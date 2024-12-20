// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:manganrek_mobile/rating_ulasan/screens/reviewpage.dart';
import 'package:manganrek_mobile/restoran_makanan/models/rumah_makan.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:manganrek_mobile/rating_ulasan/screens/viewresto.dart';

class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({super.key});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reviewNameController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  final TextEditingController _visitDateController = TextEditingController();
  RumahMakan? _selectedRestaurant;
  double _rating = 3;
  List<RumahMakan> _rumahMakanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRumahMakanList();
  }

  Future<void> _loadRumahMakanList() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request
          .get('http://127.0.0.1:8000/restoran-makanan/json-rumahmakan/');

      setState(() {
        _rumahMakanList = response
            .map<RumahMakan>((json) => RumahMakan.fromJson(json))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error loading data: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _submitForm(BuildContext context, CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await request.postJson(
          "http://127.0.0.1:8000/review/create-flutter/",
          jsonEncode(<String, dynamic>{
            'user': request.jsonData['id'],
            'review_name': _reviewNameController.text,
            'rumah_makan': _selectedRestaurant,
            'stars': _rating,
            'comments': _commentsController.text,
            'visit_date': _visitDateController.text,
            'created_at': DateTime.now().toIso8601String()
          }),
        );

        if (context.mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Review successfully saved!"),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ReviewEntryPage(),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response['message'] ??
                    "An error occurred. Please try again."),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Tambah Ulasan', style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading restaurants...',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bagi pengalamannya, Rek!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ulasanmu membantu untuk pengalaman makan yang lebih mantap!',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildInputField(
                        controller: _reviewNameController,
                        label: 'Judul Ulasan',
                        hint: 'Judulnya yang menarik pembaca, Rek!',
                        icon: Icons.title,
                      ),
                      const SizedBox(height: 24),
                      _buildRestaurantSelector(theme),
                      const SizedBox(height: 32),
                      _buildRatingSection(theme),
                      const SizedBox(height: 24),
                      _buildInputField(
                        controller: _commentsController,
                        label: 'Komentar',
                        hint: 'Cerita pengalamanmu di sini, Rek!',
                        icon: Icons.rate_review,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      _buildDatePicker(theme),
                      const SizedBox(height: 40),
                      _buildSubmitButton(request, theme),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field tidak boleh kosong!';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRestaurantSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rumah Makan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final selectedRumahMakan = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantSelectionPage(
                    rumahMakanList: _rumahMakanList,
                  ),
                ),
              );
              if (selectedRumahMakan != null) {
                setState(() {
                  _selectedRestaurant = selectedRumahMakan;
                });
              }
            },
            icon: Icon(
              _selectedRestaurant != null
                  ? Icons.check_circle
                  : Icons.restaurant,
              color: Colors.white,
            ),
            label: Text(
              _selectedRestaurant != null
                  ? _selectedRestaurant!.fields.nama
                  : 'Pilih Rumah Makan',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedRestaurant != null
                  ? Colors.green
                  : theme.primaryColor,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 40,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rating) {
              setState(() {
                _rating = rating;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Kunjung',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _visitDateController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Pilih tanggal kamu berkunjung, Rek!',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: theme.primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (pickedDate != null) {
              setState(() {
                _visitDateController.text =
                    '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
              });
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(CookieRequest request, ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _submitForm(context, request),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'Kirim Ulasan',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
