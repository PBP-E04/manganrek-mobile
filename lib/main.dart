import 'package:flutter/material.dart';
import 'package:manganrek_mobile/rating_ulasan/screens/reviewform.dart';
import 'package:manganrek_mobile/rating_ulasan/screens/reviewpage.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:manganrek_mobile/screens/login.dart';

class ItemHomepage {
  final String name;
  final IconData icon;

  ItemHomepage(this.name, this.icon);
}

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    bool isLoggedIn = request.loggedIn;

    return Material(
      color: Theme.of(context).colorScheme.secondary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          if (item.name == "Tambah Mood") {
            if (isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReviewFormPage()),
              );
            } else {
              _showSnackBar(context, "Harap login terlebih dahulu.");
            }
          } else if (item.name == "Lihat Mood") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReviewEntryPage()),
            );
          } else if (item.name == "Logout") {
            if (isLoggedIn) {
              final response =
                  await request.logout("http://127.0.0.1:8000/auth/logout/");
              if (response['status']) {
                _showSnackBar(context, "${response['message']} Sampai jumpa.");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              } else {
                _showSnackBar(context, response['message']);
              }
            } else {
              _showSnackBar(context, "Anda sudah logout.");
            }
          } else if (item.name == "Login") {
            if (!isLoggedIn) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            } else {
              _showSnackBar(context, "Anda sudah login.");
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<List<dynamic>> fetchUsers(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/auth/get-users/');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    fetchUsers(request);
    bool isLoggedIn = request.loggedIn;
    String userInfo = isLoggedIn
        ? 'User: ${request.jsonData['username']} (ID: ${request.jsonData['id']})'
        : 'Belum login';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Homepage'),
      ),
      body: Column(
        children: [
          // Display the Card for login state
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: isLoggedIn ? Colors.green[200] : Colors.red[200],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  isLoggedIn ? Icons.person : Icons.warning,
                  color: Colors.white,
                ),
                title: Text(
                  isLoggedIn
                      ? 'Welcome, ${request.jsonData['username']}'
                      : 'Belum login',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                subtitle: isLoggedIn
                    ? Text('User ID: ${request.jsonData['id']}')
                    : const Text('Silakan login untuk melanjutkan.'),
                trailing: Icon(
                  isLoggedIn ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                tileColor: isLoggedIn ? Colors.green : Colors.red,
              ),
            ),
          ),

          // GridView for menu items
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              children: [
                if (!isLoggedIn) ItemCard(ItemHomepage("Login", Icons.login)),
                if (isLoggedIn)
                  ItemCard(ItemHomepage("Tambah Mood", Icons.add)),
                ItemCard(ItemHomepage("Lihat Mood", Icons.visibility)),
                if (isLoggedIn) ItemCard(ItemHomepage("Logout", Icons.logout)),
              ],
            ),
          ),
        ],
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
