
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- Needed for DateFormat
import 'package:uuid/uuid.dart';

final formater = DateFormat.yMd();

const uuid = Uuid();

enum Catogary { food, extras, leisure, work, household, personal }

const CategoryIcons = {
  Catogary.food: Icons.lunch_dining,
  Catogary.extras: Icons.yard_rounded,
  Catogary.work: Icons.work_sharp,
  Catogary.leisure: Icons.chair,
  Catogary.household: Icons.house,
  Catogary.personal: Icons.emoji_symbols_outlined,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    this.image,
    required this.catogary,
  }) : id = uuid.v4();

  final String title;

  final double amount;
  final String id;
  final Text? image;
  final DateTime date;
  final Catogary catogary;

  String get formattedData {
    return formater.format(date);
  }
}

class ExpenseBucket {
  ExpenseBucket.forCategory(List<Expense> allExpense, this.catogary)
    : expenses = allExpense
          .where((expense) => expense.catogary == catogary)
          .toList();
  ExpenseBucket({required this.catogary, required this.expenses});
  final Catogary catogary;
  final List<Expense> expenses;

  double get totalExpense {
    double sum = 0;

    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
}
