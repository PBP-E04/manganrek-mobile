import 'package:flutter/material.dart';
import 'package:manganrek_mobile/restoran_makanan/screens/rumah_makan_page.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key, this.currentIndex = 0}) : super(key: key);

  final int currentIndex;

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => RumahMakanPage()));
        break;
      // case 1:
      //   Navigator.pushReplacement(context,
      //       MaterialPageRoute(builder: (context) => const FavoritePage()));
      //   break;
      // case 2:
      //   Navigator.pushReplacement(context,
      //       MaterialPageRoute(builder: (context) => const ReviewPage()));
      //   break;
      // case 3:
      //   Navigator.pushReplacement(context,
      //       MaterialPageRoute(builder: (context) => const PromoPage()));
      //   break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant),
          label: 'Rumah Makan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Favorit',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.reviews),
          label: 'Review',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.discount),
          label: 'Promo',
        ),
      ],
      currentIndex: widget.currentIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      onTap: (index) => _onItemTapped(index, context),
    );
  }
}
