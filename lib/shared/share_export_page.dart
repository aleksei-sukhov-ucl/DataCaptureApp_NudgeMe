import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:nudge_me/pages/charts_page/bar_graph.dart';
import 'package:nudge_me/pages/charts_page/line_graph.dart';
import 'package:nudge_me/shared/pdf_page.dart';
import 'package:nudge_me/shared/share_button.dart';
import 'package:nudge_me/shared/widget_to_image.dart';
import 'package:provider/provider.dart';

import 'cards.dart';

class PDFExportPage extends StatelessWidget {
  final int timeFrame;
  final bool exportSteps;
  final bool exportWellbeing;
  final bool exportBreathlessness;
  final bool exportSputumColor;
  final bool exportOverallTrends;

  PDFExportPage(
      {Key key,
      this.timeFrame,
      this.exportSteps,
      this.exportWellbeing,
      this.exportBreathlessness,
      this.exportSputumColor,
      this.exportOverallTrends});

  Widget trendsCardLayout() {
    return RepaintBoundary(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                child: Text(
                  cards[4].units,
                  textScaleFactor: 1.5,
                ),
              ),
            ],
          ),
          Container(
            height: 320,
            width: 340,
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.grey[100],
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: LineChartTrends(),
                )
              ]),
            ),
          ),
          Container(
            width: 340,
            child: Card(
              key: Key("Card Description"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.grey[100],
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [cards[4].cardDescription],
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }

  Widget barGraph(int cardId, int initialIndex) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
              child: Text(
                cards[cardId].titleOfCard,
                textScaleFactor: 1.5,
              ),
            ),
          ],
        ),
        Container(
          height: 320,
          width: 340,
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: Colors.grey[100],
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Provider.value(
                  value: initialIndex,
                  updateShouldNotify: (oldValue, newValue) =>
                      newValue != oldValue,
                  child: BarChartWidget(
                      card: cards[cardId], initialIndex: initialIndex),
                ),
              )
            ]),
          ),
        ),
        (cardId == 2 || cardId == 3)
            ? Container(
                width: 340,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [cards[cardId].cardDescription],
                    ),
                  ),
                ),
              )
            : SizedBox.shrink()
      ],
    );
  }

  GlobalKey exportStepsKey;
  GlobalKey exportWellbeingKey;
  GlobalKey exportSputumColorKey;
  GlobalKey exportBreathlessnessKey;
  GlobalKey exportOverallTrendsKey;

  _getAllKeys() {
    List<GlobalKey> getImagesGlobalKeysList = [];
    if (exportSteps) {
      getImagesGlobalKeysList.add(exportStepsKey);
    }
    if (exportWellbeing) {
      getImagesGlobalKeysList.add(exportWellbeingKey);
    }
    if (exportSputumColor) {
      getImagesGlobalKeysList.add(exportSputumColorKey);
    }
    if (exportBreathlessness) {
      getImagesGlobalKeysList.add(exportBreathlessnessKey);
    }
    if (exportOverallTrends) {
      getImagesGlobalKeysList.add(exportOverallTrendsKey);
    }
    return getImagesGlobalKeysList;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async => await getImages(await _getAllKeys()),
    );

    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarBrightness: Brightness.light));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CardToImage(
                    key: Key("exportSteps"),
                    builder: (key) {
                      this.exportStepsKey = key;
                      return (exportSteps)
                          ? barGraph(0, (timeFrame + 1))
                          : SizedBox.shrink();
                    }),
                CardToImage(
                    key: Key("exportWellbeing"),
                    builder: (key) {
                      this.exportWellbeingKey = key;
                      return (exportWellbeing)
                          ? barGraph(1, timeFrame)
                          : SizedBox.shrink();
                    }),
                CardToImage(
                    key: Key("exportSputumColor"),
                    builder: (key) {
                      this.exportSputumColorKey = key;
                      return (exportSputumColor)
                          ? barGraph(2, timeFrame)
                          : SizedBox.shrink();
                    }),
                CardToImage(
                    key: Key("exportBreathlessness"),
                    builder: (key) {
                      this.exportBreathlessnessKey = key;
                      return (exportBreathlessness)
                          ? barGraph(3, timeFrame)
                          : SizedBox.shrink();
                    }),
                CardToImage(
                    key: Key("exportOverallTrends"),
                    builder: (key) {
                      this.exportOverallTrendsKey = key;
                      return (exportOverallTrends)
                          ? trendsCardLayout()
                          : SizedBox.shrink();
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getImages(List<GlobalKey> globalKeys) async {
    // Future.delayed(Duration(seconds: 4),
    //     () async => await PDFExport.generatePDF(globalKeys));

    await Future.delayed(const Duration(seconds: 2), () {
      PDFExport.generatePDF(globalKeys);
    });
  }
}
