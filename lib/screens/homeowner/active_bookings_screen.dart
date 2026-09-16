import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../chat/chat_screen.dart';
import 'booking_progress_screen.dart';

class ActiveBookingsScreen extends StatelessWidget {
  const ActiveBookingsScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'accepted':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF38BDF8);
      case 'cancelled':
        return Colors.white54;
      default:
        return Colors.white70;
    }
  }


  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.outfit(
          color: const Color(0xFF38BDF8),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF020408),
        body: Center(
          child: Text(
            'No logged-in user found.',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 1,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020408),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Bookings',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('homeownerId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              final allDocs = snapshot.data?.docs ?? [];
              if (allDocs.length > 5) {
                return TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullBookingsHistoryScreen(userId: user.uid),
                      ),
                    );
                  },
                  child: Text(
                    'See All (${allDocs.length})',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.white.withValues(alpha: 0.08),
            height: 1,
          ),
        ),
      ),
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
                  Text(
                    'Track your active appointments and service history',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('homeownerId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF38BDF8),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${snapshot.error}',
                              style: GoogleFonts.poppins(color: Colors.redAccent),
                            ),
                          );
                        }

                        final allDocs = snapshot.data?.docs ?? [];
                        final now = DateTime.now();

                        final docs = allDocs.where((doc) {
                          final data = doc.data();
                          final status =
                              (data['status'] ?? 'pending').toString().toLowerCase();

                          if (status == 'completed' ||
                              status == 'rejected' ||
                              status == 'cancelled') {
                            final completedTs = data['completedAt'];
                            final updatedTs = data['updatedAt'];
                            DateTime? finishedAt;
                            if (completedTs is Timestamp) {
                              finishedAt = completedTs.toDate();
                            } else if (updatedTs is Timestamp) {
                              finishedAt = updatedTs.toDate();
                            }
                            if (finishedAt == null) return true;
                            return finishedAt.year == now.year &&
                                finishedAt.month == now.month;
                          }
                          return true;
                        }).toList();

                        if (docs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.03),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.06),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Color(0xFF38BDF8),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No bookings found.',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final sortedBookings = docs.toList()
                          ..sort((a, b) {
                            final aData = a.data();
                            final bData = b.data();
                            final aTimestamp = aData['selectedDate'];
                            final bTimestamp = bData['selectedDate'];

                            DateTime aDate = DateTime.fromMillisecondsSinceEpoch(0);
                            DateTime bDate = DateTime.fromMillisecondsSinceEpoch(0);

                            if (aTimestamp is Timestamp) aDate = aTimestamp.toDate();
                            if (bTimestamp is Timestamp) bDate = bTimestamp.toDate();
                            return bDate.compareTo(aDate);
                          });

                        final recentBookings = sortedBookings.take(5).toList();

                        return ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentBookings.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final bookingDoc = recentBookings[index];
                            final booking = bookingDoc.data();
                            final String bookingId = bookingDoc.id;

                            final String providerId = (booking['providerId'] ?? '').toString();
                            final String providerName = (booking['providerName'] ?? 'Unknown Provider').toString();
                            final String service = (booking['service'] ?? 'Unknown Service').toString();
                            final String date = (booking['bookingDate'] ?? 'No Date').toString();
                            final String time = (booking['bookingTime'] ?? 'No Time').toString();
                            final String status = (booking['status'] ?? 'pending').toString();
                            final String? providerProfilePic = booking['providerProfilePic'] ?? booking['providerImageUrl'];

                            final Color statusColor = _getStatusColor(status);

                            return BookingCardItem(
                              bookingId: bookingId,
                              providerId: providerId,
                              providerName: providerName,
                              service: service,
                              date: date,
                              time: time,
                              status: status,
                              statusColor: statusColor,
                              providerProfilePic: providerProfilePic,
                              buildAvatarFallback: _buildAvatarFallback,
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

// Reusable Consistent Booking Card Widget
class BookingCardItem extends StatelessWidget {
  final String bookingId;
  final String providerId;
  final String providerName;
  final String service;
  final String date;
  final String time;
  final String status;
  final Color statusColor;
  final String? providerProfilePic;
  final Widget Function(String) buildAvatarFallback;

  const BookingCardItem({
    super.key,
    required this.bookingId,
    required this.providerId,
    required this.providerName,
    required this.service,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
    required this.providerProfilePic,
    required this.buildAvatarFallback,
  });

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'PENDING';
      case 'accepted': return 'ACCEPTED';
      case 'rejected': return 'REJECTED';
      case 'completed': return 'COMPLETED';
      case 'cancelled': return 'CANCELLED';
      default: return 'UNKNOWN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C2340), Color(0xFF071325)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 42,
                  height: 42,
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.15),
                  child: providerProfilePic != null && providerProfilePic!.isNotEmpty && !providerProfilePic!.startsWith('demo')
                      ? Image.network(
                          providerProfilePic!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => buildAvatarFallback(providerName),
                        )
                      : buildAvatarFallback(providerName),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      providerName,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      service,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF38BDF8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getStatusLabel(status),
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 11, color: Colors.white54),
              const SizedBox(width: 4),
              Text(date, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_outlined, size: 11, color: Colors.white54),
              const SizedBox(width: 4),
              Text(time, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingProgressScreen(
                            bookingId: bookingId,
                            providerId: providerId,
                            providerName: providerName,
                            service: service,
                            status: status,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.white.withValues(alpha: 0.02),
                    ),
                    child: Text('Details', style: GoogleFonts.poppins(color: Colors.white, fontSize: 11)),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            otherUserId: providerId,
                            otherUserName: providerName,
                            bookingId: bookingId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Message', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ✅ Consistent "See All" History Screen na may parehong design card
class FullBookingsHistoryScreen extends StatelessWidget {
  final String userId;

  const FullBookingsHistoryScreen({super.key, required this.userId});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'accepted': return const Color(0xFF10B981);
      case 'rejected': return const Color(0xFFEF4444);
      case 'completed': return const Color(0xFF38BDF8);
      case 'cancelled': return Colors.white54;
      default: return Colors.white70;
    }
  }


  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.outfit(
          color: const Color(0xFF38BDF8),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      appBar: AppBar(
        backgroundColor: const Color(0xFF020408),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'All Bookings History',
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('homeownerId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
                }
                final bookings = snapshot.data?.docs ?? [];
                if (bookings.isEmpty) {
                  return Center(
                    child: Text(
                      'No booking history found.',
                      style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
                    ),
                  );
                }
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  itemCount: bookings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bookingDoc = bookings[index];
                    final booking = bookingDoc.data();
                    final String bookingId = bookingDoc.id;

                    final String providerId = (booking['providerId'] ?? '').toString();
                    final String providerName = (booking['providerName'] ?? 'Unknown Provider').toString();
                    final String service = (booking['service'] ?? 'Unknown Service').toString();
                    final String date = (booking['bookingDate'] ?? 'No Date').toString();
                    final String time = (booking['bookingTime'] ?? 'No Time').toString();
                    final String status = (booking['status'] ?? 'pending').toString();
                    final String? providerProfilePic = booking['providerProfilePic'] ?? booking['providerImageUrl'];

                    final Color statusColor = _getStatusColor(status);

                    return BookingCardItem(
                      bookingId: bookingId,
                      providerId: providerId,
                      providerName: providerName,
                      service: service,
                      date: date,
                      time: time,
                      status: status,
                      statusColor: statusColor,
                      providerProfilePic: providerProfilePic,
                      buildAvatarFallback: _buildAvatarFallback,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}