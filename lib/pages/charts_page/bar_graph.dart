import 'dart:math';import 'package:fl_chart/fl_chart.dart';import 'package:flutter/cupertino.dart';import 'package:flutter/material.dart';import 'package:flutter/gestures.dart';import 'package:flutter/rendering.dart';import 'package:nudge_me/model/user_model.dart';import 'package:nudge_me/shared/cards.dart';import 'package:nudge_me/shared/loading_indicator.dart';import 'package:pedometer/pedometer.dart';import 'package:provider/provider.dart';import 'package:shared_preferences/shared_preferences.dart';import '../../main.dart';import 'bar_graph_settings.dart';import 'package:intl/intl.dart';/// Ref: https://github.com/imaNNeoFighT/fl_chart/blob/master/example/lib/bar_chart/samples/bar_chart_sample1.dartclass BarChartWidget extends StatefulWidget {  final CardClass card;  final int initialIndex;  final int dbColumnIndex = 4;  const BarChartWidget({Key key, this.card, this.initialIndex})      : super(key: key);  @override  State<StatefulWidget> createState() => BarChartWidgetState();}class BarChartWidgetState extends State<BarChartWidget> {  /// Index for Slider  int _initialIndex = 0;  /// Bar Chart settings  final Color barBackgroundColor = Colors.white;  final Duration animDuration = const Duration(milliseconds: 250);  int touchedIndex = -1;  /// Futures to get the data from DB  Future _futureWeek;  Future _futureMonth;  Future _futureYear;  /// Stream to get the steps from pedometer  Stream<StepCount> _stepCountStream;  int currTotalSteps;  int lastTotalSteps;  /// Time Frame Annotations  DateTime startDate = DateTime.now();  DateTime endDate = DateTime.now();  @override  initState() {    super.initState();    if (mounted) {      if (widget.card.cardId == 0) {        print("initPlatformState called!");        initPlatformState();        print("getLastTotalSteps called!");        getLastTotalSteps();      }    }  }  @override  void didChangeDependencies() {    _initialIndex = Provider.of<int>(context);    switch ((widget.card.cardId == 0)        ? widget.initialIndex        : (widget.initialIndex + 1)) {      case 0:        setState(() {          print("_initialIndex changed: $_initialIndex");          _futureWeek = _getFutureWeek();        });        super.didChangeDependencies();        break;      case 1:        setState(() {          print("_initialIndex changed: $_initialIndex");          _futureMonth = _getFutureMonth();        });        super.didChangeDependencies();        break;      case 2:        setState(() {          print("_initialIndex changed: $_initialIndex");          _futureYear = _getFutureYear();        });        super.didChangeDependencies();        break;    }  }  _getFutureWeek() async {    return await Provider.of<UserWellbeingDB>(context, listen: true)        .getLastWeekOfSpecificColumns(id: (widget.card.cardId + 3));  }  _getFutureMonth() async {    return await Provider.of<UserWellbeingDB>(context, listen: true)        .getLastMonthYearSpecificColumns(            ids: [widget.card.cardId + 3], timeframe: "W");  }  _getFutureYear() async {    return await Provider.of<UserWellbeingDB>(context, listen: true)        .getLastMonthYearSpecificColumns(            ids: [widget.card.cardId + 3], timeframe: "m");  }  void onStepCount(StepCount event) {    print(event);    setState(() {      currTotalSteps = event.steps;    });  }  void onStepCountError(error) {    print('onStepCountError: $error');    setState(() {      currTotalSteps = 0;    });  }  void initPlatformState() {    _stepCountStream = Pedometer.stepCountStream;    _stepCountStream.listen(onStepCount).onError(onStepCountError);    if (!mounted) return;  }  void getLastTotalSteps() async {    if (this.mounted) {      final prefs = await SharedPreferences.getInstance();      final pedometerPair = prefs.getStringList(PREV_PEDOMETER_PAIR_KEY);      lastTotalSteps = int.parse(pedometerPair.first);      print("lastTotalSteps: $lastTotalSteps");    }  }  /// Data class for the barchart  BarChartGroupData makeGroupData(    int x,    double y,    double maxY, {    bool isTouched = false,    Color barColor = Colors.lightBlue,    double width = 16,    List<int> showTooltips = const [],  }) {    return BarChartGroupData(      x: x,      barRods: [        BarChartRodData(          y: y,          colors: isTouched ? [Colors.yellow] : [widget.card.color],          width: width,          backDrawRodData: BackgroundBarChartRodData(            show: true,            y: maxYaxis(                cardId: widget.card.cardId,                initialIndex: widget.initialIndex,                dynamicMaxValue: maxY),            colors: [barBackgroundColor],          ),        ),      ],      showingTooltipIndicators: showTooltips,    );  }  /// Passing the data into the Barchart + allow to see the data on touch  BarChartData mainBarData({List<BarChartGroupData> data, double maxY = 0}) {    return BarChartData(      // TODO: Create a Switch-Case statement to get data for week/month/year      maxY: maxYaxis(          cardId: widget.card.cardId,          initialIndex: widget.initialIndex,          dynamicMaxValue: maxY),      minY: 0,      barTouchData: BarTouchData(        touchTooltipData: BarTouchTooltipData(            tooltipBgColor: Colors.blueGrey,            getTooltipItem: (group, groupIndex, rod, rodIndex) {              String weekDayWeekMonth;              // if (widget.card.cardId == 0) {              switch ((widget.card.cardId == 0)                  ? widget.initialIndex                  : (widget.initialIndex + 1)) {                case 0:                  weekDayWeekMonth = weekDayDescription(group);                  break;                case 1:                  var date =                      DateTime.fromMillisecondsSinceEpoch(group.x.toInt());                  var start_date = DateFormat.MMMd().format(                      date.subtract(Duration(days: (date.weekday - 1))));                  var end_date = DateFormat.MMMd().format(                      date.subtract(Duration(days: (-7 + date.weekday))));                  weekDayWeekMonth = "$start_date-\n$end_date\n";                  // weekDayWeekMonth = DateFormat.MMMd().format(                  //     date.subtract(Duration(days: (date.weekday - 1))));                  // weekDayWeekMonth = DateFormat.MMMd().format(                  //     DateTime.fromMillisecondsSinceEpoch(group.x.toInt()));                  break;                case 2:                  weekDayWeekMonth = yearMonthDescription(group);                  break;                default:                  throw Error();              }              /// Popup with the information              return BarTooltipItem(                weekDayWeekMonth + '\n',                TextStyle(                  color: Colors.white,                  fontWeight: FontWeight.bold,                  fontSize: 16,                ),                children: <TextSpan>[                  // TODO: Create a Switch-Case statement to get data for week/month/year                  TextSpan(                    text: (rod.y).toStringAsFixed(2) +                        popupUnits(widget.card.cardId),                    style: TextStyle(                      color: Colors.yellow,                      fontSize: 16,                      fontWeight: FontWeight.w500,                    ),                  ),                ],              );            }),        /// Making on tap dynamic so it disappears after on tap even        touchCallback: (barTouchResponse) {          setState(() {            if (barTouchResponse.spot != null &&                barTouchResponse.touchInput is! PointerUpEvent &&                barTouchResponse.touchInput is! PointerExitEvent) {              touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;            } else {              touchedIndex = -1;            }          });        },      ),      /// Passing the actual data into the BarChart      titlesData: FlTitlesData(        show: true,        bottomTitles: SideTitles(            showTitles: true,            getTextStyles: (value) => const TextStyle(                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),            margin: 16,            // TODO: Create a Switch-Case statement to get data for week/month/year            getTitles: (double value) {              switch ((widget.card.cardId == 0)                  ? widget.initialIndex                  : (widget.initialIndex + 1)) {                case 0:                  return weekXAxisUnits(value);                case 1:                  var date = DateTime.fromMillisecondsSinceEpoch(value.toInt());                  return DateFormat.MMMd().format(                      date.subtract(Duration(days: (date.weekday - 1))));                case 2:                  return yearXAxisUnits(value);                default:                  return " ";              }            }),        /// Y-axis        rightTitles: SideTitles(          showTitles: true,          getTextStyles: (value) => const TextStyle(              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),          margin: 6,          interval: stepSize(              cardId: widget.card.cardId,              initialIndex: widget.initialIndex,              dynamicMaxValue: maxY),        ),        leftTitles: SideTitles(          showTitles: false,        ),      ),      borderData: FlBorderData(        show: false,      ),      barGroups: data,    );  }  Future<dynamic> refreshState() async {    setState(() {});    await Future<dynamic>.delayed(        animDuration + const Duration(milliseconds: 50));  }  double selectWellbeingItem({CardClass card, WellbeingItem wellbeingItem}) {    switch (card.cardId) {      case 0:        // print(        //     "Date ${wellbeingItem.date} | numSteps ${wellbeingItem.numSteps}");        return (wellbeingItem.numSteps == null)            ? 0            : wellbeingItem.numSteps / 1000;      case 1:        // print(        //     "Date ${wellbeingItem.date} | wellbeingScore ${wellbeingItem.wellbeingScore}");        return (wellbeingItem.wellbeingScore == null)            ? 0            : wellbeingItem.wellbeingScore;      case 2:        // print(        //     "Date ${wellbeingItem.date} | sputumColour ${wellbeingItem.sputumColour}");        return (wellbeingItem.sputumColour == null)            ? 0            : wellbeingItem.sputumColour;      case 3:        print(            "Date ${wellbeingItem.date} | mrcDyspnoeaScale ${wellbeingItem.mrcDyspnoeaScale}");        return (wellbeingItem.mrcDyspnoeaScale == null)            ? 0            : wellbeingItem.mrcDyspnoeaScale;      case 4:        // print(        //     "Date ${wellbeingItem.date} | speechRate ${wellbeingItem.speechRate}");        return (wellbeingItem.speechRate == null)            ? 0            : wellbeingItem.speechRate;      default:        print("Error in picking upp the data from DB");        return 10;    }  }  xAxisCase({WellbeingItem wellbeingItem, int initialIndex, int cardId}) {    switch ((cardId == 0) ? initialIndex : (initialIndex + 1)) {      case 0:        return DateTime.parse(wellbeingItem.date).weekday;      case 1:        return int.parse(wellbeingItem.date);      case 2:        return DateTime.parse(wellbeingItem.date).month;    }  }  /// Building a card with a graph  @override  Widget build(BuildContext context) {    // Provider.of<UserWellbeingDB>(context, listen: false)    //     .getLastMonthSpecificColumns(ids: [    //   widget.card.cardId + 3    // ], timeframe: "W").then((item) => item.forEach((element) {    //           print(    //               "${element.date} | ${element.numSteps} | ${element.wellbeingScore}");    //         }));    double getActualSteps() {      final actualSteps = lastTotalSteps > currTotalSteps          ? currTotalSteps          : currTotalSteps - lastTotalSteps;      return actualSteps / 1000;    }    /// Days of the week start with 1 = Monday according to Iso8601    final barGraphWithDataWeek = FutureBuilder(        future: _futureWeek,        builder: (context, snapshot) {          print("Week snapshot.connectionState: ${snapshot.connectionState}");          while (snapshot.connectionState == ConnectionState.waiting) {            print("WeeK Snapshot is waiting....");            return loadingIndicator();          }          Map dataHashMap = Map<int, double>();          for (int i = 0; i < 7; i++) {            dataHashMap[DateTime.now()                .subtract(Duration(days: 6 - i))                .weekday] = 0.toDouble();          }          int barchartIndex = -1;          List<BarChartGroupData> barChartData = [];          if (snapshot.hasData) {            print("WeeKSnapshot has data!");            if (snapshot.data.isNotEmpty) {              print("WeeK Snapshot check: isNotEmpty == true");              final dataFromDB = snapshot.data;              /// TODO: Sort out function for max Y value              List<double> findMax = [];              dataFromDB.forEach((data) => findMax.add(                  selectWellbeingItem(card: widget.card, wellbeingItem: data)));              // final maxYaxis              double maxYaxis = findMax.reduce(max);              if (widget.card.cardId == 0) {                if (maxYaxis < getActualSteps()) {                  maxYaxis = getActualSteps();                }              }              ///Populating HashMap              dataFromDB.forEach((wellbeingItem) {                int weekdayInt = xAxisCase(                    wellbeingItem: wellbeingItem,                    initialIndex: widget.initialIndex,                    cardId: widget.card.cardId);                dataHashMap.update(                    weekdayInt,                    (value) => selectWellbeingItem(                        card: widget.card, wellbeingItem: wellbeingItem));              });              print("Week HashMap: $dataHashMap");              if (widget.card.cardId == 0) {                dataHashMap.update(                    DateTime.now().weekday, (value) => getActualSteps());              }              /// Generating barChartData              dataHashMap.forEach((key, value) {                barChartData.add(makeGroupData(key, (value), maxYaxis,                    isTouched: (barchartIndex += 1) == touchedIndex));              });              return BarChart(                mainBarData(data: barChartData, maxY: maxYaxis),              );            } else if (snapshot.hasError) {              print(snapshot.error);              return Text("Error");            } else {              print("WeeK Snapshot check: isNotEmpty == false");              if (widget.card.cardId == 0) {                dataHashMap.update(                    DateTime.now().weekday, (value) => getActualSteps());              }              dataHashMap.forEach((key, value) {                barChartData.add(makeGroupData(                    key, (value), getActualSteps().toDouble(),                    isTouched: (barchartIndex += 1) == touchedIndex));              });              return BarChart(                mainBarData(data: barChartData),              );            }          } else {            print("WeeK Snapshot has no data!");            return loadingIndicator();          }        });    final barGraphWithDataMonth = FutureBuilder(        future: _futureMonth,        builder: (context, snapshot) {          print("Month snapshot.connectionState: ${snapshot.connectionState}");          while (snapshot.connectionState == ConnectionState.waiting) {            print("Month Snapshot is waiting....");            return loadingIndicator();          }          Map dataHashMap = Map<String, double>();          DateTime nextDate;          if (DateTime.now().weekday == 7) {            nextDate = DateTime.now();          } else {            nextDate = DateTime.now()                .subtract(Duration(days: DateTime.now().weekday - 1));          }          for (int i = 0; i < 35; i++) {            if (i % 7 == 0) {              dataHashMap[nextDate                  .subtract(Duration(days: (28 - i)))                  .toIso8601String()                  .substring(0, 10)] = 0.toDouble();            }          }          int barchartIndex = -1;          List<BarChartGroupData> barChartData = [];          if (snapshot.hasData) {            print("Month Snapshot has data!");            if (snapshot.data.isNotEmpty) {              print("Month Snapshot check: isNotEmpty == true");              final dataFromDB = snapshot.data;              List<double> findMax = [];              dataFromDB.forEach((data) => findMax.add(                  selectWellbeingItem(card: widget.card, wellbeingItem: data)));              double maxYaxis = findMax.reduce(max);              if (widget.card.cardId == 0) {                if (maxYaxis < getActualSteps()) {                  maxYaxis = getActualSteps();                }              }              DateTime lastDate = DateTime.parse(dataFromDB.last.date);              dataHashMap[lastDate                  .subtract(Duration(days: lastDate.weekday - 1))                  .toIso8601String()                  .substring(0, 10)] = 0.toDouble();              print("dataHashMap: $dataHashMap");              ///Populating HashMap              dataFromDB.forEach((wellbeingItem) {                String matchDate = wellbeingItem.date;                DateTime dateFromDb = DateTime.parse(wellbeingItem.date);                print("dateFromDb: $dateFromDb");                if (dateFromDb.weekday != 1) {                  matchDate = dateFromDb                      .subtract(Duration(days: dateFromDb.weekday - 1))                      .toIso8601String()                      .substring(0, 10);                } else {                  matchDate = dateFromDb.toIso8601String().substring(0, 10);                }                dataHashMap.update(                    matchDate,                    (value) => selectWellbeingItem(                        card: widget.card, wellbeingItem: wellbeingItem));              });              print("dataHashMap: $dataHashMap");              if (widget.card.cardId == 0) {                print("Not empty hash map gets triggered");                double value = dataHashMap[DateTime.now()                    .subtract(Duration(days: DateTime.now().weekday - 1))                    .toIso8601String()                    .substring(0, 10)];                dataHashMap[DateTime.now()                    .subtract(Duration(days: DateTime.now().weekday - 1))                    .toIso8601String()                    .substring(0, 10)] = value + getActualSteps();              }              /// Generating barChartData              dataHashMap.forEach((key, value) {                barChartData.add(makeGroupData(                    DateTime.parse(key).millisecondsSinceEpoch, value, maxYaxis,                    isTouched: (barchartIndex += 1) == touchedIndex));              });              return BarChart(                mainBarData(data: barChartData, maxY: maxYaxis),              );            } else if (snapshot.hasError) {              print(snapshot.error);              return Text("Error");            } else {              print("Month Snapshot check: isNotEmpty == false");              dataHashMap[DateTime.now()                  .subtract(Duration(days: DateTime.now().weekday - 1))                  .toIso8601String()                  .substring(0, 10)] = 0.toDouble();              if (widget.card.cardId == 0) {                dataHashMap.update(                    DateTime.now()                        .subtract(Duration(days: DateTime.now().weekday - 1))                        .toIso8601String()                        .substring(0, 10),                    (value) => getActualSteps());              }              dataHashMap.forEach((key, value) {                print("key $key, value: $value");              });              /// Generating barChartData              dataHashMap.forEach((key, value) {                barChartData.add(makeGroupData(                    DateTime.parse(key).millisecondsSinceEpoch,                    value,                    (widget.card.cardId == 0) ? getActualSteps() : 0,                    isTouched: (barchartIndex += 1) == touchedIndex));              });              return BarChart(                mainBarData(data: barChartData, maxY: 10),              );            }          } else {            print("Snapshot has no data!");            return loadingIndicator();          }        });    final barGraphWithDataYear = FutureBuilder(        future: _futureYear,        builder: (context, snapshot) {          print("Year snapshot.connectionState: ${snapshot.connectionState}");          while (snapshot.connectionState == ConnectionState.waiting) {            print("Snapshot is waiting....");            return loadingIndicator();          }          Map dataHashMap = Map<int, double>();          for (int i = 0; i < 12; i++) {            dataHashMap[DateTime.utc(DateTime.now().year,                    DateTime.now().month - (11 - i), DateTime.now().day)                .month] = 0.toDouble();          }          int barchartIndex = -1;          List<BarChartGroupData> barChartData = [];          if (snapshot.hasData) {            print("Snapshot has data!");            if (snapshot.data.isNotEmpty) {              print("Snapshot check: isNotEmpty == true");              final dataFromDB = snapshot.data;              List<double> findMax = [];              dataFromDB.forEach((data) => findMax.add(                  selectWellbeingItem(card: widget.card, wellbeingItem: data)));              double maxYaxis = findMax.reduce(max);              if (widget.card.cardId == 0) {                if (maxYaxis < getActualSteps()) {                  maxYaxis = getActualSteps();                }              }              ///Populating HashMap              dataFromDB.forEach((wellbeingItem) {                int weekdayInt = xAxisCase(                    wellbeingItem: wellbeingItem,                    initialIndex: widget.initialIndex,                    cardId: widget.card.cardId);                dataHashMap.update(                    weekdayInt,                    (value) => selectWellbeingItem(                        card: widget.card, wellbeingItem: wellbeingItem));              });              if (widget.card.cardId == 0) {                print("Not empty hash map gets triggered");                double value = dataHashMap[DateTime.now().month];                dataHashMap[DateTime.now().month] = value + getActualSteps();              }              /// Generating barChartData              dataHashMap.forEach((key, value) {                barChartData.add(makeGroupData(key, (value), maxYaxis,                    isTouched: (barchartIndex += 1) == touchedIndex));              });              print("Year dataHashMap: $dataHashMap");              return BarChart(                mainBarData(data: barChartData, maxY: maxYaxis),              );            } else if (snapshot.hasError) {              print(snapshot.error);              return Text("Error");            } else {              print("Year Snapshot check: isNotEmpty == false");              if (widget.card.cardId == 0) {                dataHashMap.update(                    DateTime.now().month, (value) => getActualSteps());              }              // dataHashMap[DateTime.now().month] = getActualSteps();              dataHashMap.forEach((key, value) {                barChartData.add(makeGroupData(key, (value),                    (widget.card.cardId == 0) ? getActualSteps() : 0,                    isTouched: (barchartIndex += 1) == touchedIndex));              });              return BarChart(                mainBarData(data: barChartData),              );            }          } else {            print("Snapshot has no data!");            return loadingIndicator();          }        });    barChartDataDisplay({int cardId, int initialIndex}) {      switch ((cardId == 0) ? initialIndex : (initialIndex + 1)) {        case 0:          print("Week data future builder");          return barGraphWithDataWeek;        case 1:          print("Month data future builder");          return barGraphWithDataMonth;        case 2:          print("Year data future builder");          return barGraphWithDataYear;      }    }    return barChartDataDisplay(        cardId: widget.card.cardId, initialIndex: widget.initialIndex);  }}