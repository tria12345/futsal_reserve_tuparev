// lib/views/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'court_maintenance_screen.dart';
import 'booking_verification_screen.dart';
import '../help_support_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _bottomNavIndex = 0; // 0: Panel Admin, 1: Pengaturan

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FieldProvider>().fetchFields(isCustomer: false);
      context.read<BookingProvider>().fetchBookings();
    });
  }

  void _showAddCourtDialog(BuildContext context, FieldProvider fieldProv, bool isDark) {
    final nameCont = TextEditingController();
    final priceCont = TextEditingController();
    final descCont = TextEditingController();
    final imgCont = TextEditingController(text: "https://images.unsplash.com/photo-1577223625856-74552436858d?q=80&w=600");
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : AppTheme.cardColor,
          surfaceTintColor: isDark ? const Color(0xFF1E293B) : AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Tambah Lapangan Futsal Baru", 
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textPrimary, 
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
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: "Nama Lapangan (misal: Lapangan D)",
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
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
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: "Harga Per Jam (Rp)",
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
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
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: "Deskripsi / Spesifikasi",
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
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
                    style: TextStyle(color: isDark ? Colors.white : AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: "URL Gambar",
                      labelStyle: TextStyle(color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
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
    final themeProv = context.watch<ThemeProvider>();
    final user = auth.currentUser;
    final isDark = themeProv.isDarkMode;

    if (user == null) return const LoginScreen();

    // Stats variables
    final pendingCount = bookingProv.bookings.where((b) => b.paymentStatus == 'pending').length;
    final approvedCount = bookingProv.bookings.where((b) => b.paymentStatus == 'approved').length;
    final checkinCount = bookingProv.bookings.where((b) => b.checkedIn).length;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.background,
      appBar: AppBar(
        title: Text(
          _bottomNavIndex == 0 ? "Dashboard Admin" : "Pengaturan",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: _bottomNavIndex == 0
              ? RefreshIndicator(
                  onRefresh: () async {
                    await fieldProv.fetchFields(isCustomer: false);
                    await bookingProv.fetchBookings();
                  },
                  color: AppTheme.primary,
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
                            color: isDark ? const Color(0xFF1E293B) : AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppTheme.softShadow(),
                            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 0.8),
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
                                      style: TextStyle(
                                        fontSize: 17, 
                                        fontWeight: FontWeight.bold, 
                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Pengawasan operasional ekosistem langsung.",
                                      style: TextStyle(
                                        fontSize: 12, 
                                        color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
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
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                "DISETUJUI",
                                approvedCount.toString(),
                                Icons.check_circle_outline,
                                AppTheme.primary,
                                isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                "HADIR",
                                checkinCount.toString(),
                                Icons.sports_soccer,
                                AppTheme.secondary,
                                isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Operational management actions
                        Text(
                          "MANAJEMEN OPERASIONAL",
                          style: TextStyle(
                            fontSize: 13, 
                            fontWeight: FontWeight.bold, 
                            color: isDark ? Colors.white70 : AppTheme.textPrimary, 
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
                                isDark,
                                () => _showAddCourtDialog(context, fieldProv, isDark),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionTile(
                                "Pemeliharaan",
                                Icons.construction_rounded,
                                Colors.orange,
                                isDark,
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
                          isDark,
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
                            Expanded(
                              child: Text(
                                "RESERVASI SISTEM LANGSUNG",
                                style: TextStyle(
                                  fontSize: 13, 
                                  fontWeight: FontWeight.bold, 
                                  color: isDark ? Colors.white70 : AppTheme.textPrimary, 
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
                                      color: isDark ? const Color(0xFF1E293B) : AppTheme.cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: AppTheme.softShadow(),
                                      border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 0.8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.inbox_rounded, size: 48, color: isDark ? const Color(0xFF64748B) : AppTheme.textSecondary),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Tidak ada reservasi ditemukan di database MySQL.",
                                            style: TextStyle(
                                              color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
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
                                          side: BorderSide(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 0.8),
                                        ),
                                        color: isDark ? const Color(0xFF1E293B) : AppTheme.cardColor,
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
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold, 
                                                        color: isDark ? Colors.white : AppTheme.textPrimary,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "Tanggal Pemesanan: ${booking.bookDate}\nWaktu Sewa: ${booking.timeSlotString}",
                                                      style: TextStyle(
                                                        fontSize: 11, 
                                                        color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
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
                                                    style: TextStyle(
                                                      color: isDark ? Colors.white : AppTheme.textPrimary, 
                                                      fontWeight: FontWeight.bold, 
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: isDark ? const Color(0xFF0F172A) : stBg,
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
                )
              : _buildSettingsTab(user, auth, isDark),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : Colors.grey.shade200,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
          },
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: isDark ? const Color(0xFF64748B) : Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_rounded),
              label: 'Panel Admin',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(UserModel user, AuthProvider auth, bool isDark) {
    final themeProv = context.watch<ThemeProvider>();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        // iOS styled user profile header card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade100),
            boxShadow: AppTheme.softShadow(),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                  backgroundImage: NetworkImage(
                     user.avatar ?? "https://api.dicebear.com/7.x/adventurer/svg?seed=${user.name}",
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGlow,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Grouped iOS style Menu Section 1: Tampilan
        _buildGroupTitle("TAMPILAN"),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.dark_mode_rounded,
                  iconBg: const Color(0xFF5856D6), // iOS Purple
                  title: "Mode Gelap",
                  trailing: Switch.adaptive(
                    value: themeProv.isDarkMode,
                    activeTrackColor: AppTheme.primary,
                    onChanged: (val) {
                      themeProv.toggleTheme(val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Grouped iOS style Menu Section 2: Informasi
        _buildGroupTitle("INFORMASI"),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.info_outline_rounded,
                  iconBg: const Color(0xFF007AFF), // iOS Blue
                  title: "Tentang Aplikasi",
                  trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Futsal Reserve Tuparev",
                      applicationVersion: "v1.0.0",
                      applicationIcon: Image.asset('assets/images/logo.png', width: 48, height: 48),
                      children: [
                        const Text("Aplikasi booking lapangan futsal premium dengan fitur notifikasi real-time dan state management canggih."),
                      ],
                    );
                  },
                ),
                Divider(color: isDark ? const Color(0xFF334155) : Colors.grey.shade100, height: 1),
                _buildSettingsTile(
                  icon: Icons.support_agent_rounded,
                  iconBg: const Color(0xFF34C759), // iOS Green
                  title: "Bantuan & Dukungan",
                  trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 35),

        // Grouped iOS style Menu Section 3: Logout
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade100),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: _buildSettingsTile(
              icon: Icons.logout_rounded,
              iconBg: const Color(0xFFFF3B30), // iOS Red
              title: "Keluar Akun",
              trailing: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
              onTap: () async {
                final navigator = Navigator.of(context);
                // Confirm dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog.adaptive(
                    title: const Text("Keluar"),
                    content: const Text("Apakah Anda yakin ingin keluar dari akun ini?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Keluar", style: TextStyle(color: AppTheme.accent)),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await auth.logout();
                  navigator.pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBg,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: iconBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : AppTheme.textPrimary,
        ),
      ),
      trailing: trailing,
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow(),
        border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 0.8),
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
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w900, 
              color: isDark ? Colors.white : AppTheme.textPrimary,
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

  Widget _buildActionTile(String title, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return Material(
      color: isDark ? const Color(0xFF1E293B) : AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 0.8),
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
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : AppTheme.textPrimary, 
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTileHorizontal(String title, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return Material(
      color: isDark ? const Color(0xFF1E293B) : AppTheme.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 0.8),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: isDark ? Colors.white : AppTheme.textPrimary, 
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
