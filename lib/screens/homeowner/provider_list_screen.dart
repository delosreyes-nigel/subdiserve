import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'create_booking_screen.dart';

import '../chat/chat_screen.dart';


class ProviderListScreen extends StatefulWidget {
  final String categoryTitle;

  const ProviderListScreen({
    super.key,
    required this.categoryTitle,
  });

  @override
  State<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends State<ProviderListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getDisplayName(Map<String, dynamic> data) {
    final name = (data['name'] ?? data['fullName'] ?? '').toString().trim();
    if (name.isNotEmpty) return name;
    return 'Unnamed Provider';
  }

  String getServiceCategory(Map<String, dynamic> data) {
    final category = (data['service'] ??
            data['serviceCategory'] ??
            data['category'] ??
            '')
        .toString()
        .trim();
    if (category.isNotEmpty) return category;
    return 'General Service';
  }

  String getEmail(Map<String, dynamic> data) {
    final email = (data['email'] ?? '').toString().trim();
    if (email.isNotEmpty) return email;
    return 'No email available';
  }

  bool matchesCategory(String providerCategory, String selectedCategory) {
    final providerValue = providerCategory.toLowerCase().trim();
    final selectedValue = selectedCategory.toLowerCase().trim();

    if (providerValue == selectedValue) return true;
    if (selectedValue == 'plumbing' && providerValue.contains('plumb')) return true;
    if (selectedValue == 'electrical work' && (providerValue.contains('electrical') || providerValue.contains('electrician'))) return true;
    if (selectedValue == 'house cleaning' && providerValue.contains('clean')) return true;
    if (selectedValue == 'aircon maintenance' && providerValue.contains('aircon')) return true;
    if (selectedValue == 'appliance repair' && providerValue.contains('appliance')) return true;

    return false;
  }

  // ✅ Marketplace Profile Modal
  void _showProviderMarketplaceModal(
    BuildContext context, {
    required String providerId,
    required String providerName,
    required String providerCategory,
    required String email,
    required double avgRating,
    required int ratingCount,
    required String? imageUrl,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0B192C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Modal Profile Picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                    child: imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('demo')
                        ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildAvatarFallback(providerName))
                        : _buildAvatarFallback(providerName),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          providerCategory,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF38BDF8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white12),
            const SizedBox(height: 12),
            Text(
              'Provider Details & Contact',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email_outlined, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(email, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 6),
                Text(
                  ratingCount > 0 ? '${avgRating.toStringAsFixed(1)} Rating ($ratingCount reviews)' : 'No ratings yet',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: providerId,
                            otherUserName: providerName,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                    label: Text('Chat Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF38BDF8),
                      side: const BorderSide(color: Color(0xFF38BDF8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateBookingScreen(
                            providerId: providerId,
                            providerName: providerName,
                            providerCategory: providerCategory,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text('Book Service', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.outfit(
          color: const Color(0xFF38BDF8),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providersStream = FirebaseFirestore.instance.collection('providers').snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020408),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.categoryTitle,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.white.withValues(alpha: 0.08), height: 1),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF020408), Color(0xFF061021), Color(0xFF0B192C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search marketplace provider...',
                      hintStyle: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.3), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.white.withValues(alpha: 0.4)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.03),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: providersStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
                      }

                      final allDocs = snapshot.data?.docs ?? [];
                      final currentUid = FirebaseAuth.instance.currentUser?.uid;

                      final filteredDocs = allDocs.where((doc) {
                        if (currentUid != null && doc.id == currentUid) return false;
                        final data = doc.data();
                        final serviceCategory = getServiceCategory(data);
                        final name = getDisplayName(data).toLowerCase();

                        return matchesCategory(serviceCategory, widget.categoryTitle) && name.contains(_searchQuery);
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return Center(
                          child: Text(
                            'No marketplace listings found for "${widget.categoryTitle}".',
                            style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
                          ),
                        );
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        itemCount: filteredDocs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data();

                          final providerId = doc.id;
                          final providerName = getDisplayName(data);
                          final providerCategory = getServiceCategory(data);
                          final email = getEmail(data);
                          final double avgRating = ((data['averageRating'] ?? 0) as num).toDouble();
                          final int ratingCount = (data['ratingCount'] ?? 0) as int;
                          
                          // ✅ Kunin ang Profile/Selfie Image URL mula sa database kung meron
                          final String? profileImgUrl = data['selfieUrl'] ?? data['profileImageUrl'] ?? data['validIdUrl'];

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => _showProviderMarketplaceModal(
                                  context,
                                  providerId: providerId,
                                  providerName: providerName,
                                  providerCategory: providerCategory,
                                  email: email,
                                  avgRating: avgRating,
                                  ratingCount: ratingCount,
                                  imageUrl: profileImgUrl,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // ✅ Profile Picture Avatar (Marketplace Style)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                                            border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: profileImgUrl != null && profileImgUrl.isNotEmpty && !profileImgUrl.startsWith('demo')
                                              ? Image.network(profileImgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildAvatarFallback(providerName))
                                              : _buildAvatarFallback(providerName),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              providerName,
                                              style: GoogleFonts.outfit(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              providerCategory,
                                              style: GoogleFonts.poppins(color: const Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Tap to view details & chat',
                                              style: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 💬 Direct Quick Chat Button
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ChatScreen(
                                                otherUserId: providerId,
                                                otherUserName: providerName,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF38BDF8), size: 20),
                                        style: IconButton.styleFrom(
                                          backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.15),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}