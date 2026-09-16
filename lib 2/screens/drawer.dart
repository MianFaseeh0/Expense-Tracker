import 'package:expensetracker/provider/name_provider.dart';
import 'package:expensetracker/screens/new_expense.dart';
import 'package:expensetracker/sign-login-screens/startup_screens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DrawerScreen extends StatelessWidget {
  const DrawerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'User',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Consumer(
                builder: (context, ref, child) {
                  final name = ref.watch(stringProvider);
                  return Text(
                    name,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.start,
                  );
                },
              ),
            ),
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.attach_money_outlined),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => NewExpense()),
                );
                
              },
              label: Text('ADD NEW EXPENSE'),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              icon: Icon(Icons.list),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => NewExpense()),
                );
              },
              label: Text('GO TO EXPENSES SCREEN'),
            ),
            Spacer(),
            ElevatedButton.icon(
              icon: Icon(Icons.logout_outlined),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                PopupMenuButton<String>(
                  child: Text('YOUR DATA WILL REMAIN SAVED!'),
                  onSelected: (value) {
                    if (value == "LOG OUT") {
                      FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (ctx) => StartupScreens()),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: "LOG OUT", child: Text("LOG OUT")),
                    PopupMenuItem(value: "CANCEL", child: Text("CANCEL")),
                  ],
                );
              },
              label: Text('LOG OUT'),
            ),
          ],
        ),
      ),
    );
  }
}
