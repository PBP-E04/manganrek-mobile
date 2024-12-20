import 'package:flutter/material.dart';
import 'package:manganrek_mobile/restoran_makanan/models/makanan.dart';
import 'package:manganrek_mobile/restoran_makanan/models/rumah_makan.dart';
import 'package:manganrek_mobile/restoran_makanan/screens/detail_rumah_makan.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class MakananCard extends StatelessWidget {
  final Makanan makanan;

  const MakananCard({super.key, required this.makanan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to RumahMakanDetailPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRumahMakanPage(idRumahMakan: makanan.fields.idRumahMakan),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Makanan
              Text(
                makanan.fields.namaMakanan,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2f5233),
                ),
              ),
              const SizedBox(height: 8),

              // Nama Rumah Makan
              FutureBuilder<String>(
                future: fetchNamaRumahMakanById(
                    context.read<CookieRequest>(), makanan.fields.idRumahMakan),
                builder: (context, snapshot) {
                  return _buildInfoRow(
                    icon: Icons.restaurant,
                    text: snapshot.hasData ? snapshot.data! : 'Loading...',
                  );
                },
              ),
              const SizedBox(height: 8),

              // Harga
              _buildInfoRow(
                icon: Icons.attach_money,
                text: 'Rp ${_formatHarga(makanan.fields.harga)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatHarga(int harga) {
    return harga.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Future<String> fetchNamaRumahMakanById(
      CookieRequest request, String id) async {
    final response = await request.get(
        'https://anders-willard-manganrek.pbp.cs.ui.ac.id/restoran-makanan/json-rumahmakan/$id/');
    var data = response[0];

    return RumahMakan.fromJson(data).fields.nama;
  }
}
