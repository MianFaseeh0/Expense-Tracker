import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A tap-to-capture field for attaching a receipt photo to an expense.
///
/// Renamed from `InputPic` to `ExpenseImagePickerField` to describe its
/// role rather than its implementation detail.
class ExpenseImagePickerField extends StatefulWidget {
  const ExpenseImagePickerField({required this.onImagePicked, super.key});

  final ValueChanged<File> onImagePicked;

  @override
  State<ExpenseImagePickerField> createState() =>
      _ExpenseImagePickerFieldState();
}

class _ExpenseImagePickerFieldState extends State<ExpenseImagePickerField> {
  File? _selectedImage;

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final selected = File(pickedFile.path);
    setState(() => _selectedImage = selected);
    widget.onImagePicked(selected);
  }

  @override
  Widget build(BuildContext context) {
    final image = _selectedImage;

    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(70, 42, 42, 42),
      ),
      clipBehavior: Clip.hardEdge,
      child: image == null
          ? TextButton.icon(
              icon: const Icon(Icons.camera_sharp, color: Colors.black),
              onPressed: _captureImage,
              label: const Text(
                'Add Image',
                style: TextStyle(color: Colors.black),
              ),
            )
          : GestureDetector(
              onTap: _captureImage,
              child: Image.file(
                image,
                fit: BoxFit.cover,
                cacheWidth: 300,
                cacheHeight: 90,
              ),
            ),
    );
  }
}
