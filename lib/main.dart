import 'package:flutter/material.dart';
import 'package:manganrek_mobile/rating_ulasan/screens/reviewform.dart';
import 'package:manganrek_mobile/rating_ulasan/screens/reviewpage.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:manganrek_mobile/restoran_makanan/screens/rumah_makan_page.dart';

class ItemHomepage {
  final String name;
  final IconData icon;

  ItemHomepage(this.name, this.icon);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'ManganRek!',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.lightGreen,
          ).copyWith(secondary: Colors.lightGreen[400]),
        ),
        home: RumahMakanPage(),
      ),
    );
  }
}

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<CookieRequest>(create: (_) => CookieRequest()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green),
        ),
        home: const HomePage(),
      ),
    ),
  );
}
