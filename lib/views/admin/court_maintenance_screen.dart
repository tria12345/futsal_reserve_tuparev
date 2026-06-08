// lib/views/admin/court_maintenance_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/field_provider.dart';
import '../../theme/app_theme.dart';

class CourtMaintenanceScreen extends StatefulWidget {
  const CourtMaintenanceScreen({super.key});

  @override
  State<CourtMaintenanceScreen> createState() => _CourtMaintenanceScreenState();
}

class _CourtMaintenanceScreenState extends State<CourtMaintenanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FieldProvider>().fetchFields(isCustomer: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final fieldProv = context.watch<FieldProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kontrol Pemeliharaan"),
      ),
      body: Container(
        decoration: const BoxDecoration(color: AppTheme.background),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: fieldProv.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : fieldProv.fields.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sports_soccer_rounded, size: 64, color: AppTheme.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              "Tidak ada lapangan terdaftar di sistem.", 
                              style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: fieldProv.fields.length,
                        itemBuilder: (context, index) {
                          final court = fieldProv.fields[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade200, width: 0.8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Miniature thumbnail
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGlow,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200, width: 0.8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(11),
                                      child: court.buildImage(
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Icon(
                                          Icons.sports_soccer_rounded,
                                          color: AppTheme.primary,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Court meta
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          court.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold, 
                                            fontSize: 16, 
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: court.isMaintenance 
                                                ? Colors.orange.withValues(alpha: 0.1) 
                                                : AppTheme.primaryGlow,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            court.isMaintenance 
                                                ? "Sedang Diperbaiki ⚠️" 
                                                : "Aktif & Bisa Dipesan 🏟️",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: court.isMaintenance ? Colors.orange : AppTheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Switch toggle + Delete button
                                  Column(
                                    children: [
                                      Switch(
                                        value: court.isMaintenance,
                                        activeThumbColor: AppTheme.accent,
                                        activeTrackColor: AppTheme.accent.withValues(alpha: 0.4),
                                        inactiveThumbColor: AppTheme.primary,
                                        inactiveTrackColor: AppTheme.primaryGlow,
                                        onChanged: (newValue) async {
                                          final success = await fieldProv.toggleMaintenance(court.id, newValue);
                                          if (context.mounted) {
                                            final statusWord = newValue 
                                                ? "ditangguhkan untuk pemeliharaan" 
                                                : "diaktifkan kembali";
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? "${court.name} sekarang $statusWord."
                                                      : "Gagal mengubah status lapangan.",
                                                ),
                                                backgroundColor: success ? AppTheme.primary : AppTheme.accent,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                      // Delete Court Button (Modul 5 — CRUD Delete)
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.accent, size: 22),
                                        tooltip: "Hapus Lapangan",
                                        onPressed: () {
                                          _showDeleteConfirmDialog(context, court.id, court.name, fieldProv);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ),
      ),
    );
  }

  // Delete confirmation dialog (Modul 5 — CRUD Delete)
  void _showDeleteConfirmDialog(
    BuildContext context,
    int courtId,
    String courtName,
    FieldProvider fieldProv,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          surfaceTintColor: AppTheme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTheme.accent, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Hapus Lapangan: $courtName",
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus lapangan ini secara permanen? Tindakan ini tidak dapat dibatalkan.",
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "BATAL",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await fieldProv.deleteField(courtId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? "Lapangan berhasil dihapus!"
                            : "Gagal menghapus lapangan.",
                      ),
                      backgroundColor: success ? AppTheme.primary : AppTheme.accent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text("KONFIRMASI"),
            ),
          ],
        );
      },
    );
  }
}
