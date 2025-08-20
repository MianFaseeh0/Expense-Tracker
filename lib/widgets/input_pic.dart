import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InputPic extends StatefulWidget {
  InputPic({required this.onPickedImage, super.key});
  void Function(File onPicked) onPickedImage;
  @override
  State<InputPic> createState() => _InputPicState();
}

class _InputPicState extends State<InputPic> {
  File? _selectedImage;
  void _takeImage() async {
    final getImage = ImagePicker();
    final image = await getImage.pickImage(
      source: ImageSource.camera,
      maxWidth: double.infinity,
    );
    if (image == null) {
      return;
    }
    setState(() {
      _selectedImage = File(image.path);
    });
    widget.onPickedImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      icon: Icon(Icons.camera_sharp, color: Colors.black),
      onPressed: _takeImage,
      label: Text('Add Image', style: TextStyle(color: Colors.black)),
    );
    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takeImage,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          cacheWidth: 300, // Try tweaking based on your needs
          cacheHeight: 90,
        ),
      );
    }
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(70, 42, 42, 42),
      ),
      clipBehavior: Clip.hardEdge,
      child: content,
    );
  }
}
