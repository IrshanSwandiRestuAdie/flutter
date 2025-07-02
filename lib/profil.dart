// ignore_for_file: use_build_context_synchronously
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html; // For web-specific functionality
import 'package:app_uas/login_register_page.dart';
import 'package:app_uas/settings_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<String> _blobToDataUrl(String blobUrl) async {
    try {
      final response = await html.HttpRequest.request(blobUrl, responseType: 'blob');
      final blob = response.response;
      final completer = Completer<String>();
      final reader = html.FileReader();
      reader.onLoadEnd.listen((e) {
        completer.complete(reader.result as String);
      });
      reader.readAsDataUrl(blob as html.Blob);
      return await completer.future;
    } catch (e) {
      debugPrint('Error converting blob to data URL: $e');
      return '';
    }
  }

  Stream<Widget> _buildProfileImage(dynamic imageSource) async* {
    final defaultWidget = const Icon(Icons.person, size: 40, color: Colors.grey);

    if (imageSource == null) {
      yield defaultWidget;
      return;
    }

    if (kIsWeb && imageSource.toString().startsWith('blob:')) {
      try {
        final dataUrl = await _blobToDataUrl(imageSource);
        yield dataUrl.isNotEmpty
            ? Image.network(
                dataUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => defaultWidget,
              )
            : defaultWidget;
        return;
      } catch (e) {
        debugPrint('Error loading blob image: $e');
        yield defaultWidget;
        return;
      }
    } else if (imageSource.toString().startsWith('http') || 
               imageSource.toString().startsWith('data:')) {
      yield Image.network(
        imageSource.toString(),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => defaultWidget,
      );
      return;
    }

    yield defaultWidget;
    return;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      child: ClipOval(
                        child: FutureBuilder<String?>(
                          future: kIsWeb && (profileImage?.startsWith('blob:') ?? false)
                              ? _blobToDataUrl(profileImage!)
                              : Future.value(profileImage ?? photoUrl),
                          builder: (context, asyncSnapshot) {
                            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            return StreamBuilder<Widget>(
                              stream: _buildProfileImage(asyncSnapshot.data ?? photoUrl),
                              builder: (context, imageSnapshot) {
                                if (imageSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                return imageSnapshot.data ??
                                    const Icon(Icons.person, size: 40, color: Colors.grey);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        (data?['username'] as String?) ?? user?.displayName ?? 'User',
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




