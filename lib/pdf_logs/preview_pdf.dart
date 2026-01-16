import 'package:flutter/material.dart';

class CreatePdf extends StatefulWidget {
  const CreatePdf({super.key});

  @override
  State<CreatePdf> createState() => _CreatePdfState();
}

class _CreatePdfState extends State<CreatePdf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preiview Pdf"),
        centerTitle: true,
      
      ),
      body: SingleChildScrollView(),
      bottomNavigationBar: TextButton(onPressed: (){}, child: Text('Save Pdf'))
    );
  }
}