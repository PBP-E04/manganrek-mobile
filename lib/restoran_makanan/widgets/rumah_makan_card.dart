import 'package:flutter/material.dart';
import 'package:manganrek_mobile/restoran_makanan/models/rumah_makan.dart';
import 'package:manganrek_mobile/restoran_makanan/models/makanan.dart';
import 'package:manganrek_mobile/restoran_makanan/screens/detail_rumah_makan.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RumahMakanCard extends StatelessWidget {
  final RumahMakan rumahMakan;

  const RumahMakanCard({super.key, required this.rumahMakan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to RumahMakanDetailPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailRumahMakanPage(idRumahMakan: rumahMakan.pk),
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
              // Nama Rumah Makan
              Text(
                rumahMakan.fields.nama,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF2f5233),
                ),
              ),
              const SizedBox(height: 8),

              // Alamat
              _buildInfoRow(
                icon: Icons.location_on,
                text: rumahMakan.fields.alamat,
              ),
              const SizedBox(height: 8),

              // Tingkat Kepedasan
              _buildInfoRow(
                icon: Icons.local_fire_department,
                text:
                    'Tingkat Kepedasan: ${_getSpicyLevel(rumahMakan.fields.tingkatKepedasan)}',
                spicyLevel: rumahMakan.fields.tingkatKepedasan,
              ),
              const SizedBox(height: 8),

              // Rentang Harga
              FutureBuilder<String>(
                future: fetchRentangHarga(
                    context.read<CookieRequest>(), rumahMakan.pk),
                builder: (context, snapshot) {
                  return _buildInfoRow(
                    icon: Icons.attach_money,
                    text: snapshot.hasData
                        ? 'Rentang Harga: ${snapshot.data!}'
                        : 'Loading...',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      {required IconData icon, required String text, int? spicyLevel}) {
    return Row(
      children: [
        Icon(
          icon,
          color: spicyLevel != null
              ? _getSpicynessColor(spicyLevel)
              : const Color(0xFF2f5233),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: spicyLevel != null
                  ? _getSpicynessColor(spicyLevel)
                  : Colors.black87,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
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
