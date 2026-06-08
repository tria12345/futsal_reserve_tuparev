import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final isDark = themeProv.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.background,
      appBar: AppBar(
        title: const Text("Bantuan & Dukungan"),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.gavel_rounded), text: "Peraturan"),
                  Tab(icon: Icon(Icons.help_outline_rounded), text: "FAQ"),
                  Tab(icon: Icon(Icons.contact_support_rounded), text: "Hubungi Kami"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRulesTab(isDark),
              _buildFaqTab(isDark),
              _buildContactTab(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ================= TAB 1: RULES & REGULATIONS =================
  Widget _buildRulesTab(bool isDark) {
    final rules = [
      {
        "icon": Icons.payment_rounded,
        "title": "Pembayaran DP / Lunas",
        "desc": "Setiap pemesanan lapangan wajib membayar uang muka (DP) minimal 50% atau langsung lunas. Bukti transfer harus diunggah maksimal 1 jam setelah pemesanan dibuat agar tidak dibatalkan otomatis."
      },
      {
        "icon": Icons.edit_calendar_rounded,
        "title": "Reschedule & Pembatalan",
        "desc": "Reschedule jadwal bermain hanya dapat diajukan paling lambat H-1 sebelum jam bermain. Pembatalan sepihak setelah H-1 atau ketidakhadiran akan membuat uang muka (DP) Anda hangus."
      },
      {
        "icon": Icons.sports_soccer_rounded,
        "title": "Sepatu & Pakaian Olahraga",
        "desc": "Semua pemain wajib menggunakan pakaian olahraga yang sopan dan sepatu futsal / sepatu olahraga dengan alas karet/flat. Tidak diperkenankan bermain bertelanjang dada atau menggunakan sandal."
      },
      {
        "icon": Icons.alarm_on_rounded,
        "title": "Ketepatan Waktu Bermain",
        "desc": "Pemain diharapkan hadir 10 menit sebelum jam bermain. Toleransi keterlambatan adalah 15 menit. Waktu bermain tidak akan diperpanjang apabila keterlambatan disebabkan oleh pihak penyewa."
      },
      {
        "icon": Icons.cleaning_services_rounded,
        "title": "Kebersihan & Ketertiban",
        "desc": "Dilarang membuang sampah sembarangan, merokok di area lapangan, membawa minuman keras, senjata tajam, atau hewan peliharaan demi kenyamanan bersama."
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardColorDark : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
            boxShadow: isDark ? [] : AppTheme.softShadow(),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    rule["icon"] as IconData,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rule["title"] as String,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        rule["desc"] as String,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= TAB 2: FAQ =================
  Widget _buildFaqTab(bool isDark) {
    final faqs = [
      {
        "q": "Bagaimana cara melakukan booking lapangan?",
        "a": "Masuk ke tab 'Beranda', pilih lapangan futsal yang Anda inginkan, tentukan tanggal bermain dan klik 'Cek Slot'. Pilih jam kosong yang tersedia, klik 'Pesan Sekarang', unggah bukti pembayaran transfer bank/e-wallet Anda, lalu tunggu konfirmasi/verifikasi pembayaran dari admin."
      },
      {
        "q": "Berapa lama proses verifikasi booking?",
        "a": "Proses verifikasi oleh admin berkisar antara 5 hingga 30 menit setelah bukti pembayaran diunggah. Anda akan menerima notifikasi real-time di aplikasi ketika status pemesanan disetujui atau ditolak."
      },
      {
        "q": "Apakah uang muka (DP) saya bisa dikembalikan?",
        "a": "Uang muka tidak dapat dikembalikan apabila pembatalan dilakukan setelah batas waktu H-1 jadwal bermain. Jika ingin melakukan perubahan jadwal (reschedule), silakan hubungi admin paling lambat H-1."
      },
      {
        "q": "Di mana saya bisa melihat riwayat booking saya?",
        "a": "Semua riwayat pemesanan aktif maupun lampau dapat Anda lihat pada tab 'Beranda' di bagian bawah (daftar 'Booking Saya')."
      },
      {
        "q": "Apa yang harus dilakukan saat tiba di lapangan?",
        "a": "Tunjukkan kode booking atau nama tim Anda yang tertera di aplikasi ke petugas administrasi lapangan saat check-in di loket resepsionis."
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardColorDark : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              iconColor: AppTheme.primary,
              collapsedIconColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              title: Text(
                faq["q"]!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Text(
                    faq["a"]!,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= TAB 3: CONTACT / SUPPORT =================
  Widget _buildContactTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.softShadow(),
            ),
            child: const Column(
              children: [
                Icon(Icons.headset_mic_rounded, color: Colors.white, size: 48),
                SizedBox(height: 12),
                Text(
                  "Butuh Bantuan Cepat?",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Text(
                  "Tim Customer Service kami siap melayani pertanyaan dan keluhan Anda setiap hari pukul 08:00 - 22:00 WIB.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "SALURAN DUKUNGAN RESMI",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          _buildContactCard(
            context: context,
            isDark: isDark,
            icon: Icons.chat_rounded,
            iconBg: const Color(0xFF25D366), // WhatsApp Green
            title: "WhatsApp Admin",
            value: "0877-1113-5073",
            actionText: "Salin Nomor",
            onActionPressed: () {
              Clipboard.setData(const ClipboardData(text: "087711135073"));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Nomor WhatsApp admin berhasil disalin ke papan klip.")),
              );
            },
          ),
          _buildContactCard(
            context: context,
            isDark: isDark,
            icon: Icons.email_rounded,
            iconBg: const Color(0xFF007AFF), // iOS Blue
            title: "Email Dukungan",
            value: "futsaltuparev@gmail.com",
            actionText: "Salin Email",
            onActionPressed: () {
              Clipboard.setData(const ClipboardData(text: "futsaltuparev@gmail.com"));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Alamat email dukungan berhasil disalin ke papan klip.")),
              );
            },
          ),
          _buildContactCard(
            context: context,
            isDark: isDark,
            icon: Icons.location_on_rounded,
            iconBg: const Color(0xFFFF9500), // iOS Orange
            title: "Lokasi Fisik",
            value: "Jl. Tuparev No. 123, Kedawung, Cirebon",
            actionText: "Lihat Peta",
            onActionPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Fitur peta sedang dipersiapkan.")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconBg,
    required String title,
    required String value,
    required String actionText,
    required VoidCallback onActionPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardColorDark : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconBg, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}
