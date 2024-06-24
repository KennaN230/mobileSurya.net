import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class EditProfilePage extends StatefulWidget {
  final String email;
  final String name;
  final String dob;
  final String phone;
  final String gender;
  final String address;
  final String initialImageUrl;

  const EditProfilePage({
    Key? key,
    required this.email,
    required this.name,
    required this.dob,
    required this.phone,
    required this.gender,
    required this.address,
    required this.initialImageUrl, required imageUrl,
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
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  String _errorMessage = '';
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _dobController = TextEditingController(text: widget.dob);
    _phoneController = TextEditingController(text: widget.phone);
    _genderController = TextEditingController(text: widget.gender);
    _addressController = TextEditingController(text: widget.address);
    _imageUrl = widget.initialImageUrl;
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

  Future<void> updateProfile() async {
    try {
      var url = Uri.parse('http://192.168.100.31/surya4/lib/API/APIeditProfile.php');
      var request = http.MultipartRequest('POST', url);
      request.fields['email'] = widget.email;
      request.fields['nama'] = _nameController.text;
      request.fields['tanggalLahir'] = _dobController.text;
      request.fields['noTelp'] = _phoneController.text;
      request.fields['jenisKelamin'] = _genderController.text;
      request.fields['alamat'] = _addressController.text;

      if (_profileImage != null) {
        request.files.add(await http.MultipartFile.fromPath('profile_image', _profileImage!.path,
            contentType: MediaType('image', 'jpeg'))); // Ubah contentType jika diperlukan
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      // Memeriksa kode status respons
      print('Kode status respons: ${response.statusCode}');
      // Menampilkan isi respons dari server
      print('Isi respons: $responseData');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(responseData);
        // Jika respons mengandung kunci 'success', menampilkan notifikasi sukses
        if (decodedData.containsKey('success')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil berhasil diperbarui')),
          );
        }
        // Jika respons mengandung kunci 'error', menampilkan pesan error
        else if (decodedData.containsKey('error')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${decodedData['error']}')),
          );
        }
        // Jika format respons tidak sesuai yang diharapkan
        else {
          _handleError('Format respons tidak terduga');
        }
      }
      // Jika respons tidak berhasil (kode status selain 200)
      else {
        _handleError('Gagal memperbarui profil. Kode status: ${response.statusCode}');
      }
    }
    // Menangani eksepsi yang mungkin terjadi selama proses update
    catch (e) {
      _handleError('Exception: $e');
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      updateProfile();
    }
  }

  void _handleError(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
    });
    print('Error: $errorMessage');
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
        child: Form(
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
                        : _imageUrl.isNotEmpty
                            ? NetworkImage(_imageUrl)
                            : AssetImage('assets/images/person/login.png') as ImageProvider,
                    child: _profileImage == null && _imageUrl.isEmpty
                        ? const Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Date of Birth cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone Number cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Gender cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Address cannot be empty';
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
        ),
      ),
    );
  }
}
