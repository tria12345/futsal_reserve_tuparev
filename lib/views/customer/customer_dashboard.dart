// lib/views/customer/customer_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/field_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../login_screen.dart';
import 'court_detail_screen.dart';
import '../help_support_screen.dart';

class CustomerDashboard extends StatefulWidget {
  final int initialTab;
  const CustomerDashboard({super.key, this.initialTab = 0});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  late DateTime _selectedDate;
  late int _activeTab; // 0: Booking Lobby, 1: Booking History
  int _bottomNavIndex = 0; // 0: Beranda (Booking Lobby/History), 1: Pengaturan

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
    final themeProv = context.watch<ThemeProvider>();
    final user = auth.currentUser;
    final isDark = themeProv.isDarkMode;

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.background,
      appBar: AppBar(
        title: Text(
          _bottomNavIndex == 0 ? "Futsal Reserve Tuparev" : "Pengaturan",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _bottomNavIndex == 0
              ? Column(
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
                              border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
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
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  "Siap menaklukkan lapangan hari ini?",
                                  style: TextStyle(
                                    fontSize: 13,
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

                    // Tab Buttons (Beautiful commercial segmented selector)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
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
                                  color: _activeTab == 0 ? (isDark ? const Color(0xFF334155) : Colors.white) : Colors.transparent,
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
                                child: Text(
                                  "Sewa Lapangan",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _activeTab == 0 ? AppTheme.primary : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
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
                                  color: _activeTab == 1 ? (isDark ? const Color(0xFF334155) : Colors.white) : Colors.transparent,
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
                                child: Text(
                                  "Riwayat Sewa Saya",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _activeTab == 1 ? AppTheme.primary : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
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
                          ? _buildLobbyTab(fieldProv, isDark)
                          : _buildHistoryTab(bookingProv, isDark),
                    ),
                  ],
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
              icon: Icon(Icons.sports_soccer_rounded),
              label: 'Beranda',
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

  Widget _buildLobbyTab(FieldProvider fieldProv, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal calendar picker
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Pilih Tanggal",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.textPrimary,
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
                    color: isSelected ? AppTheme.primary : (isDark ? const Color(0xFF1E293B) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : (isDark ? const Color(0xFF334155) : Colors.grey.shade200),
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
                          color: isSelected ? Colors.white70 : (isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : AppTheme.textPrimary),
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

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Lapangan Futsal Tersedia",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.textPrimary,
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
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 0.8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                                        court.imageUrl ?? _getFallbackImageUrl(court.name),
                                        height: 140,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => Image.network(
                                          _getFallbackImageUrl(court.name),
                                          height: 140,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c2, e2, s2) => Container(
                                            height: 140,
                                            color: isDark ? const Color(0xFF334155) : Colors.grey.shade100,
                                            child: const Icon(Icons.sports_soccer, size: 48, color: Colors.grey),
                                          ),
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
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDark ? Colors.white : AppTheme.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${_getFieldSpecs(court.name)['floor']} • ${_getFieldSpecs(court.name)['position']}",
                                                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isDark ? const Color(0xFF0F172A) : AppTheme.primaryGlow,
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

  Widget _buildHistoryTab(BookingProvider bookingProv, bool isDark) {
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
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200, width: 0.8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
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
                                color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
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
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.textPrimary),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Tanggal Pemesanan: ${booking.bookDate}",
                                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                                  ),
                                  Text(
                                    "Waktu Sewa: ${booking.timeSlotString}",
                                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Nama Tim: ${booking.teamName}",
                                    style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppTheme.textPrimary, fontWeight: FontWeight.w600),
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
                                      color: const Color(0xFF006064),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "HADIR",
                                      style: TextStyle(color: Color(0xFF80DEEA), fontSize: 8, fontWeight: FontWeight.bold),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // Fallback gambar Unsplash unik per lapangan, dipakai jika gambar server gagal
  String _getFallbackImageUrl(String courtName) {
    final cleanName = courtName.toLowerCase();
    if (cleanName.contains('1')) {
      return 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?q=80&w=600&fit=crop';
    } else if (cleanName.contains('2')) {
      return 'https://images.unsplash.com/photo-1577223625856-74552436858d?q=80&w=600&fit=crop';
    } else if (cleanName.contains('3')) {
      return 'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?q=80&w=600&fit=crop';
    } else if (cleanName.contains('4')) {
      return 'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?q=80&w=600&fit=crop';
    } else if (cleanName.contains('5')) {
      return 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=600&fit=crop';
    } else if (cleanName.contains('6')) {
      return 'https://images.unsplash.com/photo-1546519638-68e109498ffc?q=80&w=600&fit=crop';
    }
    return 'https://images.unsplash.com/photo-1577223625856-74552436858d?q=80&w=600&fit=crop';
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
