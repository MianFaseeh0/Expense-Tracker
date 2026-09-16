import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({
    this.image,
    required this.title,
    this.cat,
    required this.detail,
    super.key,
  });
  final File? image;
  final String title, detail;
  final IconData? cat;

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Detail',
          style: GoogleFonts.spaceMono(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              child: Hero(
                tag: 'image',
                child: image != null
                    ? Image.file(image!, fit: BoxFit.cover)
                    : const Center(child: Text('No Image Added')),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(title, style: GoogleFonts.spaceMono(fontSize: 22)),
                const Spacer(),
                Icon(cat, size: 30),
              ],
            ),
            const SizedBox(height: 20),

            Text(detail, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
