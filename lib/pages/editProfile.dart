import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final String email;
  final String name;
  final String dob;
  final String phone;
  final String gender;
  final String address;
  final String imageUrl;

  const EditProfilePage({
    Key? key,
    required this.email,
    required this.name,
    required this.dob,
    required this.phone,
    required this.gender,
    required this.address,
    required this.imageUrl,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneController;
  late TextEditingController _genderController;
  late TextEditingController _addressController;
  late Future<String> _loggedInEmail;
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _dobController = TextEditingController(text: widget.dob);
    _phoneController = TextEditingController(text: widget.phone);
    _genderController = TextEditingController(text: widget.gender);
    _addressController = TextEditingController(text: widget.address);
    _loggedInEmail = _loadLoggedInEmail();
  }

  Future<String> _loadLoggedInEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_profileImage == null) return;

    final uri = Uri.parse('http://192.168.100.31/surya4/lib/API/APIeditProfile.php');
    final request = http.MultipartRequest('POST', uri)
      ..fields['email'] = widget.email
      ..fields['nama'] = _nameController.text
      ..fields['tanggalLahir'] = _dobController.text
      ..fields['noTelp'] = _phoneController.text
      ..fields['jenisKelamin'] = _genderController.text
      ..fields['alamat'] = _addressController.text;

    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        _profileImage!.path,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      // Data berhasil diupdate, lakukan sesuatu jika perlu
      print('Profile updated successfully');
    } else {
      // Handle error jika request gagal
      _handleError('Failed to update profile');
    }
  }

  void _handleError(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      _uploadImage().then((_) {
        // Tambahkan navigasi kembali ke halaman profil
        // Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<String>(
          future: _loggedInEmail,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading email'));
            } else {
              return Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : NetworkImage(widget.imageUrl) as ImageProvider,
                          child: _profileImage == null
                              ? const Icon(Icons.camera_alt, size: 50)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Lahir',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal Lahir tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor HP',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor HP tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                   
                    TextFormField(
                      controller: _genderController,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kelamin',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Jenis Kelamin tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
