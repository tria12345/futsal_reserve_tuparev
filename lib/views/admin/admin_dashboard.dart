// lib/views/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'court_maintenance_screen.dart';
import 'booking_verification_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FieldProvider>().fetchFields(isCustomer: false);
      context.read<BookingProvider>().fetchBookings();
    });
  }

  void _showAddCourtDialog(BuildContext context, FieldProvider fieldProv) {
    final nameCont = TextEditingController();
    final priceCont = TextEditingController();
    final descCont = TextEditingController();
    final imgCont = TextEditingController(text: "https://images.unsplash.com/photo-1577223625856-74552436858d?q=80&w=600");
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          surfaceTintColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Tambah Lapangan Futsal Baru", 
            style: TextStyle(
              color: AppTheme.textPrimary, 
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameCont,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: "Nama Lapangan (misal: Lapangan D)",
                      labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: priceCont,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: "Harga Per Jam (Rp)",
                      labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Price is required" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descCont,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: "Deskripsi / Spesifikasi",
                      labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: imgCont,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: "URL Gambar",
                      labelStyle: const TextStyle(color: AppTheme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL", style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                
                final success = await fieldProv.addField(
                  nameCont.text.trim(),
                  double.parse(priceCont.text.trim()),
                  descCont.text.trim(),
                  imgCont.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? "Court created successfully!" : "Failed to create court."),
                      backgroundColor: success ? AppTheme.primary : AppTheme.accent,
                    ),
                  );
                }
              },
              child: const Text("TAMBAH LAPANGAN"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fieldProv = context.watch<FieldProvider>();
    final bookingProv = context.watch<BookingProvider>();
    final user = auth.currentUser;

    if (user == null) return const LoginScreen();

    // Stats variables
    final pendingCount = bookingProv.bookings.where((b) => b.paymentStatus == 'pending').length;
    final approvedCount = bookingProv.bookings.where((b) => b.paymentStatus == 'approved').length;
    final checkinCount = bookingProv.bookings.where((b) => b.checkedIn).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Admin"),
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
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.background),
        child: RefreshIndicator(
          onRefresh: () async {
            await fieldProv.fetchFields(isCustomer: false);
            await bookingProv.fetchBookings();
          },
          color: AppTheme.primary,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome card (Stylized premium container)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.softShadow(),
                        border: Border.all(color: Colors.grey.shade200, width: 0.8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppTheme.primaryGlow,
                            child: const Icon(Icons.admin_panel_settings, color: AppTheme.primary, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selamat Datang, Admin ${user.name}!",
                                  style: const TextStyle(
                                    fontSize: 17, 
                                    fontWeight: FontWeight.bold, 
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Pengawasan operasional ekosistem langsung.",
                                  style: TextStyle(
                                    fontSize: 12, 
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
                    const SizedBox(height: 24),

                    // Operational stats grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "MENUNGGU",
                            pendingCount.toString(),
                            Icons.pending_actions,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            "DISETUJUI",
                            approvedCount.toString(),
                            Icons.check_circle_outline,
                            AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            "HADIR",
                            checkinCount.toString(),
                            Icons.sports_soccer,
                            AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Operational management actions
                    const Text(
                      "MANAJEMEN OPERASIONAL",
                      style: TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.textPrimary, 
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionTile(
                            "Tambah Lapangan",
                            Icons.add_box_rounded,
                            AppTheme.primary,
                            () => _showAddCourtDialog(context, fieldProv),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionTile(
                            "Pemeliharaan",
                            Icons.construction_rounded,
                            Colors.orange,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CourtMaintenanceScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildActionTileHorizontal(
                      "Verifikasi Pembayaran Sewa",
                      Icons.verified_user_rounded,
                      AppTheme.secondary,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BookingVerificationScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Live list preview
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "RESERVASI SISTEM LANGSUNG",
                            style: TextStyle(
                              fontSize: 13, 
                              fontWeight: FontWeight.bold, 
                              color: AppTheme.textPrimary, 
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGlow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Aliran Langsung", 
                            style: TextStyle(
                              color: AppTheme.primary, 
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    bookingProv.isLoading
                        ? const Center(child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(color: AppTheme.primary),
                          ))
                        : bookingProv.bookings.isEmpty
                            ? Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppTheme.softShadow(),
                                  border: Border.all(color: Colors.grey.shade200, width: 0.8),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.inbox_rounded, size: 48, color: AppTheme.textSecondary),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Tidak ada reservasi ditemukan di database MySQL.",
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: bookingProv.bookings.length > 5 ? 5 : bookingProv.bookings.length,
                                itemBuilder: (context, index) {
                                  final booking = bookingProv.bookings[index];
                                  
                                  Color stColor = Colors.orange;
                                  Color stBg = Colors.orange.withValues(alpha: 0.1);
                                  String statusText = "Menunggu Persetujuan";

                                  if (booking.paymentStatus == 'approved') {
                                    stColor = AppTheme.primary;
                                    stBg = AppTheme.primaryGlow;
                                    statusText = "Disetujui / Lunas";
                                  } else if (booking.paymentStatus == 'rejected') {
                                    stColor = AppTheme.accent;
                                    stBg = AppTheme.accent.withValues(alpha: 0.1);
                                    statusText = "Ditolak";
                                  }

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: Colors.grey.shade200, width: 0.8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppTheme.primaryGlow,
                                            child: const Icon(Icons.sports_soccer, color: AppTheme.primary),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${booking.fieldName} - ${booking.teamName}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold, 
                                                    color: AppTheme.textPrimary,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Tanggal Pemesanan: ${booking.bookDate}\nWaktu Sewa: ${booking.timeSlotString}",
                                                  style: const TextStyle(
                                                    fontSize: 11, 
                                                    color: AppTheme.textSecondary,
                                                    height: 1.3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "Rp ${booking.totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}",
                                                style: const TextStyle(
                                                  color: AppTheme.textPrimary, 
                                                  fontWeight: FontWeight.bold, 
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: stBg,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  statusText.toUpperCase(),
                                                  style: TextStyle(
                                                    color: stColor, 
                                                    fontSize: 9, 
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow(),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900, 
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10, 
              color: AppTheme.textSecondary, 
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 0.8),
            boxShadow: AppTheme.softShadow(),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: AppTheme.textPrimary, 
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTileHorizontal(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 0.8),
            boxShadow: AppTheme.softShadow(),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: AppTheme.textPrimary, 
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
