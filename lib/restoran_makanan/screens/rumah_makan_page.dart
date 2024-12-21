import 'package:flutter/material.dart';
import 'package:manganrek_mobile/widgets/navbar.dart';
import 'package:manganrek_mobile/restoran_makanan/widgets/rumah_makan_card.dart';
import 'package:manganrek_mobile/restoran_makanan/widgets/makanan_card.dart';
import 'package:manganrek_mobile/restoran_makanan/models/rumah_makan.dart';
import 'package:manganrek_mobile/restoran_makanan/models/makanan.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RumahMakanPage extends StatefulWidget {
  const RumahMakanPage({super.key});

  @override
  State<RumahMakanPage> createState() => _RumahMakanPageState();
}

class _RumahMakanPageState extends State<RumahMakanPage> {
  bool _isRumahMakanView = true;
  final TextEditingController _searchController = TextEditingController();

  // Filter variables
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minSpicyController = TextEditingController();
  final TextEditingController _maxSpicyController = TextEditingController();

  Future<List<RumahMakan>> fetchRumahMakan(CookieRequest request) async {
    final response = await request.get('https://anders-willard-manganrek.pbp.cs.ui.ac.id/restoran-makanan/json-rumahmakan/');
    var data = response;
    
    // Melakukan konversi data json menjadi object RumahMakan
    List<RumahMakan> listRumahMakan = [];
    for (var d in data) {
      if (d != null) {
        listRumahMakan.add(RumahMakan.fromJson(d));
      }
    }
    return listRumahMakan;
  }

  Future<List<Makanan>> fetchMakanan(CookieRequest request) async {
    final response = await request.get('https://anders-willard-manganrek.pbp.cs.ui.ac.id/restoran-makanan/json-menu/');
    var data = response;
    
    // Melakukan konversi data json menjadi object Makanan
    List<Makanan> listMakanan = [];
    for (var d in data) {
      if (d != null) {
        listMakanan.add(Makanan.fromJson(d));
      }
    }
    return listMakanan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('ManganRek!',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      bottomNavigationBar: const Navbar(currentIndex: 0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2f5233).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildToggleViewButtons(),
            const SizedBox(height: 16),
            _buildSearchAndFilterRow(),
            Expanded(
              child: _isRumahMakanView
                  ? _buildRumahMakanList()
                  : _buildMakananList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRumahMakanModal,
        backgroundColor: const Color(0xFF2f5233),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildToggleViewButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isRumahMakanView = true),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: _isRumahMakanView
                              ? const Color(0xFF2f5233)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            'Rumah Makan',
                            style: TextStyle(
                              color: _isRumahMakanView
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isRumahMakanView = false),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: !_isRumahMakanView
                              ? const Color(0xFF2f5233)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            'Makanan',
                            style: TextStyle(
                              color: !_isRumahMakanView
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: _isRumahMakanView
                      ? 'Cari rumah makan...'
                      : 'Cari makanan...',
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF2f5233)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildIconButton(Icons.filter_list, _showFilterModal),
          const SizedBox(width: 8),
          _buildIconButton(Icons.sort, _showSortModal),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF2f5233)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: _showAddRumahMakanModal,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2f5233),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 4,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add),
            SizedBox(width: 8),
            Text(
              'Tambah Rumah Makan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRumahMakanList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<List<RumahMakan>>(
        future: fetchRumahMakan(context.watch<CookieRequest>()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2f5233),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada rumah makan ditemukan'),
            );
          }

          // Filter the list based on search query
          final filteredList = snapshot.data!.where((rumahMakan) {
            final searchQuery = _searchController.text.toLowerCase();
            return rumahMakan.fields.nama.toLowerCase().contains(searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final rumahMakan = filteredList[index];
              return RumahMakanCard(
                rumahMakan: rumahMakan,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMakananList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: FutureBuilder<List<Makanan>>(
        future: fetchMakanan(context.watch<CookieRequest>()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2f5233),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Tidak ada makanan ditemukan'),
            );
          }

          // Filter the list based on search query
          final filteredList = snapshot.data!.where((makanan) {
            final searchQuery = _searchController.text.toLowerCase();
            return makanan.fields.namaMakanan.toLowerCase().contains(searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final makanan = filteredList[index];
              return MakananCard(
                makanan: makanan,
              );
            },
          );
        },
      ),
    );
  }

  void _showAddRumahMakanModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tambah Rumah Makan Baru',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2f5233),
                ),
              ),
              const SizedBox(height: 20),
              _buildStyledTextField(
                label: 'Nama Rumah Makan',
                icon: Icons.restaurant,
              ),
              const SizedBox(height: 15),
              _buildStyledTextField(
                label: 'Alamat',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 15),
              _buildStyledTextField(
                label: 'Kontak',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Save logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2f5233),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Filter Pencarian',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2f5233),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStyledTextField(
                      label: 'Harga Min',
                      controller: _minPriceController,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStyledTextField(
                      label: 'Harga Max',
                      controller: _maxPriceController,
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildStyledTextField(
                      label: 'Tingkat Pedas Min',
                      controller: _minSpicyController,
                      icon: Icons.local_fire_department,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStyledTextField(
                      label: 'Tingkat Pedas Max',
                      controller: _maxSpicyController,
                      icon: Icons.local_fire_department,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Apply filter logic
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2f5233),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Terapkan Filter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                'Urutkan Berdasarkan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2f5233),
                ),
              ),
            ),
            _buildSortTile(
              'Harga Terendah',
              Icons.arrow_downward,
              () {
                // Sort by lowest price logic
                Navigator.pop(context);
              },
            ),
            _buildSortTile(
              'Harga Tertinggi',
              Icons.arrow_upward,
              () {
                // Sort by highest price logic
                Navigator.pop(context);
              },
            ),
            _buildSortTile(
              'Tingkat Kepedasan',
              Icons.local_fire_department,
              () {
                // Sort by spiciness logic
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // Helper method for styled text fields
  Widget _buildStyledTextField({
    required String label,
    TextEditingController? controller,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
            icon != null ? Icon(icon, color: const Color(0xFF2f5233)) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: const Color(0xFF2f5233).withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: const Color(0xFF2f5233).withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF2f5233), width: 2),
        ),
      ),
    );
  }

  // Helper method for sort tiles
  Widget _buildSortTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2f5233)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
