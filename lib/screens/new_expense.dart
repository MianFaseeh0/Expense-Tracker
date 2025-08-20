import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/widgets/input_pic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:expensetracker/model/data.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class NewExpense extends ConsumerStatefulWidget {
  const NewExpense({super.key});

  @override
  ConsumerState<NewExpense> createState() {
    return _NewExpensestate();
  }
}

class _NewExpensestate extends ConsumerState<NewExpense> {
  File? _PickedImage;

  DateTime _selectedDate = DateTime.now();

  late final _nameController = TextEditingController();
  late final _amountController = TextEditingController();
  late final _descriptionController = TextEditingController();

  final _fromkey = GlobalKey<FormState>();

  var isSending = false;
  Catogary _selectedCatogary = Catogary.extras;

  void _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(now.year - 20, now.month, now.day),
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate!;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<Directory> getSaveDirectory() async {
    if (Platform.isAndroid) {
      return await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  Future<File> saveImageToFile(File image, Directory dir) async {
    final String filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String newPath = '${dir.path}/$filename';
    final File newFile = await File(image.path).copy(newPath);
    return newFile;
  }

  Future<void> uploadExpenses() async {
    if (_fromkey.currentState!.validate()) {
      setState(() {
        isSending = true;
      });

      final image = _PickedImage;

      final dir = await getSaveDirectory();
      final savedImage = await saveImageToFile(image!, dir);
      print('Image saved at: ${savedImage.path}');

      try {
        await FirebaseFirestore.instance.collection('expenses').add({
          'name': _nameController.text.trim(),
          'date': _selectedDate,
          'amount': int.parse(_amountController.text.trim()),
          'category': _selectedCatogary.name,
          'user': FirebaseAuth.instance.currentUser!.uid,
          'image-path': savedImage.path,
          'description': _descriptionController.text.trim(),
        });

        if (mounted) {
          setState(() {
            isSending = false;
          });

          print("Saving complete. Now popping.");
          Navigator.of(context).pop();

          Fluttertoast.showToast(
            toastLength: Toast.LENGTH_SHORT,
            msg: 'Expense Added',
            gravity: ToastGravity.BOTTOM,
          );
        }
      } catch (e) {
        print("Error while uploading expense: $e");
        if (mounted) {
          setState(() {
            isSending = false;
          });
        }
      }
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add new Expense')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Form(
              key: _fromkey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(label: Text('Name of Expense')),
                    maxLength: 50,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return 'Must be between 1 and 50 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      label: Text('Description of Expense'),
                    ),
                    maxLength: 1000,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            label: Text('Enter Amount'),
                            prefixText: '\$',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null) {
                              return 'must be a value';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 17),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(formater.format(_selectedDate)),
                            IconButton(
                              onPressed: _presentDatePicker,
                              icon: Icon(Icons.calendar_month),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    value: _selectedCatogary,
                    items: Catogary.values
                        .map(
                          (catogary) => DropdownMenuItem(
                            value: catogary,
                            child: Text(catogary.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCatogary = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  InputPic(
                    onPickedImage: (image) {
                      _PickedImage = image;
                    },
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        await uploadExpenses();
                      },
                      child: Text(
                        'submit',
                        style: GoogleFonts.spaceMono(color: Colors.black),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,

                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'cancel',
                        style: GoogleFonts.spaceMono(color: Colors.black),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    child: Text('sign out'),
                  ),
                ],
              ),
            ),
          ),
          if (isSending)
            Container(
              color: const Color.fromARGB(112, 0, 0, 0),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
