import 'package:flutter/material.dart';
import 'package:queuetrack/pdf_logs/get_pdf_data.dart';

class CreatePdf extends StatefulWidget {
  const CreatePdf({super.key});

  @override
  State<CreatePdf> createState() => _CreatePdfState();
}

class _CreatePdfState extends State<CreatePdf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[300],
      body: Center(child:
      Text(
        'Click the Button Below to Download and Share Your Document',
        style: TextStyle(
            fontSize: 24,
            fontStyle: FontStyle.italic),
      )
        ,),
      bottomNavigationBar: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.blue),
          foregroundColor: WidgetStatePropertyAll(Colors.white),

        ),
          onPressed: (){
        GetPdfData().createPdfDocument(pdfName: 'QueueTrackReport', context: context);
      }, child: Text('Save and Share Pdf'))
    );
  }
}