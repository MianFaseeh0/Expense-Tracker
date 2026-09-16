import 'package:expensetracker/presentation/widgets/charts/expense_summary_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/asset_paths.dart';
import '../../widgets/common/spending_overview_card.dart';
import '../../widgets/expense/expense_list_view.dart';
import '../../widgets/navigation/app_navigation_drawer.dart';
import '../expense/add_expense_screen.dart';
import 'category_grid_screen.dart';

/// The signed-in home shell: tabbed categories/expenses view and the
/// add-expense speed dial. The overall expense card stays fixed at
/// the top; the chart used to live here too, but now lives inside
/// [ExpenseListView], where it collapses away as that tab is scrolled.
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  static const _tabs = [
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: CategoryGridScreen(),
    ),
    ExpenseListView(),
  ];

  void _openAddExpenseScreen() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
  }

  void _selectTab(int index) {
    setState(() => _selectedTabIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(
          'Expense Tracker',
          style: GoogleFonts.spaceMono(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const AppNavigationDrawer(),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(AssetPaths.homeBackground),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Hero(
              tag: 'hello',
              child: Lottie.asset(
                AssetPaths.gradientAnimation,
                height: 200,
                width: 200,
              ),
            ),
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                child: SpendingOverviewCard(),
              ),
              const SizedBox(height: 12),
              if(_selectedTabIndex == 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ExpenseSummaryChart(),
                            ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _selectedTabIndex = index),
                  children: _tabs,
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
            child: const Icon(Icons.attach_money),
            label: 'Add Expense',
            onTap: _openAddExpenseScreen,
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
        currentIndex: _selectedTabIndex,
        onTap: _selectTab,
      ),
    );
  }
}