import 'dart:io';

import 'package:bill_app/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _materialNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _vendorNameController = TextEditingController();
  final TextEditingController _formNameController = TextEditingController();

  // Dropdown
  final List<String> _units = ["Ton", "Kilogram", "Litre", "Meter"];
  String? _selectedUnit;

  // Image
  File? _image;
  final ImagePicker _picker = ImagePicker();

  //Photo url and the database instance
  String url = "";
  final db = Database();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });

      // Await the actual result here
      var downloadUrl = await uploadImageToStorage(_image!);
      url = downloadUrl;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void dispose() {
    _materialNameController.dispose();
    _quantityController.dispose();
    _vendorNameController.dispose();
    super.dispose();
  }

  Future<String> uploadImageToStorage(File file) async {
    final id = const Uuid().v4();
    final imageRef = FirebaseStorage.instance.ref('images').child(id);
    final uploadImage = imageRef.putFile(file);

    final snapShot = await uploadImage;
    final downloadedUrl = await snapShot.ref.getDownloadURL();
    print(downloadedUrl);
    return downloadedUrl;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a unit')),
        );
        SnackBar(
          content: Text("Submitted Successfully"),
          duration: Duration(seconds: 1),
        );
        return;
      }

      // Form is valid and unit is selected
      print("Material: ${_materialNameController.text}");
      print("Quantity: ${_quantityController.text}");
      print("Vendor: ${_vendorNameController.text}");
      print("Unit: $_selectedUnit");
      print("Image: ${_image?.path ?? 'No image selected'}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form submitted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Form Page', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[600],
        leading: BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _formNameController,
                label: 'Form Name',
                hint: 'Enter Form Name',
              ),
              _buildTextField(
                controller: _materialNameController,
                label: 'Material Name',
                hint: 'Enter Material Name',
              ),
              _buildTextField(
                controller: _quantityController,
                label: 'Quantity',
                hint: 'Enter Quantity',
              ),
              _buildTextField(
                controller: _vendorNameController,
                label: 'Vendor Name',
                hint: 'Enter Vendor Name',
              ),

              // Dropdown
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                hint: const Text('Select Unit'),
                items: _units.map((unit) {
                  return DropdownMenuItem(value: unit, child: Text(unit));
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedUnit = value);
                },
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Image Upload Button
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.upload_file),
                label: Text(_image == null ? "Upload Bill" : "Change Bill"),
              ),
              if (_image != null) ...[
                const SizedBox(height: 10),
                Image.file(_image!, height: 150),
              ],
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: () async {

                  try {
                    if (url.isEmpty) {
                      _submitForm();
                      print(Services.userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Upload failed. Try again.")));
                    } else {
                      print("DATABASE ENTRY");
                      await db.insertBill(
                          _formNameController.text.trim(),
                          _materialNameController.text.trim(),
                          _quantityController.text.trim(),
                          _vendorNameController.text.trim(),
                          _selectedUnit!,
                          url);
                    }
                  } catch (e) {
                    print("Database Error");
                    print(e);
                  }
                  Navigator.of(context).pop();


                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
