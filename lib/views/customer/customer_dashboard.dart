// lib/views/customer/customer_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'court_detail_screen.dart';

class CustomerDashboard extends StatefulWidget {
  final int initialTab;
  const CustomerDashboard({super.key, this.initialTab = 0});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  late DateTime _selectedDate;
  late int _activeTab; // 0: Booking Lobby, 1: Booking History

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _activeTab = widget.initialTab;
    
    // Fetch courts and history on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FieldProvider>().fetchFields(isCustomer: true);
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        context.read<BookingProvider>().fetchBookings(userId: user.id);
      }
    });
  }

  String _formatDateString(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fieldProv = context.watch<FieldProvider>();
    final bookingProv = context.watch<BookingProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Futsal Reserve Tuparev",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Keluar",
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
          // User greeting banner (Clean, professional look)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      user.avatar ?? "https://api.dicebear.com/7.x/adventurer/svg?seed=${user.name}",
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Halo, ${user.name}!",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        "Siap menaklukkan lapangan hari ini?",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Buttons (Beautiful commercial segmented selector)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeTab == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: const Text(
                        "Sewa Lapangan",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() => _activeTab = 1);
                      bookingProv.fetchBookings(userId: user.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeTab == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: const Text(
                        "Riwayat Sewa Saya",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Display Active Tab
          Expanded(
            child: _activeTab == 0
                ? _buildLobbyTab(fieldProv)
                : _buildHistoryTab(bookingProv),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildLobbyTab(FieldProvider fieldProv) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal calendar picker
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Pilih Tanggal",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 74,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 14, // Next 2 weeks
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;

              final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  width: 58,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade200,
                    ),
                    boxShadow: isSelected ? AppTheme.softShadow() : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekday,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white70 : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Lapangan Futsal Tersedia",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: fieldProv.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : fieldProv.errorMessage != null
                  ? Center(child: Text(fieldProv.errorMessage!, style: const TextStyle(color: AppTheme.accent)))
                  : fieldProv.fields.isEmpty
                      ? const Center(
                          child: Text(
                            "Tidak ada lapangan aktif tersedia.",
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: fieldProv.fields.length,
                          itemBuilder: (context, index) {
                            final court = fieldProv.fields[index];
                            
                            // Skip maintenance fields
                            if (court.isMaintenance) return const SizedBox.shrink();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade200, width: 0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CourtDetailScreen(
                                          field: court,
                                          selectedDate: _formatDateString(_selectedDate),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Image.network(
                                        court.imageUrl ?? "https://images.unsplash.com/photo-1577223625856-74552436858d?q=80&w=600",
                                        height: 140,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Container(
                                          height: 140,
                                          color: Colors.grey.shade100,
                                          child: const Icon(Icons.sports_soccer, size: 48, color: Colors.grey),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    court.name,
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${_getFieldSpecs(court.name)['floor']} • ${_getFieldSpecs(court.name)['position']}",
                                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryGlow,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
                                              ),
                                              child: const Text(
                                                "Rp 65k - 160k",
                                                style: TextStyle(
                                                  color: AppTheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(BookingProvider bookingProv) {
    return RefreshIndicator(
      onRefresh: () async {
        final user = context.read<AuthProvider>().currentUser;
        if (user != null) {
          await bookingProv.fetchBookings(userId: user.id);
        }
      },
      color: AppTheme.primary,
      child: bookingProv.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : bookingProv.bookings.isEmpty
              ? const Center(
                  child: Text(
                    "Anda belum melakukan penyewaan.",
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: bookingProv.bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookingProv.bookings[index];

                    Color statusColor = Colors.orange;
                    if (booking.paymentStatus == 'approved') statusColor = AppTheme.primary;
                    if (booking.paymentStatus == 'rejected') statusColor = AppTheme.accent;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200, width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.sports_soccer, color: AppTheme.primary, size: 26),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.fieldName ?? "Lapangan Futsal",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Tanggal Pemesanan: ${booking.bookDate}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                  Text(
                                    "Waktu Sewa: ${booking.timeSlotString}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Nama Tim: ${booking.teamName}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Rp ${booking.totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}",
                                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Text(
                                    (booking.paymentStatus == 'pending' 
                                        ? 'MENUNGGU' 
                                        : (booking.paymentStatus == 'approved' ? 'DISETUJUI' : 'DITOLAK')),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (booking.checkedIn) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F7FA),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "HADIR",
                                      style: TextStyle(color: Color(0xFF00838F), fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ]
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Map<String, String> _getFieldSpecs(String name) {
    final cleanName = name.toLowerCase();
    if (cleanName.contains("1")) {
      return {
        'floor': "Vinyl Standar Internasional",
        'position': "Depan (Dekat Pintu Masuk)",
      };
    } else if (cleanName.contains("2")) {
      return {
        'floor': "Vinyl Standar Internasional",
        'position': "Tengah (Akses Cepat)",
      };
    } else if (cleanName.contains("3")) {
      return {
        'floor': "Rumput Sintetis (Soft Turf)",
        'position': "Belakang (Suasana Kondusif)",
      };
    } else if (cleanName.contains("4")) {
      return {
        'floor': "Rumput Sintetis (Soft Turf)",
        'position': "Belakang (Sudut Tenang)",
      };
    } else if (cleanName.contains("5")) {
      return {
        'floor': "Interlock Polymer Sport",
        'position': "Samping (Ventilasi Maksimal)",
      };
    } else if (cleanName.contains("6")) {
      return {
        'floor': "Interlock Polymer Sport",
        'position': "Samping (Sudut Parkir)",
      };
    } else {
      return {
        'floor': "Vinyl Premium",
        'position': "Standar",
      };
    }
  }
}
