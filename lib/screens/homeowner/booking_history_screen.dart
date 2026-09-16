import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/rate_review_widgets.dart';

/// Shows a homeowner's FULL, all-time booking history across every
/// status, including the rating they gave for completed jobs. Unlike
/// "My Bookings" (which only shows the current month's completed
/// bookings), this screen is the permanent record.
class HomeownerBookingHistoryScreen extends StatelessWidget {
  const HomeownerBookingHistoryScreen({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'accepted':
        return const Color(0xFF10B981);
      case 'completed':
        return const Color(0xFF38BDF8);
      case 'rejected':
      case 'cancelled':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061021),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Booking History',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: user == null
              ? const SizedBox.shrink()
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('bookings')
                      .where('homeownerId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF38BDF8)),
                      );
                    }

                    final docs = (snapshot.data?.docs ?? []).toList()
                      ..sort((a, b) {
                        final aData = a.data();
                        final bData = b.data();
                        DateTime pick(Map<String, dynamic> d) {
                          final ts = d['completedAt'] ?? d['updatedAt'] ?? d['createdAt'];
                          return ts is Timestamp
                              ? ts.toDate()
                              : DateTime.fromMillisecondsSinceEpoch(0);
                        }
                        return pick(bData).compareTo(pick(aData));
                      });

                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No bookings yet.',
                          style: GoogleFonts.poppins(
                              color: Colors.white38, fontSize: 13),
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();
                        final bookingId = doc.id;
                        final service =
                            (data['service'] ?? 'Service').toString();
                        final providerId =
                            (data['providerId'] ?? '').toString();
                        final providerName =
                            (data['providerName'] ?? 'Provider').toString();
                        final status =
                            (data['status'] ?? 'pending').toString();
                        final isCompleted = status.toLowerCase() == 'completed';
                        final isRated = data['rated'] == true;
                        final ratingGiven = data['ratingGiven'];
                        final ratingComment =
                            (data['ratingComment'] ?? '').toString();
                        final ts = data['completedAt'] ??
                            data['updatedAt'] ??
                            data['createdAt'];
                        final displayDate = ts is Timestamp
                            ? _formatDate(ts.toDate())
                            : '';
                        final color = _statusColor(status);

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      service,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                          color: color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Provider: $providerName  \u2022  $displayDate',
                                style: GoogleFonts.poppins(
                                    color: Colors.white54, fontSize: 11),
                              ),
                              if (isCompleted) ...[
                                const SizedBox(height: 10),
                                if (isRated && ratingGiven != null) ...[
                                  Row(
                                    children: [
                                      StarRatingDisplay(
                                          rating: (ratingGiven as num)
                                              .toDouble(),
                                          size: 14),
                                      const SizedBox(width: 6),
                                      Text('$ratingGiven/5',
                                          style: GoogleFonts.poppins(
                                              color: const Color(0xFFF59E0B),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  if (ratingComment.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text('"$ratingComment"',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white70,
                                            fontSize: 12)),
                                  ],
                                ] else
                                  SizedBox(
                                    width: double.infinity,
                                    height: 34,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        showRateReviewDialog(
                                          context: context,
                                          bookingId: bookingId,
                                          homeownerId: user.uid,
                                          homeownerName:
                                              user.displayName ?? 'Homeowner',
                                          providerId: providerId,
                                          providerName: providerName,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFFF59E0B)),
                                        foregroundColor:
                                            const Color(0xFFF59E0B),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      icon: const Icon(Icons.star_rounded,
                                          size: 14),
                                      label: Text('Rate this Service',
                                          style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}