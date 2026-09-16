import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../widgets/bottom_nav_bar.dart';
import '../../../../widgets/notification_bell_button.dart';
import '../../../../services/category_service.dart';
import 'provider_list_screen.dart';

class HomeownerHomeScreen extends StatefulWidget {
  const HomeownerHomeScreen({super.key});

  @override
  State<HomeownerHomeScreen> createState() => _HomeownerHomeScreenState();
}

class _HomeownerHomeScreenState extends State<HomeownerHomeScreen> {
  String userName = 'User';
  String searchQuery = '';
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            userName = data['fullName'] ?? data['name'] ?? data['username'] ?? 'User';
          });
        }
      }
    } catch (e) {
      // Ignore error
    }
  }

  // ✅ Premium iOS-Style Color & Soft Interior Gradient Mapping
  Map<String, dynamic> _getCategoryMeta(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('plumbing')) {
      return {"icon": Icons.plumbing_rounded, "tag": "Maintenance", "color": const Color(0xFF38BDF8), "cardGradient": [const Color(0xFF0C2340), const Color(0xFF071325)]};
    } else if (lower.contains('electrical') || lower.contains('electric')) {
      return {"icon": Icons.bolt_rounded, "tag": "Maintenance", "color": const Color(0xFF7DD3FC), "cardGradient": [const Color(0xFF0C2A4A), const Color(0xFF07152A)]};
    } else if (lower.contains('carpentry') || lower.contains('carpenter')) {
      return {"icon": Icons.handyman_rounded, "tag": "Maintenance", "color": const Color(0xFF818CF8), "cardGradient": [const Color(0xFF171E42), const Color(0xFF0B0F24)]};
    } else if (lower.contains('painting') || lower.contains('painter')) {
      return {"icon": Icons.format_paint_rounded, "tag": "Maintenance", "color": const Color(0xFFF472B6), "cardGradient": [const Color(0xFF321431), const Color(0xFF150A1A)]};
    } else if (lower.contains('aircon') || lower.contains('cooling')) {
      return {"icon": Icons.ac_unit_rounded, "tag": "Maintenance", "color": const Color(0xFF22D3EE), "cardGradient": [const Color(0xFF0D2F3F), const Color(0xFF071822)]};
    } else if (lower.contains('cleaning') || lower.contains('house cleaning')) {
      return {"icon": Icons.cleaning_services_rounded, "tag": "Cleaning", "color": const Color(0xFF34D399), "cardGradient": [const Color(0xFF0D3227), const Color(0xFF071A15)]};
    } else if (lower.contains('computer') || lower.contains('laptop') || lower.contains('it')) {
      return {"icon": Icons.computer_rounded, "tag": "Repair", "color": const Color(0xFFA78BFA), "cardGradient": [const Color(0xFF221A46), const Color(0xFF100C24)]};
    } else if (lower.contains('network') || lower.contains('wifi')) {
      return {"icon": Icons.router_rounded, "tag": "Repair", "color": const Color(0xFF60A5FA), "cardGradient": [const Color(0xFF12234A), const Color(0xFF091227)]};
    } else if (lower.contains('appliance')) {
      return {"icon": Icons.kitchen_rounded, "tag": "Repair", "color": const Color(0xFFFBBF24), "cardGradient": [const Color(0xFF362612), const Color(0xFF1B1308)]};
    }
    return {"icon": Icons.home_repair_service_rounded, "tag": "Maintenance", "color": const Color(0xFF38BDF8), "cardGradient": [const Color(0xFF0C2340), const Color(0xFF071325)]};
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Maintenance', 'Repair', 'Cleaning'];

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF020408),
                  Color(0xFF061021),
                  Color(0xFF0B192C),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- COMPACT EXECUTIVE HEADER ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.07),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF38BDF8),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'RESIDENT PORTAL',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF38BDF8),
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                userName,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const NotificationBellButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- SEARCH BAR ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 16),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            onChanged: (val) => setState(() => searchQuery = val),
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Search service, category, provider...',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.3),
                                fontSize: 11,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // --- FILTER CHIPS ---
                  SizedBox(
                    height: 32,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() => selectedFilter = filter),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0284C7)
                                    : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF38BDF8)
                                      : Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Text(
                                filter,
                                style: GoogleFonts.poppins(
                                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- CATEGORIES GRID (iOS GLASSMORPHISM STYLE) ---
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: CategoryService().streamCategories(),
                      builder: (context, categorySnapshot) {
                        final categoryDocs = categorySnapshot.data?.docs ?? [];

                        final fallbackDefaults = [
                          {"title": "Plumbing", "desc": "Leaks & pipes", "tag": "Maintenance"},
                          {"title": "Electrical Work", "desc": "Wiring & lighting", "tag": "Maintenance"},
                          {"title": "Carpentry", "desc": "Woodwork & framing", "tag": "Maintenance"},
                          {"title": "House Cleaning", "desc": "Sanitation & chores", "tag": "Cleaning"},
                          {"title": "Painting", "desc": "Walls & touch-ups", "tag": "Maintenance"},
                          {"title": "Appliance Repair", "desc": "Kitchen appliances", "tag": "Repair"},
                        ];

                        final baseDefaults = categoryDocs.isNotEmpty
                            ? categoryDocs.map((doc) {
                                final data = doc.data();
                                return {
                                  'title': (data['title'] ?? '').toString(),
                                  'desc': (data['description'] ?? '').toString(),
                                  'tag': (data['tag'] ?? 'Maintenance').toString(),
                                };
                              }).toList()
                            : fallbackDefaults;

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('providers')
                              .where('verificationStatus', isEqualTo: 'approved')
                              .snapshots(),
                          builder: (context, snapshot) {
                            final docs = snapshot.hasData ? snapshot.data!.docs : [];
                            final Map<String, Map<String, dynamic>> dynamicCategories = {};

                            for (var d in baseDefaults) {
                              dynamicCategories[d['title']!] = d;
                            }

                            for (var doc in docs) {
                              final data = doc.data() as Map<String, dynamic>;
                              final serviceTitle = data['service'] ?? data['serviceCategory'];
                              if (serviceTitle != null && serviceTitle.toString().trim().isNotEmpty) {
                                final meta = _getCategoryMeta(serviceTitle);
                                dynamicCategories[serviceTitle] = {
                                  "title": serviceTitle,
                                  "desc": data['experience'] ?? 'Verified professional',
                                  "tag": meta['tag'],
                                };
                              }
                            }

                            final categoriesList = dynamicCategories.values.toList();
                            final filteredCategories = categoriesList.where((cat) {
                              final title = cat['title'].toString().toLowerCase();
                              final desc = cat['desc'].toString().toLowerCase();
                              final tag = cat['tag'].toString();
                              final query = searchQuery.toLowerCase();

                              final matchesQuery = title.contains(query) || desc.contains(query);
                              final matchesFilter = selectedFilter == 'All' || tag == selectedFilter;

                              return matchesQuery && matchesFilter;
                            }).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Service Categories',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${filteredCategories.length} available',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF38BDF8),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: filteredCategories.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.55,
                                    ),
                                    itemBuilder: (context, index) {
                                      final cat = filteredCategories[index];
                                      final meta = _getCategoryMeta(cat['title']);
                                      final Color accentColor = meta['color'];
                                      final List<Color> cardGradient = meta['cardGradient'];

                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          // ✅ Soft Interior Gradient + Subtle Glowing Shadow
                                          gradient: LinearGradient(
                                            colors: cardGradient,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          border: Border.all(
                                            color: accentColor.withValues(alpha: 0.25),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: accentColor.withValues(alpha: 0.08),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(16),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ProviderListScreen(
                                                    categoryTitle: cat['title'] as String,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(6),
                                                        decoration: BoxDecoration(
                                                          color: accentColor.withValues(alpha: 0.15),
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        child: Icon(
                                                          meta['icon'],
                                                          color: accentColor,
                                                          size: 18,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios_rounded,
                                                        color: Colors.white.withValues(alpha: 0.3),
                                                        size: 10,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        cat['title'],
                                                        style: GoogleFonts.poppins(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 1),
                                                      Text(
                                                        cat['desc'],
                                                        style: GoogleFonts.poppins(
                                                          color: Colors.white.withValues(alpha: 0.4),
                                                          fontSize: 9,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}