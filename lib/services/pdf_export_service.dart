import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/recipe.dart';
import '../utils.dart';

class PdfExportService {
  /// Генерирует PDF «технологическую карту» по уже масштабированному
  /// рецепту и открывает системный share-диалог.
  ///
  /// `scaledByTier[i]` — список секций i-го яруса с уже пересчитанными
  /// количествами ингредиентов.
  static Future<void> exportScaledRecipe({
    required Recipe recipe,
    required List<List<RecipeSection>> scaledByTier,
  }) async {
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();
    final fontItalic = await PdfGoogleFonts.robotoItalic();

    final doc = pw.Document(
      title: recipe.title,
      author: 'Tortio',
    );

    final theme = pw.ThemeData.withFont(
      base: font,
      bold: fontBold,
      italic: fontItalic,
    );

    final tiers = recipe.allTiers;
    final totalWeight = scaledByTier
        .expand((s) => s)
        .expand((s) => s.ingredients)
        .fold<double>(0, (sum, i) => sum + i.amount);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 36, 36, 32),
        theme: theme,
        build: (context) => [
          _buildHeader(recipe, totalWeight),
          if (recipe.notes.trim().isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _buildNotesBlock(recipe.notes),
          ],
          for (var ti = 0; ti < tiers.length; ti++) ...[
            pw.SizedBox(height: 18),
            _buildTierBlock(tiers[ti], ti, scaledByTier[ti]),
          ],
          pw.SizedBox(height: 24),
          _buildFooter(),
        ],
      ),
    );

    final bytes = await doc.save();
    final dateStr = DateTime.now().toIso8601String().substring(0, 10);
    final safeName = recipe.title
        .replaceAll(RegExp(r'[^\w\sЀ-ӿ-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'tortio-$safeName-$dateStr.pdf',
    );
  }

  static pw.Widget _buildHeader(Recipe recipe, double totalWeight) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          recipe.title,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#E85D75'),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          recipe.isMultiTier
              ? '${recipe.allTiers.length} ярус(ов) • итого ≈ ${formatGrams(totalWeight)}'
              : recipe.height > 0
                  ? '⌀ ${recipe.diameter.round()}×${recipe.height.round()} см • итого ≈ ${formatGrams(totalWeight)}'
                  : '⌀ ${recipe.diameter.round()} см • итого ≈ ${formatGrams(totalWeight)}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        if (recipe.tags.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 4,
            runSpacing: 3,
            children: recipe.tags
                .map(
                  (t) => pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(4),
                      ),
                    ),
                    child: pw.Text(
                      t,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildNotesBlock(String notes) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#FFF8F5'),
        border: pw.Border.all(
          color: PdfColor.fromHex('#FF6B8A').shade(0.7),
          width: 0.5,
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Text(
        notes,
        style: pw.TextStyle(
          fontSize: 11,
          fontStyle: pw.FontStyle.italic,
          color: PdfColors.grey800,
        ),
      ),
    );
  }

  static pw.Widget _buildTierBlock(
    TierData tier,
    int idx,
    List<RecipeSection> scaledSections,
  ) {
    final tierWeight = scaledSections
        .expand((s) => s.ingredients)
        .fold<double>(0, (sum, i) => sum + i.amount);
    final label = tier.label.isNotEmpty
        ? 'Ярус ${idx + 1}: ${tier.label}'
        : 'Ярус ${idx + 1}';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FF6B8A'),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            tier.height > 0
                ? '$label  •  ⌀ ${tier.diameter.round()}×${tier.height.round()} см  •  ${formatGrams(tierWeight)}'
                : '$label  •  ⌀ ${tier.diameter.round()} см  •  ${formatGrams(tierWeight)}',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
        pw.SizedBox(height: 8),
        for (final section in scaledSections) _buildSectionTable(section),
      ],
    );
  }

  static pw.Widget _buildSectionTable(RecipeSection s) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            s.type.name,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#E85D75'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Table(
            border: pw.TableBorder.symmetric(
              inside: pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.4,
              ),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(3),
              1: pw.FlexColumnWidth(1),
            },
            children: [
              for (final ing in s.ingredients)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: pw.Text(
                        ing.name,
                        style: const pw.TextStyle(fontSize: 11),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: pw.Text(
                        formatAmount(ing.amount, ing.unit),
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (s.notes.trim().isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              s.notes,
              style: pw.TextStyle(
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        'Tortio • $dateStr',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
      ),
    );
  }
}
