// lib/views/customer/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/field_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import 'customer_dashboard.dart';

class CheckoutScreen extends StatefulWidget {
  final FieldModel field;
  final String selectedDate;
  final List<int> selectedHours;
  final double selectedPrice;

  const CheckoutScreen({
    super.key,
    required this.field,
    required this.selectedDate,
    required this.selectedHours,
    required this.selectedPrice,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _teamController;
  late TextEditingController _phoneController;

  List<int>? _selectedReceiptBytes;
  String? _receiptFileName;
  bool _isReceiptSelected = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? "");
    _teamController = TextEditingController(text: "");
    _phoneController = TextEditingController(text: "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teamController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatHoursList(List<int> hours) {
    final sorted = List<int>.from(hours)..sort();
    return sorted.map((hour) {
      final start = "${hour.toString().padLeft(2, '0')}:00";
      final end = "${(hour + 1).toString().padLeft(2, '0')}:00";
      return "$start-$end";
    }).join(", ");
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

  // Pick actual photo from local device gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Compress slightly
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedReceiptBytes = bytes;
          _receiptFileName = image.name;
          _isReceiptSelected = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bukti pembayaran berhasil dimuat!"),
              backgroundColor: AppTheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to pick image: $e"),
            backgroundColor: AppTheme.accent,
          ),
        );
      }
    }
  }



  Future<void> _submitBooking(int userId) async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedReceiptBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih atau buat bukti pembayaran terlebih dahulu!"),
          backgroundColor: AppTheme.accent,
        ),
      );
      return;
    }

    final bookingProv = context.read<BookingProvider>();

    bool overallSuccess = true;
    String? lastError;

    // Loop through each selected hour to create separate booking records in the MySQL database.
    // This maintains backward compatibility with the database schema and ensures all selected
    // slots are properly marked as occupied for other users instantly.
    for (int hour in widget.selectedHours) {
      final slotPrice = _getSlotPrice(hour);
      final success = await bookingProv.createBooking(
        userId: userId,
        fieldId: widget.field.id,
        date: widget.selectedDate,
        startHour: hour,
        endHour: hour + 1,
        teamName: _teamController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        totalPrice: slotPrice,
        receiptBytes: _selectedReceiptBytes!,
        filename: _receiptFileName!,
      );
      if (!success) {
        overallSuccess = false;
        lastError = bookingProv.errorMessage;
      }
    }

    if (overallSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengajuan sewa dikirim! Menunggu verifikasi Admin."),
          backgroundColor: AppTheme.primary,
        ),
      );
      
      // Navigate back to Dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CustomerDashboard()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(lastError ?? "Failed to submit booking."),
          backgroundColor: AppTheme.accent,
        ),
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookingProv = context.watch<BookingProvider>();
    final user = auth.currentUser;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Ultra-clean, modern soft canvas color
      appBar: AppBar(
        title: const Text(
          "Verifikasi Pesanan & Pembayaran",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Order Summary Card (Visual Ticket Receipt Design)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100, width: 1.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ticket Header
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGlow,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.confirmation_number_rounded, color: AppTheme.primary, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "RINGKASAN PEMESANAN",
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                // Details
                                _buildTicketRow(
                                  icon: Icons.sports_soccer_rounded,
                                  label: "Nama Lapangan",
                                  value: widget.field.name,
                                ),
                                const SizedBox(height: 14),
                                _buildTicketRow(
                                  icon: Icons.calendar_month_rounded,
                                  label: "Tanggal Pemesanan",
                                  value: widget.selectedDate,
                                ),
                                const SizedBox(height: 14),
                                _buildTicketRow(
                                  icon: Icons.access_time_filled_rounded,
                                  label: "Waktu Sewa",
                                  value: _formatHoursList(widget.selectedHours),
                                ),
                                const SizedBox(height: 24),

                                // Ticket Divider
                                Row(
                                  children: List.generate(
                                    25,
                                    (index) => Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                                        color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade200,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Total Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Total Harga",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGlow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _formatPrice(widget.selectedPrice),
                                        style: const TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Left Notch
                          Positioned(
                            left: -10,
                            bottom: 74,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade100, width: 1.0),
                              ),
                            ),
                          ),
                          // Right Notch
                          Positioned(
                            right: -10,
                            bottom: 74,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade100, width: 1.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Checkout fields Form Card
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGlow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.assignment_rounded, color: AppTheme.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "DETAIL PERTANDINGAN",
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                          decoration: _buildInputDecoration(
                            labelText: "Nama Pelanggan",
                            hintText: "Full Name",
                            prefixIcon: Icons.person_rounded,
                          ),
                          validator: (v) => v == null || v.isEmpty ? "Name is required" : null,
                        ),
                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _teamController,
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                          decoration: _buildInputDecoration(
                            labelText: "Nama Tim",
                            hintText: "e.g., Tuparev United FC",
                            prefixIcon: Icons.sports_soccer_rounded,
                          ),
                          validator: (v) => v == null || v.isEmpty ? "Team name is required" : null,
                        ),
                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _phoneController,
                          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                          keyboardType: TextInputType.phone,
                          decoration: _buildInputDecoration(
                            labelText: "Nomor Telepon",
                            hintText: "e.g., 0812XXXXXXXX",
                            prefixIcon: Icons.phone_rounded,
                          ),
                          validator: (v) => v == null || v.isEmpty ? "Phone number is required" : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Dynamic QRIS Code Card (Sleek Scan Board Layout)
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100, width: 1.0),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGlow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.qr_code_scanner_rounded, color: AppTheme.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "PEMBAYARAN QRIS DINAMIS",
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sleek Viewfinder frame around QR Code
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade100, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  "https://api.qrserver.com/v1/create-qr-code/?size=180x180&data=FutsalReserveTuparev_Rp_${widget.selectedPrice.toInt()}",
                                  height: 180,
                                  width: 180,
                                  loadingBuilder: (c, w, l) {
                                    if (l == null) return w;
                                    return const SizedBox(
                                      height: 180,
                                      width: 180,
                                      child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGlow,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            "Total: ${_formatPrice(widget.selectedPrice)}",
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: const Text(
                            "Pindai kode QRIS, bayar, lalu unggah bukti pembayaran di bawah.",
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Receipt Upload block (Tactile dashed gesture box)
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade100, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGlow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "BUKTI PEMBAYARAN",
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Interactive dashed upload widget
                        GestureDetector(
                          onTap: _pickImageFromGallery,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: _isReceiptSelected ? AppTheme.primaryGlow : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _isReceiptSelected ? AppTheme.primary.withValues(alpha: 0.3) : Colors.grey.shade300,
                                width: 1.5,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _isReceiptSelected
                                ? Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 22),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _receiptFileName ?? "receipt.png",
                                              style: const TextStyle(
                                                color: AppTheme.primary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              "Bukti pembayaran berhasil dimuat!",
                                              style: TextStyle(
                                                color: AppTheme.primary,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFC5221F)),
                                        onPressed: () {
                                          setState(() {
                                            _selectedReceiptBytes = null;
                                            _receiptFileName = null;
                                            _isReceiptSelected = false;
                                          });
                                        },
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8F0FE),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.cloud_upload_outlined, size: 28, color: Colors.blueAccent),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "AMBIL FOTO DARI GALERI",
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        "Belum ada bukti pembayaran terpilih.",
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button (High-End green gradient drop-shadow capsule)
                  bookingProv.isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                      : Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _submitBooking(user.id),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                const Text(
                                  "KIRIM PENGAJUAN SEWA",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900, 
                                    letterSpacing: 0.5, 
                                    fontSize: 14, 
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          label.replaceAll(":", ""), 
          style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textPrimary, fontSize: 13),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
      floatingLabelStyle: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: AppTheme.primary, size: 18),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.accent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
      ),
    );
  }
}
