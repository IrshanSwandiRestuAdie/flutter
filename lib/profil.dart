// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert'; 
import 'package:app_uas/login_register_page.dart';
import 'package:app_uas/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser ;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 40,
                    child: CircularProgressIndicator(),
                  );
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final profileImage = data?['profileImage'];
                final photoUrl = user?.photoURL;

              
                print('Profile Image URL: $profileImage');
                print('User  Photo URL: $photoUrl');

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: (profileImage != null && profileImage.isNotEmpty)
                          ? (profileImage.startsWith('data:image/')
                              ? MemoryImage(base64Decode(profileImage.split(',').last)) 
                              : NetworkImage(profileImage))
                          : (photoUrl != null ? NetworkImage(photoUrl) : null),
                      child: (profileImage == null && photoUrl == null)
                          ? const Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (data?['username'] as String?) ?? user?.displayName ?? 'User  ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'user@example.com',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Pengaturan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              icon: Icons.settings,
              label: 'Ubah Profil',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.exit_to_app,
              label: 'Logout',
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }
}