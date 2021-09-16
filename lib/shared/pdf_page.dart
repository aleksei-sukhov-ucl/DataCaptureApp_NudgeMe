import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFExport {
  static Future<File> generatePDF(List<GlobalKey> globalKeys) async {
    final pdf = pw.Document();

    print("globalKeys:$globalKeys");
    List<pw.ImageProvider> flutterImgs = [];
    await Future.forEach(globalKeys, (key) async {
      MemoryImage flutterImg = await Utils.capture(key);
      pw.ImageProvider img = await flutterImageProvider(flutterImg);
      flutterImgs.add(img);
    });

    await Future.delayed(const Duration(seconds: 2), () {
      pdf.addPage(pw.MultiPage(
          pageTheme: pageTheme,
          build: (context) {
            return [
              pw.ListView.builder(
                  itemCount: flutterImgs.length,
                  itemBuilder: (context, index) {
                    return pw.Center(
                      child: pw.Image(
                        flutterImgs[index],
                        width: pageTheme.pageFormat.availableWidth * 0.8,
                        height: pageTheme.pageFormat.availableHeight * 0.99,
                      ),
                    );
                  })
            ];
          }));
    });

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            "Wellbeing_as_of_${DateTime.now().toString().substring(0, 10)}.pdf");
  }
}

final pageTheme = pw.PageTheme(
  pageFormat: PdfPageFormat.a4,
  buildBackground: (context) {
    return pw.FullPage(
      ignoreMargins: true,
    );
  },
);

class Utils {
  static Future capture(GlobalKey globalKey) async {
    if (globalKey == null) return null;
    RenderRepaintBoundary wrappedWidget =
        globalKey.currentContext.findRenderObject();
    final img = await wrappedWidget.toImage();
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData.buffer.asUint8List();

    return MemoryImage(pngBytes);
  }
}
