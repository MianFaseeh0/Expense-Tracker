import 'package:expensetracker/sign-login-screens/startup_screens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Drawerwidget extends StatelessWidget {
  const Drawerwidget({required this.onSelectScreen, super.key});

  final void Function(String identifier) onSelectScreen;

  void logout(context) {
    FirebaseAuth.instance.signOut();
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (ctx) => StartupScreens()));
  }

  @override
  Widget build(context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 40,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                const SizedBox(width: 10),
                Text(
                  'Holding Up!',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 30,
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ],
            ),
          ),
          // ListTile(
          //   splashColor: Theme.of(context).colorScheme.onTertiaryFixedVariant,
          //   onTap: () {
          //     onSelectScreen('Home');
          //   },
          //   leading: Icon(Icons.fastfood_rounded),

          //   title: Text('Home', style: GoogleFonts.dmSerifDisplay()),
          // ),

          // ListTile(
          //   splashColor: Theme.of(context).colorScheme.onTertiaryFixedVariant,
          //   onTap: () {
          //     onSelectScreen('Filters');
          //   },
          //   leading: Icon(Icons.settings_rounded),

          //   title: Text('Filters', style: GoogleFonts.dmSerifDisplay()),
          // ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 0, 0, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              logout(context);
            },
            child: Text(
              'Logout',
              style: GoogleFonts.dmSerifDisplay(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
