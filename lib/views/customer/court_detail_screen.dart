// lib/views/customer/court_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/field_model.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import 'checkout_screen.dart';

class CourtDetailScreen extends StatefulWidget {
  final FieldModel field;
  final String selectedDate;

  const CourtDetailScreen({
    super.key,
    required this.field,
    required this.selectedDate,
  });

  @override
  State<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends State<CourtDetailScreen> {
  final List<int> _selectedHours = []; // Holds all selected slot hours

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch unavailable slots for this field and date
      context.read<BookingProvider>().fetchUnavailableSlots(widget.field.id, widget.selectedDate);
    });
  }

  String _formatHourPill(int hour) {
    final start = hour.toString().padLeft(2, '0');
    final end = (hour + 1).toString().padLeft(2, '0');
    return "$start:00 - $end:00";
  }

  double _getSlotPrice(int hour) {
    if (hour >= 8 && hour < 12) return 65000.0;
    if (hour >= 12 && hour < 18) return 85000.0;
    if (hour >= 18 && hour <= 23) return 160000.0;
    return 65000.0;
  }

  String _formatPrice(double price) {
    return "Rp ${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]}.")}";
  }

  String _formatPriceShort(double price) {
    return "Rp ${(price / 1000).toInt()}k";
  }

  Map<String, String> _getFieldSpecs(String name) {
    final cleanName = name.toLowerCase();
    if (cleanName.contains("1")) {
      return {
        'floor': "Vinyl Standar Internasional",
        'position': "Depan (Dekat Pintu Masuk)",
        'amenity': "Kantor Pengelola & Toilet Utama",
        'desc': "Menggunakan lantai vinyl premium standar internasional. Sangat empuk dan meminimalkan cedera lutut saat melakukan pergerakan agresif.",
      };
    } else if (cleanName.contains("2")) {
      return {
        'floor': "Vinyl Standar Internasional",
        'position': "Tengah (Akses Cepat)",
        'amenity': "Tribun Penonton Utama",
        'desc': "Lantai vinyl berkualitas dunia, berada di posisi paling strategis di tengah area tribun. Menawarkan sirkulasi udara terbaik untuk pemain.",
      };
    } else if (cleanName.contains("3")) {
      return {
        'floor': "Rumput Sintetis (Soft Turf)",
        'position': "Belakang (Suasana Kondusif)",
        'amenity': "Kantin & Kafetaria",
        'desc': "Rumput sintetis monofilament tebal dengan lapisan pasir silika dan karet granul premium. Nyaman untuk permainan taktis berdurasi panjang.",
      };
    } else if (cleanName.contains("4")) {
      return {
        'floor': "Rumput Sintetis (Soft Turf)",
        'position': "Belakang (Sudut Tenang)",
        'amenity': "Musala & Area Wudu",
        'desc': "Lantai rumput sintetis dengan perawatan terjadwal mingguan. Memberikan cengkeraman maksimal pada sol sepatu untuk kestabilan berakselerasi.",
      };
    } else if (cleanName.contains("5")) {
      return {
        'floor': "Interlock Polymer Sport",
        'position': "Samping (Ventilasi Maksimal)",
        'amenity': "Loker Pemain & Kamar Mandi Bilas",
        'desc': "Ubin olahraga interlock modern yang stabil. Sangat cocok untuk permainan dengan pantulan bola cepat dan performa tinggi.",
      };
    } else if (cleanName.contains("6")) {
      return {
        'floor': "Interlock Polymer Sport",
        'position': "Samping (Sudut Parkir)",
        'amenity': "Area Parkir Motor Utama",
        'desc': "Menggunakan sistem kunci antar interlock berkepadatan tinggi. Memiliki pantulan bola yang sangat konsisten di setiap sudut lapangan.",
      };
    } else {
      return {
        'floor': "Vinyl Premium",
        'position': "Standar",
        'amenity': "Tribun Samping",
        'desc': "Lapangan futsal standar dengan fasilitas lengkap dan pencahayaan memadai.",
      };
    }
  }



  Widget _buildSpecsCard(String name) {
    final specs = _getFieldSpecs(name);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 0.8),
        boxShadow: AppTheme.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Spesifikasi Lapangan",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Spec rows
          _buildSpecRow(
            "Bahan Lantai",
            specs['floor']!,
            Icons.layers_rounded,
            Colors.green,
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 16),
          _buildSpecRow(
            "Posisi",
            specs['position']!,
            Icons.location_on_rounded,
            Colors.red,
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 16),
          _buildSpecRow(
            "Paling Dekat Ke",
            specs['amenity']!,
            Icons.storefront_rounded,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          Text(
            specs['desc']!,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(
          "$label:",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingProv = context.watch<BookingProvider>();
    
    // Operating hours: 08:00 AM (8) to 11:00 PM (23, meaning last slot starts at 22:00)
    final operatingHours = List<int>.generate(15, (index) => 8 + index); // 8, 9... 22

    // Grouping slots into sections
    final morningHours = operatingHours.where((h) => h >= 8 && h < 12).toList();
    final afternoonHours = operatingHours.where((h) => h >= 12 && h < 18).toList();
    final nightHours = operatingHours.where((h) => h >= 18 && h <= 23).toList();

    // Calculate total price of selected hours
    final double totalPrice = _selectedHours.fold(0.0, (sum, hour) => sum + _getSlotPrice(hour));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft background color
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          widget.field.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            color: const Color(0xFFF5F7FA),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Sleek Image Banner with subtle shadow
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: widget.field.buildImage(
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                        height: 220,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metadata row: Clean venue information without rating pill
                        const Text(
                          "Indoor Futsal • Tuparev, Cirebon",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Court Specifications Card (Highly informative, premium & fully localized!)
                        _buildSpecsCard(widget.field.name),
                        const SizedBox(height: 16),
                        
                        // Selected Date Card (Clean, Forest Tinted Outline)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200, width: 0.8),
                            boxShadow: AppTheme.softShadow(),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGlow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Tanggal Pemesanan",
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.selectedDate,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section Header: Pilih Slot Jam
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Pilih Slot Jam",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "Bisa pilih lebih dari satu slot.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            // Micro info badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "Multi-select",
                                style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 3. Grid sections (Pagi, Sore, Malam)
                        bookingProv.isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.0),
                                  child: CircularProgressIndicator(color: AppTheme.primary),
                                ),
                              )
                            : Column(
                                children: [
                                  _buildTimeSection(
                                    "Pagi",
                                    "08.00 - 12.00",
                                    Icons.wb_sunny_rounded,
                                    Colors.orange,
                                    morningHours,
                                    bookingProv,
                                  ),
                                  _buildTimeSection(
                                    "Sore",
                                    "12.00 - 18.00",
                                    Icons.wb_cloudy_rounded,
                                    Colors.blue,
                                    afternoonHours,
                                    bookingProv,
                                  ),
                                  _buildTimeSection(
                                    "Malam",
                                    "18.00 - 23.00",
                                    Icons.nights_stay_rounded,
                                    Colors.indigo,
                                    nightHours,
                                    bookingProv,
                                  ),
                                ],
                              ),
                        const SizedBox(height: 100), // Prevent overlap with bottom bar
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Harga total slot terpilih (${_selectedHours.length} jam)",
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatPrice(totalPrice),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _selectedHours.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => CheckoutScreen(
                                      field: widget.field,
                                      selectedDate: widget.selectedDate,
                                      selectedHours: _selectedHours,
                                      selectedPrice: totalPrice,
                                    ),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade500,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("LANJUTKAN"),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(
    String title,
    String timeDesc,
    IconData icon,
    Color sectionColor,
    List<int> hours,
    BookingProvider bookingProv,
  ) {
    if (hours.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 10.0),
          child: Row(
            children: [
              Icon(icon, size: 16, color: sectionColor),
              const SizedBox(width: 8),
              Text(
                "$title ($timeDesc)",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        
        // Grid pill list of slots
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: hours.map((hour) {
            final isBooked = bookingProv.unavailableSlots.contains(hour);
            final isSelected = _selectedHours.contains(hour);
            final price = _getSlotPrice(hour);

            Color bg;
            Color text;
            Color border;
            List<BoxShadow>? shadow;

            if (isBooked) {
              bg = Colors.grey.shade100;
              text = Colors.grey.shade400;
              border = Colors.grey.shade200;
              shadow = null;
            } else if (isSelected) {
              bg = AppTheme.primary;
              text = Colors.white;
              border = AppTheme.primary;
              shadow = [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ];
            } else {
              bg = Colors.white;
              text = AppTheme.textPrimary;
              border = Colors.grey.shade200;
              shadow = [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ];
            }

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isBooked
                    ? null
                    : () {
                        setState(() {
                          if (isSelected) {
                            _selectedHours.remove(hour);
                          } else {
                            _selectedHours.add(hour);
                          }
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 105,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border, width: isSelected ? 1.8 : 1.0),
                    boxShadow: shadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatHourPill(hour),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isBooked ? "Penuh" : _formatPriceShort(price),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected || isBooked ? FontWeight.bold : FontWeight.w500,
                          color: isBooked 
                              ? Colors.grey.shade400 
                              : (isSelected ? Colors.white70 : AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
