import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/booking_model.dart';
import '../../services/provider_schedule_service.dart';
import '../../widgets/rate_review_widgets.dart';

/// Shows a provider's FULL, all-time job history (completed + cancelled),
/// each with the homeowner's rating and comment if one was given. Unlike
/// "My Schedule" (which only shows the current month's completed jobs),
/// this screen is the permanent record.
class ProviderJobHistoryScreen extends StatelessWidget {
  const ProviderJobHistoryScreen({super.key});

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final providerId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF020408),
      appBar: AppBar(
        backgroundColor: const Color(0xFF061021),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Job History & Ratings & Feedback',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: StreamBuilder<List<BookingModel>>(
            stream: ProviderScheduleService().getProviderBookings(providerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                );
              }

              final all = snapshot.data ?? [];
              final history = all
                  .where((b) =>
                      b.status == 'completed' ||
                      b.status == 'cancelled' ||
                      b.status == 'rejected')
                  .toList()
                ..sort((a, b) {
                  final aDate = a.completedAt ?? a.updatedAt;
                  final bDate = b.completedAt ?? b.updatedAt;
                  return bDate.compareTo(aDate); // newest first
                });

              if (history.isEmpty) {
                return Center(
                  child: Text(
                    'No completed or cancelled jobs yet.',
                    style: GoogleFonts.poppins(
                        color: Colors.white38, fontSize: 13),
                  ),
                );
              }

              final completedCount =
                  history.where((b) => b.status == 'completed').length;

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: history.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '$completedCount completed \u2022 ${history.length - completedCount} cancelled/rejected',
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 12),
                      ),
                    );
                  }

                  final booking = history[index - 1];
                  final isCompleted = booking.status == 'completed';
                  final statusColor =
                      isCompleted ? const Color(0xFF10B981) : Colors.redAccent;
                  final displayDate = booking.completedAt ?? booking.updatedAt;

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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                booking.service,
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
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isCompleted ? 'COMPLETED' : booking.status.toUpperCase(),
                                style: GoogleFonts.poppins(
                                    color: statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Client: ${booking.homeownerName}  \u2022  ${_formatDate(displayDate)}',
                          style: GoogleFonts.poppins(
                              color: Colors.white54, fontSize: 11),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(height: 10),
                          if (booking.rated && booking.ratingGiven != null) ...[
                            Row(
                              children: [
                                StarRatingDisplay(
                                    rating: booking.ratingGiven!.toDouble(),
                                    size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  '${booking.ratingGiven}/5',
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFFF59E0B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            if ((booking.ratingComment ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${booking.ratingComment}"',
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ] else
                            Text(
                              'Not yet rated by the homeowner.',
                              style: GoogleFonts.poppins(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic),
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