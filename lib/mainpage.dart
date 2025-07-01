// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:app_uas/cart_page.dart';
import 'package:app_uas/detail_produk.dart';
import 'package:app_uas/login_register_page.dart';
import 'package:app_uas/profil.dart';
import 'package:app_uas/provider/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductListingPage extends StatelessWidget {
  const ProductListingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // ignore: unused_local_variable
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Rexus Official Store'),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable:
                Provider.of<Cart>(context, listen: false).itemCountNotifier,
            builder: (context, itemCount, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartPage(),
                        ),
                      );
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => _profilePopup(context),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child:
                    user?.photoURL != null
                        ? ClipOval(
                          child: Image.network(
                            user!.photoURL!,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        )
                        : Icon(
                          Icons.person_sharp,
                          size: 20,
                          color: Colors.grey[600],
                        ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[700]!),
                ),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final product = Product.fromDocument(
                  snapshot.data!.docs[index],
                );
                return ProductCard(product: product);
              },
            );
          },
        ),
      ),
    );
  }

  void _profilePopup(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(top: kToolbarHeight + 8, right: 16),
          child: Align(
            alignment: Alignment.topRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: screenSize.width * 0.7,
                constraints: BoxConstraints(
                  maxWidth: 280,
                  maxHeight: screenSize.height * 0.6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.08),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[200],
                            child:
                                user?.photoURL != null
                                    ? ClipOval(
                                      child: Image.network(
                                        user!.photoURL!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.grey[500],
                                    ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<DocumentSnapshot>(
                                  future:
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user?.uid)
                                          .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return Text(
                                        user?.displayName ?? 'User',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      );
                                    }
                                    final data =
                                        snapshot.data!.data()
                                            as Map<String, dynamic>;
                                    return Text(
                                      data['username'] ??
                                          user?.displayName ??
                                          'User',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? 'user@example.com',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          _buildPopupMenuItem(
                            context,
                            icon: Icons.account_circle_outlined,
                            label: 'Kelola akun Anda',
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                ),
                          ),

                          const Divider(height: 1),
                          _buildPopupMenuItem(
                            context,
                            icon: Icons.exit_to_app,
                            label: 'Sign out',
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[100],
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported, size: 40),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${product.price.toStringAsFixed(3)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () {
                        Provider.of<Cart>(
                          context,
                          listen: false,
                        ).addItem(product);
                      },
                      child: const Center(
                        child: Text(
                          'Tambah ke Keranjang',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
