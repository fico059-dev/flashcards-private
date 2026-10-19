import 'dart:io';
import 'dart:typed_data';
import 'package:flashcards/domain/models/flashcards/flashcard/flashcard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  final pw.Font _defaultFont;

  PdfExportService._(this._defaultFont);

  static Future<PdfExportService> create() async {
    final font = await PdfGoogleFonts.openSansRegular();
    return PdfExportService._(font);
  }

  Future<Uint8List> generateFlashcardsPdf(List<Flashcard> flashcards) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.SizedBox(height: 16),
              ...flashcards.map(
                (card) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Question: ${card.question}",
                      style: pw.TextStyle(font: _defaultFont, fontSize: 16),
                    ),
                    pw.Text(
                      "Answer: ${card.answer}",
                      style: pw.TextStyle(font: _defaultFont, fontSize: 16),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Divider(),
                  ],
                ),
              ),
            ],
      ),
    );

    return pdf.save();
  }

  Future<File> savePdf(Uint8List pdfBytes, String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename.pdf');
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  Future<void> printPdf(Uint8List pdfBytes) async {
    await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }
}
