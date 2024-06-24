import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'editProfile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileData = Future.value({});
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail().then((_) {
      setState(() {
        _profileData = _loadUserProfile();
      });
    });
  }

  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userEmail = prefs.getString('user_email');
    });
  }

  Future<Map<String, dynamic>> _loadUserProfile() async {
    if (_userEmail != null) {
      return _fetchProfileData(_userEmail!);
    } else {
      throw Exception('User email not found');
    }
  }

  Future<Map<String, dynamic>> _fetchProfileData(String userEmail) async {
    var url = Uri.parse('http://192.168.100.31/surya4/lib/API/APIperson.php');
    var response = await http.post(url, body: {'email': userEmail});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  void _navigateAndEditProfile(BuildContext context, Map<String, dynamic> profileData) async {
    final updatedProfile = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          name: profileData['nama'] ?? '',
          dob: profileData['tanggalLahir'] ?? '',
          email: profileData['email'] ?? '',
          phone: profileData['noTelp'] ?? '',
          gender: profileData['jenisKelamin'] ?? '',
          address: profileData['alamat'] ?? '',
          imageUrl: profileData['profile_image'] ?? '', initialImageUrl: '',
        ),
      ),
    );

    if (updatedProfile != null) {
      setState(() {
        _profileData = Future.value(updatedProfile);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: _profileData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _navigateAndEditProfile(context, snapshot.data!),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final profileData = snapshot.data!;
            final imageUrl = profileData['profile_image']?.isNotEmpty == true
                ? (profileData['profile_image']!.startsWith('http')
                    ? profileData['profile_image']
                    : 'assets/images/person/${profileData['profile_image']}')
                : 'assets/images/person/login.png';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: imageUrl.startsWith('http')
                        ? NetworkImage(imageUrl)
                        : AssetImage(imageUrl) as ImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Failed to load image: $exception');
                    },
                    child: imageUrl.isEmpty 
                        ? const Icon(Icons.person, size: 50) 
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileDetail('Nama', profileData['nama']),
                _buildProfileDetail('Tanggal Lahir', profileData['tanggalLahir']),
                _buildProfileDetail('Email', _userEmail),
                _buildProfileDetail('Nomor HP', profileData['noTelp']),
                _buildProfileDetail('Jenis Kelamin', profileData['jenisKelamin']),
                _buildProfileDetail('Alamat', profileData['alamat']),
              ],
            );
          } else {
            return const Center(child: Text('No profile data available'));
          }
        },
      ),
    );
  }

  Widget _buildProfileDetail(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
    theme: ThemeData(
      primarySwatch: Colors.lightBlue,
      scaffoldBackgroundColor: Colors.grey[100],
      textTheme: const TextTheme(
        bodyText1: TextStyle(color: Colors.black),
        bodyText2: TextStyle(color: Colors.black54),
      ),
    ),
  ));
}
