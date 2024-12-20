import 'package:flutter/material.dart';
import 'package:manganrek_mobile/restoran_makanan/models/makanan.dart';
import 'package:manganrek_mobile/restoran_makanan/models/rumah_makan.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class DetailRumahMakanPage extends StatefulWidget {
  final String idRumahMakan;

  const DetailRumahMakanPage({super.key, required this.idRumahMakan});

  @override
  State<DetailRumahMakanPage> createState() => _RumahMakanDetailPageState();
}

class _RumahMakanDetailPageState extends State<DetailRumahMakanPage> {
  late Future<RumahMakan> _rumahMakan;

  @override
  void initState() {
    super.initState();
    _rumahMakan = _fetchRumahMakan(context.read<CookieRequest>());
  }

  Future<RumahMakan> _fetchRumahMakan(CookieRequest request) async {
    final response = await request.get(
      'https://anders-willard-manganrek.pbp.cs.ui.ac.id/restoran-makanan/json-rumahmakan/${widget.idRumahMakan}/'
    );

    if (response == null || response.isEmpty) {
      throw Exception('Rumah Makan tidak ditemukan');
    }

    return RumahMakan.fromJson(response[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<RumahMakan>(
          future: _rumahMakan,
          builder: (context, rumahMakanSnapshot) {
            if (rumahMakanSnapshot.hasData) {
              return Text(
                rumahMakanSnapshot.data!.fields.nama,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }
            return const Text('Detail Rumah Makan');
          },
        ),
        backgroundColor: const Color(0xFF2f5233),
      ),
      body: FutureBuilder<RumahMakan>(
        future: _rumahMakan,
        builder: (context, rumahMakanSnapshot) {
          if (rumahMakanSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2f5233),
              ),
            );
          }

          if (!rumahMakanSnapshot.hasData) {
            return const Center(
              child: Text('Rumah Makan tidak ditemukan'),
            );
          }

          final rumahMakan = rumahMakanSnapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRestaurantHeader(rumahMakan),
                _buildMenuSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantHeader(RumahMakan rumahMakan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2f5233).withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            icon: Icons.location_on,
            text: rumahMakan.fields.alamat,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            icon: Icons.local_fire_department,
            text: 'Tingkat Kepedasan: ${_getSpicyLevel(rumahMakan.fields.tingkatKepedasan)}',
          ),
          const SizedBox(height: 8),
          FutureBuilder<String>(
            future: fetchRentangHarga(
              context.read<CookieRequest>(), 
              rumahMakan.pk
            ),
            builder: (context, snapshot) {
              return _buildDetailRow(
                icon: Icons.attach_money,
                text: snapshot.hasData
                  ? 'Rentang Harga: ${snapshot.data!}'
                  : 'Memuat rentang harga...',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon, 
          color: const Color(0xFF2f5233),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Menu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2f5233),
            ),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Makanan>>(
            future: _fetchMenuByRumahMakan(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2f5233),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Tidak ada menu tersedia');
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final makanan = snapshot.data![index];
                  return ListTile(
                    title: Text(makanan.fields.namaMakanan),
                    subtitle: Text('Rp ${_formatHarga(makanan.fields.harga)}'),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Makanan>> _fetchMenuByRumahMakan() async {
    final request = context.read<CookieRequest>();
    final response = await request.get(
      'https://anders-willard-manganrek.pbp.cs.ui.ac.id/restoran-makanan/json-menu-by-rumahmakan/${widget.idRumahMakan}/'
    );

    List<Makanan> menuList = [];
    for (var d in response) {
      if (d != null) {
        menuList.add(Makanan.fromJson(d));
      }
    }
    return menuList;
  }

  String _getSpicyLevel(int level) {
    if (level <= 0) {
      return 'Tidak Pedas';
    } else if (level <= 2) {
      return 'Hampir Tidak Pedas';
    } else if (level <= 4) {
      return 'Sedikit Pedas';
    } else if (level <= 6) {
      return 'Pedas';
    } else if (level <= 8) {
      return 'Sangat Pedas';
    } else {
      return 'Ekstrem Pedas';
    }
  }

  Color _getSpicynessColor(int level) {
    if (level <= 2) {
      return Colors.green; // Mild
    } else if (level <= 4) {
      return Colors.lightGreen; // Light
    } else if (level <= 6) {
      return Colors.orange; // Medium
    } else if (level <= 8) {
      return Colors.deepOrange; // Hot
    } else {
      return Colors.red; // Extreme
    }
  }

  Future<String> fetchRentangHarga(
      CookieRequest request, String idRumahMakan) async {
    final response = await request.get(
        'https://anders-willard-manganrek.pbp.cs.ui.ac.id/restoran-makanan/json-menu-by-rumahmakan/$idRumahMakan/');

    if (response == null || response.isEmpty) {
      return 'Tidak ada menu';
    }

    int minHarga = 999999999;
    int maxHarga = 0;

    for (var d in response) {
      if (d != null) {
        Makanan makanan = Makanan.fromJson(d);
        if (makanan.fields.harga < minHarga) {
          minHarga = makanan.fields.harga;
        }
        if (makanan.fields.harga > maxHarga) {
          maxHarga = makanan.fields.harga;
        }
      }
    }

    if (minHarga == 999999999 && maxHarga == 0) {
      return 'Tidak ada menu';
    }

    return 'Rp ${_formatHarga(minHarga)} - Rp ${_formatHarga(maxHarga)}';
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}