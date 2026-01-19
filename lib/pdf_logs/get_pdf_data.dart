import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GetPdfData {
  final supabase = Supabase.instance.client;

  // 1.get the daily queue
  Future getTodaysQueue() async {
    //final dt = DateTime.now().toLocal().toString();
    return await supabase.from('QUEUE').select('*') as List;
  }

  //create the pdf document
  Future createPdfDocument({
    required String pdfName,
    required BuildContext context,
  }) async {
    try {
      // 1. Create PDF document
      final pf = pw.Document();

      // 2. Fetch data
      final List data = await getTodaysQueue();

      // 3. Add page
      pf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            final rows = data.length;

            return pw.Table(
              border: pw.TableBorder.all(), // optional but nice
              children: [
                // Header row
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Queue ID',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Vehicle ID',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Number of Trips',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        'Wait Time',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                // Data rows
                for (int i = 0; i < rows; i++)
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(data[i]['queueId'].toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(data[i]['vehicleId'].toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(data[i]['numberOfTrips'].toString()),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(data[i]['waitTime'].toString()),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      );

      // 4. Show system preview / save / share dialog
      await Printing.layoutPdf(
        name:
            '${pdfName.toString()}-${DateTime.now().toString().split(' ')[0]}',
        onLayout: (PdfPageFormat format) async => pf.save(),
      );
      final pdfBytes = await pf.save();
      await Printing.sharePdf(
        filename: pdfName,
        bytes: pdfBytes,
        subject: 'Queue Track Daily Report',
        body: "Attached is today's report.",
      );
    } catch (err) {
      Fluttertoast.showToast(msg: err.toString());
      print('PDF Error: $err');
    }
  }
}
