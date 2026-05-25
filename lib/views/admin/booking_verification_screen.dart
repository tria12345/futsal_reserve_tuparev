// lib/views/admin/booking_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';

class BookingVerificationScreen extends StatefulWidget {
  const BookingVerificationScreen({super.key});

  @override
  State<BookingVerificationScreen> createState() => _BookingVerificationScreenState();
}

class _BookingVerificationScreenState extends State<BookingVerificationScreen> {
  int _selectedVerificationTab = 0; // 0: Verify Receipt Payments, 1: Process Check-Ins

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookings();
    });
  }

  void _showReceiptReviewDialog(BuildContext context, dynamic booking, BookingProvider bookingProv) {
    // Correct URL mapping
    final String fullReceiptUrl = "${AppConfig.uploadsUrl}${booking.paymentReceipt}";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          surfaceTintColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Tinjau Bukti Transfer: ${booking.teamName}",
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Receipts metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Harga", style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  Text("Rp ${booking.totalPrice.toInt()}", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              
              // Receipt image frame
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 280,
                  width: double.maxFinite,
                  color: Colors.black.withValues(alpha: 0.05),
                  child: Image.network(
                    fullReceiptUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.broken_image_rounded, color: AppTheme.accent, size: 48),
                          const SizedBox(height: 8),
                          const Text("Memuat...", style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                          const Text("(Simulated payment transfer proof)", style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Verifikasi kecocokan nilai transfer dengan harga sewa sebelum mengambil tindakan.",
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            // Reject Button
            TextButton(
              onPressed: () async {
                final success = await bookingProv.verifyBooking(booking.id, 'rejected');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? "Booking transaction rejected." : "Verification failed."),
                      backgroundColor: AppTheme.accent,
                    ),
                  );
                }
              },
              child: const Text("TOLAK", style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
            ),
            
            // Approve Button
            ElevatedButton(
              onPressed: () async {
                final success = await bookingProv.verifyBooking(booking.id, 'approved');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? "Booking transaction approved & finalized!" : "Verification failed."),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text("SETUJUI"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProv = context.watch<BookingProvider>();

    // Dynamic Lists based on statuses
    final pendingBookings = bookingProv.bookings.where((b) => b.paymentStatus == 'pending').toList();
    final approvedBookings = bookingProv.bookings.where((b) => b.paymentStatus == 'approved').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meja Verifikasi"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 768),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedVerificationTab = 0),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedVerificationTab == 0 ? AppTheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Verifikasi Pembayaran (${pendingBookings.length})",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedVerificationTab == 0 ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedVerificationTab = 1),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedVerificationTab == 1 ? AppTheme.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Kehadiran Lapangan (${approvedBookings.where((b) => !b.checkedIn).length})",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedVerificationTab == 1 ? Colors.white : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.background),
        child: RefreshIndicator(
          onRefresh: () => bookingProv.fetchBookings(),
          color: AppTheme.primary,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: bookingProv.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : _selectedVerificationTab == 0
                      ? _buildPaymentTab(pendingBookings, bookingProv)
                      : _buildCheckInTab(approvedBookings, bookingProv),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTab(List<dynamic> pendingList, BookingProvider bookingProv) {
    if (pendingList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_rounded, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              "Tidak ada pembayaran tertunda yang menunggu verifikasi.", 
              style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: pendingList.length,
      itemBuilder: (context, index) {
        final booking = pendingList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.orange),
              ),
              title: Text(
                "${booking.fieldName} - ${booking.teamName}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  "User: ${booking.userName ?? 'Player'}\nDate: ${booking.bookDate} | Time: ${booking.timeSlotString}",
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                ),
              ),
              trailing: ElevatedButton(
                onPressed: () => _showReceiptReviewDialog(context, booking, bookingProv),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("TINJAU", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckInTab(List<dynamic> approvedList, BookingProvider bookingProv) {
    // Filter out already checked-in teams
    final activeCheckins = approvedList.where((b) => !b.checkedIn).toList();
    final completedCheckins = approvedList.where((b) => b.checkedIn).toList();

    if (activeCheckins.isEmpty && completedCheckins.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy_rounded, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(
              "Tidak ada pemesanan disetujui untuk check-in hari ini.", 
              style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (activeCheckins.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              "MENUNGGU KEDATANGAN",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.0),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeCheckins.length,
            itemBuilder: (context, index) {
              final booking = activeCheckins[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200, width: 0.8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGlow,
                      child: const Icon(Icons.sports_soccer_rounded, color: AppTheme.primary),
                    ),
                    title: Text(
                      "${booking.fieldName} - ${booking.teamName}",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Phone: ${booking.phoneNumber}\nSlot: ${booking.timeSlotString}",
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                      ),
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () async {
                        final success = await bookingProv.checkInBooking(booking.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(success ? "${booking.teamName} Checked In Successfully!" : "Check-in failed."),
                              backgroundColor: success ? AppTheme.primary : AppTheme.accent,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_rounded, size: 14),
                      label: const Text("MASUK", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],

        if (completedCheckins.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              "PERTANDINGAN SELESAI (HARI INI)",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.0),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: completedCheckins.length,
            itemBuilder: (context, index) {
              final booking = completedCheckins[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200, width: 0.8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.done_all_rounded, color: Colors.grey),
                    ),
                    title: Text(
                      "${booking.fieldName} - ${booking.teamName}",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Sudah hadir & selesai. Pertandingan aktif/selesai.",
                        style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}
