import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/widgets/chart_bar.dart';
import 'package:expensetracker/model/data.dart';
import 'package:google_fonts/google_fonts.dart';

class Chart extends StatefulWidget {
  const Chart({super.key});

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  Stream<List<Expense>> fetchExpensesStream() {
    return FirebaseFirestore.instance
        .collection('expenses')
        .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return Expense(
              title: data['name'],
              amount: (data['amount'] as num).toDouble(),
              date: (data['date'] as Timestamp).toDate(),
              catogary: Catogary.values.firstWhere(
                (c) => c.name == data['category'],
                orElse: () => Catogary.food,
              ),
            );
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(
              60,
              118,
              118,
              118,
            ).withValues(alpha: .25),
            borderRadius: BorderRadius.circular(20),
          ),
          child: StreamBuilder<List<Expense>>(
            stream: fetchExpensesStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData ||
                  snapshot.data!.isEmpty ||
                  snapshot.data == null) {
                final buckets = [
                  ExpenseBucket.forCategory([], Catogary.food),
                  ExpenseBucket.forCategory([], Catogary.leisure),
                  ExpenseBucket.forCategory([], Catogary.extras),
                  ExpenseBucket.forCategory([], Catogary.work),
                  ExpenseBucket.forCategory([], Catogary.household),
                  ExpenseBucket.forCategory([], Catogary.personal),
                ];

                return Column(
                  children: [
                    Spacer(),

                    Center(
                      child: Text(
                        'Empty',
                        style: GoogleFonts.spaceMono(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: buckets
                          .map(
                            (bucket) => Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Icon(CategoryIcons[bucket.catogary]),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                );
              }

              final expenses = snapshot.data!;

              // Build buckets
              final buckets = [
                ExpenseBucket.forCategory(expenses, Catogary.food),
                ExpenseBucket.forCategory(expenses, Catogary.leisure),
                ExpenseBucket.forCategory(expenses, Catogary.extras),
                ExpenseBucket.forCategory(expenses, Catogary.work),
                ExpenseBucket.forCategory(expenses, Catogary.household),
                ExpenseBucket.forCategory(expenses, Catogary.personal),
              ];

              // Find max total expense
              double maxTotalExpense = 0;
              for (final bucket in buckets) {
                if (bucket.totalExpense > maxTotalExpense) {
                  maxTotalExpense = bucket.totalExpense;
                }
              }

              return Column(
                children: [
                  Spacer(),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final bucket in buckets)
                          ChartBar(
                            fill: bucket.totalExpense == 0
                                ? 0
                                : bucket.totalExpense / maxTotalExpense,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: buckets
                        .map(
                          (bucket) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Icon(CategoryIcons[bucket.catogary]),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
