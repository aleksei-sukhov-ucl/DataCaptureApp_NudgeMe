import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

final pageTheme = pw.PageTheme(
  pageFormat: PdfPageFormat.a4,
  buildBackground: (context) {
    return pw.FullPage(
      ignoreMargins: true,
    );
  },
);

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

    print("flutterImgs: $flutterImgs");
    // Future<List<pw.ImageProvider>> _getAllImages(
    //     List<GlobalKey> globalKeys) async {
    //   List<pw.ImageProvider> flutterImgs = [];
    //   globalKeys.forEach((globalKey) async {
    //     MemoryImage flutterImg = await Utils.capture(globalKey);
    //     flutterImgs.add(await flutterImageProvider(flutterImg));
    //   });
    //
    //   return flutterImgs;
    // }
    //
    // print(await _getAllImages(globalKeys));
    // List<pw.ImageProvider> flutterImgs = [];
    // // final flutterImg = await Utils.capture(globalKey);
    // // final pw.ImageProvider img = await flutterImageProvider(flutterImg);
    // print("globalKeys:$globalKeys");
    // globalKeys.forEach((globalKey) async {
    //   MemoryImage flutterImg = await Utils.capture(globalKey);
    //   flutterImgs.add(await flutterImageProvider(flutterImg));
    // });
    // print("flutterImgs: $flutterImgs");
    // final flutterImg1 = await Utils.capture(globalKeys[0]);
    // final pw.ImageProvider img1 = await flutterImageProvider(flutterImg1);
    // final flutterImg2 = await Utils.capture(globalKeys[1]);
    // final pw.ImageProvider img2 = await flutterImageProvider(flutterImg2);
    // final flutterImg3 = await Utils.capture(globalKeys[2]);
    // final pw.ImageProvider img3 = await flutterImageProvider(flutterImg3);

    // globalKeys.forEach((key) async {
    //   final flutterImg = await Utils.capture(key);
    //   print("flutterImg: $flutterImg");
    //   // pw.ImageProvider img = await flutterImageProvider(flutterImg);
    //   flutterImgs.add(await flutterImageProvider(flutterImg));
    // });

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
                      ),
                    );
                  })
              // pw.Center(
              //   child: pw.Image(
              //     flutterImgs[0],
              //     width: pageTheme.pageFormat.availableWidth * 0.8,
              //   ),
              // )
            ];
          }));
    });

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            "Wellbeing_as_of_${DateTime.now().toString().substring(0, 10)}.pdf");
  }

  // static Future openFile(File file) async {
  //   final url = file.path;
  //
  //   await OpenFile.open(url);
  // }
}

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
