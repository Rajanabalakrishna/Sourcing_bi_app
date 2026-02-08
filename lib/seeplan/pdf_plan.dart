import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'plan_service_model.dart';

class PlanPurposeScreen extends StatefulWidget {
  final VillageVisitPlan plan;

  const PlanPurposeScreen({super.key, required this.plan});

  @override
  State<PlanPurposeScreen> createState() => _PlanPurposeScreenState();
}

class _PlanPurposeScreenState extends State<PlanPurposeScreen> {
  bool _isGeneratingPdf = false;

  static const Color _primaryColor = Color(0xFF1E3A5F);
  static const Color _accentColor = Color(0xFF3B82F6);
  static const Color _successColor = Color(0xFF10B981);
  static const Color _warningColor = Color(0xFFF59E0B);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _cardColor = Colors.white;
  static const Color _textPrimary = Color(0xFF1F2937);
  static const Color _textSecondary = Color(0xFF6B7280);

  String _sanitizeText(String text) {
    return text
        .replaceAll('━', '-')
        .replaceAll('─', '-')
        .replaceAll('•', '-')
        .replaceAll('📍', '')
        .replaceAll('📌', '')
        .replaceAll('📋', '')
        .replaceAll('🏢', '')
        .replaceAll('👤', '')
        .replaceAll('👔', '')
        .replaceAll('📊', '')
        .replaceAll('🗺', '')
        .replaceAll('✅', '')
        .replaceAll('❌', '')
        .replaceAll('⚡', '')
        .replaceAll('🔹', '')
        .replaceAll('🔸', '')
        .replaceAll(RegExp(r'[^\x00-\x7F\u0900-\u097F\u00A0-\u00FF]'), '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Plan Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildWeekScheduleCard(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _primaryColor,
            _primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.plan.planName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.plan.purpose,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${widget.plan.startDate} - ${widget.plan.endDate}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekScheduleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.schedule_rounded, color: _accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Week Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          if (widget.plan.dailyPlans.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No daily plans available',
                  style: TextStyle(color: _textSecondary),
                ),
              ),
            )
          else
            ...widget.plan.dailyPlans
                .map((dailyPlan) => _buildDayCard(dailyPlan)),
        ],
      ),
    );
  }

  Widget _buildDayCard(DailyPlan dailyPlan) {
    final date = DateTime.tryParse(dailyPlan.visitDate);
    final formattedDate = date != null
        ? DateFormat('EEEE, MMM dd, yyyy').format(date)
        : dailyPlan.visitDate;

    Color statusColor;
    switch (dailyPlan.status) {
      case 'completed':
        statusColor = _successColor;
        break;
      case 'in_progress':
        statusColor = _warningColor;
        break;
      default:
        statusColor = _accentColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  dailyPlan.statusDisplay.isNotEmpty
                      ? dailyPlan.statusDisplay
                      : dailyPlan.status.replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.flag_rounded, size: 16, color: _textSecondary),
              const SizedBox(width: 8),
              const Text(
                'Purpose: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dailyPlan.purpose.isNotEmpty
                ? dailyPlan.purpose
                : 'No purpose specified',
            style: TextStyle(
              fontSize: 14,
              color:
              dailyPlan.purpose.isNotEmpty ? _textPrimary : _textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSmallInfoBadge(
                Icons.location_on_rounded,
                '${dailyPlan.villageVisits.length} Villages',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfoBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isGeneratingPdf ? null : _generateAndOpenPdf,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: _primaryColor.withOpacity(0.4),
        ),
        child: _isGeneratingPdf
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(width: 16),
            Text(
              'Generating PDF...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'Download & Open PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateAndOpenPdf() async {
    setState(() => _isGeneratingPdf = true);

    try {
      final filePath = await _generatePdf();
      await OpenFilex.open(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('PDF saved and opened successfully!'),
              ],
            ),
            backgroundColor: _successColor,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error generating PDF: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  //
  // ======================== PDF GENERATION (FIXED) ========================
  //

  Future<String> _generatePdf() async {
    final pdf = pw.Document();

    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final hindiFont = await PdfGoogleFonts.notoSansDevanagariRegular();
    final hindiBoldFont = await PdfGoogleFonts.notoSansDevanagariBold();

    final theme = pw.ThemeData.withFont(
      base: baseFont,
      bold: boldFont,
      fontFallback: [hindiFont, hindiBoldFont],
    );

    // ✅ FIX: Build a FLAT list — every entry is a simple, small,
    //    top-level pw.Text / pw.SizedBox / pw.Divider.
    //    NO pw.Column, pw.Row, or pw.Container wrappers.
    final List<pw.Widget> allWidgets = [];

    // === Plan Overview Section ===
    allWidgets.add(
      pw.Text(
        'Plan Overview',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
    allWidgets.add(pw.SizedBox(height: 6));

    // ✅ FLATTENED: was pw.Column → now separate Text widgets
    allWidgets.add(
      pw.Text(
        'Plan Name:',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
    );
    allWidgets.add(pw.SizedBox(height: 2));
    allWidgets.add(
      pw.Text(
        _sanitizeText(widget.plan.planName),
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
    );
    allWidgets.add(pw.SizedBox(height: 6));

    // ✅ FLATTENED: was pw.Row(Expanded(Column)) → now separate Text widgets
    allWidgets.add(
      pw.Text(
        'Total Days:',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
    );
    allWidgets.add(pw.SizedBox(height: 2));
    allWidgets.add(
      pw.Text(
        '${widget.plan.dailyPlans.length}',
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
    );
    allWidgets.add(pw.SizedBox(height: 6));

    allWidgets.add(
      pw.Text(
        'Status:',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ),
    );
    allWidgets.add(pw.SizedBox(height: 2));
    allWidgets.add(
      pw.Text(
        widget.plan.statusDisplay.isNotEmpty
            ? widget.plan.statusDisplay
            : widget.plan.status,
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
    );
    allWidgets.add(pw.SizedBox(height: 8));
    allWidgets.add(pw.Divider(color: PdfColors.grey400));
    allWidgets.add(pw.SizedBox(height: 12));

    // === Daily Schedule Section ===
    allWidgets.add(
      pw.Text(
        'Daily Schedule & Purpose',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
    allWidgets.add(pw.SizedBox(height: 8));

    for (var dailyPlan in widget.plan.dailyPlans) {
      final date = DateTime.tryParse(dailyPlan.visitDate);
      final formattedDate = date != null
          ? DateFormat('EEE, MMM dd, yyyy').format(date)
          : dailyPlan.visitDate;

      final status = dailyPlan.statusDisplay.isNotEmpty
          ? dailyPlan.statusDisplay
          : dailyPlan.status;

      final purpose = _sanitizeText(
        dailyPlan.purpose.isNotEmpty
            ? dailyPlan.purpose
            : 'No purpose specified',
      );

      // ✅ FLATTENED: was pw.Row → now separate Text widgets
      allWidgets.add(
        pw.Text(
          formattedDate,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.indigo900,
          ),
        ),
      );
      allWidgets.add(pw.SizedBox(height: 2));

      allWidgets.add(
        pw.Text(
          'Status: $status',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      );
      allWidgets.add(pw.SizedBox(height: 4));

      // ✅ FLATTENED: was pw.Column → now separate Text widgets
      allWidgets.add(
        pw.Text(
          'Purpose:',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
      );
      allWidgets.add(pw.SizedBox(height: 2));

      // ✅ FIX: For potentially long purpose text, split into
      //    smaller chunks so each chunk fits on one page.
      final purposeLines = _splitTextIntoChunks(purpose, 500);
      for (final chunk in purposeLines) {
        allWidgets.add(
          pw.Text(
            chunk,
            style: const pw.TextStyle(fontSize: 9),
          ),
        );
      }
      allWidgets.add(pw.SizedBox(height: 4));

      // ✅ FLATTENED: simple Text, no Row/Container wrapper
      allWidgets.add(
        pw.Text(
          'Villages: ${dailyPlan.villageVisits.length}',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
        ),
      );
      allWidgets.add(pw.SizedBox(height: 6));
      allWidgets.add(pw.Divider(color: PdfColors.grey300, thickness: 0.5));
      allWidgets.add(pw.SizedBox(height: 6));
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        maxPages: 100,
        theme: theme,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Week Schedule Report',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo900,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              '${widget.plan.startDate} - ${widget.plan.endDate}',
              style: const pw.TextStyle(
                  fontSize: 9, color: PdfColors.indigo900),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              _sanitizeText(widget.plan.planName),
              style:
              const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),
          ],
        ),
        build: (context) => allWidgets,
        footer: (context) => pw.Column(
          children: [
            pw.Divider(color: PdfColors.grey300, thickness: 0.5),
            pw.SizedBox(height: 3),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated: ${DateFormat('MMM dd, yyyy HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'Page ${context.pageNumber}/${context.pagesCount}',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'Week_Schedule_${widget.plan.planName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// ✅ NEW HELPER: Splits long text into chunks of [maxLength] characters
  /// so that no single pw.Text widget becomes taller than a page.
  List<String> _splitTextIntoChunks(String text, int maxLength) {
    if (text.length <= maxLength) return [text];

    final List<String> chunks = [];
    int start = 0;
    while (start < text.length) {
      int end = start + maxLength;
      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }
      // Try to break at a space to avoid cutting words
      int spaceIndex = text.lastIndexOf(' ', end);
      if (spaceIndex > start) {
        end = spaceIndex;
      }
      chunks.add(text.substring(start, end));
      start = end + 1; // skip the space
    }
    return chunks;
  }
}
