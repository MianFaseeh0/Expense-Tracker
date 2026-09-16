import 'package:expensetracker/presentation/widgets/charts/expense_summary_chart.dart';
import 'package:expensetracker/screens/categories.dart';
import 'package:expensetracker/screens/new_expense.dart';
import 'package:expensetracker/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/widgets/expenses_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});
  @override
  State<TabScreen> createState() {
    return _Expensesstate();
  }
}

class _Expensesstate extends State<TabScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  List<Widget> screens = [];

  @override
  void initState() {
    super.initState();
    screens = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: CategoriesScreen(),
      ),
      ExpensesList(),
    ];
  }

  void openExpenseOverlay() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (ctx) => NewExpense()));
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 2),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Expense Tracke',
          style: GoogleFonts.spaceMono(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // drawer: DrawerScreen(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset('assets/json/homepage_background.png'),
          ),
          Align(
            alignment: Alignment.topCenter,

            child: Hero(
              tag: 'hello',
              child: Lottie.asset(
                'assets/json/gradient.json',
                height: 200,
                width: 200,
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
                child: const Chart(),
              ),
              const SizedBox(height: 15),
              Text(
                'Categories',
                style: GoogleFonts.spaceMono(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _selectPage,
                  children: screens,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.4,
        spacing: 12,
        children: [
          SpeedDialChild(
            child: Icon(Icons.attach_money),
            label: 'Add Expense',
            onTap: openExpenseOverlay,
          ),
          SpeedDialChild(
            child: Icon(Icons.task_alt),
            label: 'Add ToDo',
            onTap: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Expenses'),
        ],
        selectedItemColor: Colors.deepOrange,

        currentIndex: _selectedIndex,
        onTap: _selectPage,
      ),
    );
  }
}
