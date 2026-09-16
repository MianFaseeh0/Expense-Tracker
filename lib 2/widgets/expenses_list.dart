import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/model/data.dart';
import 'package:expensetracker/screens/expense_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpensesList extends ConsumerStatefulWidget {
  const ExpensesList({super.key});

  @override
  ConsumerState<ExpensesList> createState() => _ExpensesListState();
}

class _ExpensesListState extends ConsumerState<ExpensesList> {
  Widget _buildPlaceholderIcon() {
    return const Icon(
      Icons.receipt_long,
      size: 40,
      color: Color.fromARGB(255, 255, 255, 255),
    );
  }

  @override
  Widget build(context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('expenses')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'Oh O! No Expenses here try adding some.',
            style: GoogleFonts.spaceMono(
              color: const Color.fromARGB(255, 0, 0, 0),
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (ctx, index) {
            final data =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final timestamp = data['date'] as Timestamp;
            final date = timestamp.toDate();

            // Safely handle image path
            final imagePath = data['image-path'] as String?;
            final imageFile = imagePath != null && imagePath.isNotEmpty
                ? File(imagePath)
                : null;

            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => ExpenseDetailScreen(
                      detail: data['description'] ?? '',
                      title: data['name'] ?? 'Untitled',
                      image: imageFile,
                      cat:
                          CategoryIcons[Catogary.values.firstWhere(
                            (c) => c.name == data['category'],
                            orElse: () => Catogary.extras,
                          )]!,
                    ),
                  ),
                );
              },
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Item?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          final deletedDoc = snapshot.data!.docs[index];
                          final deletedData =
                              deletedDoc.data() as Map<String, dynamic>;

                          FirebaseFirestore.instance
                              .collection('expenses')
                              .doc(snapshot.data!.docs[index].id)
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('expenses')
                                      .doc(deletedDoc.id)
                                      .set(deletedData);
                                },
                              ),
                              content: const Row(
                                children: [Text('Expense deleted'), Spacer()],
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              },
              child: Card(
                color: Colors.black,
                elevation: 10,
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shadowColor: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            60,
                            118,
                            118,
                            118,
                          ).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Hero(
                          tag: 'image',
                          child: imageFile != null
                              ? FutureBuilder<bool>(
                                  future: imageFile.exists(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }

                                    if (snapshot.hasData &&
                                        snapshot.data == true) {
                                      return Image.file(
                                        imageFile,
                                        fit: BoxFit.cover,
                                      );
                                    } else {
                                      return _buildPlaceholderIcon();
                                    }
                                  },
                                )
                              : _buildPlaceholderIcon(),
                        ),
                      ),

                      Text(
                        data['name'] ?? 'Untitled',
                        style: GoogleFonts.spaceMono(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            '\$${data['amount']?.toStringAsFixed(2) ?? '0.00'}',
                            style: GoogleFonts.spaceMono(color: Colors.white),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(
                                CategoryIcons[Catogary.values.firstWhere(
                                  (c) => c.name == data['category'],
                                  orElse: () => Catogary.extras,
                                )],
                                color: Colors.white,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                '${date.day}/${date.month}/${date.year}',
                                style: GoogleFonts.spaceMono(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
