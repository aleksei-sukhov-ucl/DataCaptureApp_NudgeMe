import 'package:nudge_me/model/user_model.dart';

generateMonthlyHashMap() {
  Map dataHashMap = Map<String, double>();
  DateTime nextDate;
  nextDate =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  for (int i = 0; i < 35; i++) {
    if (i % 7 == 0) {
      dataHashMap[nextDate
          .subtract(Duration(days: (28 - i)))
          .toIso8601String()
          .substring(0, 10)] = 0.toDouble();
    }
  }
  return dataHashMap;
}

Map<String, List<double>> generateMonthlyHashMapExport() {
  Map dataHashMap = Map<String, List<double>>();
  DateTime nextDate;
  nextDate =
      DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  for (int i = 0; i < 35; i++) {
    if (i % 7 == 0) {
      dataHashMap[nextDate
          .subtract(Duration(days: (28 - i)))
          .toIso8601String()
          .substring(0, 10)] = <double>[];
    }
  }
  return dataHashMap;
}

generateYearlyHashMap() {
  Map dataHashMap = Map<int, double>();
  for (int i = 0; i < 12; i++) {
    dataHashMap[
        DateTime.utc(DateTime.now().year, DateTime.now().month - (11 - i), 1)
            .month] = 0.toDouble();
  }
  return dataHashMap;
}

/// Fetching data from DB for particular wellbeing metrics
double selectWellbeingItem({int cardId, WellbeingItem wellbeingItem}) {
  switch (cardId) {
    case 0:
      return (wellbeingItem.numSteps == null)
          ? 0
          : wellbeingItem.numSteps / 1000;
    case 1:
      return (wellbeingItem.wellbeingScore == null)
          ? 0
          : wellbeingItem.wellbeingScore;
    case 2:
      return (wellbeingItem.sputumColour == null)
          ? 0
          : wellbeingItem.sputumColour;
    case 3:
      return (wellbeingItem.mrcDyspnoeaScale == null)
          ? 0
          : wellbeingItem.mrcDyspnoeaScale;
    case 4:
      return (wellbeingItem.speechRate == null) ? 0 : wellbeingItem.speechRate;
    default:
      print("Error in picking upp the data from DB");
      return 10;
  }
}

populateWeeklyHashMapWithDataFromDB(Map<String, List<double>> hashMap,
    List<WellbeingItem> dataFromDB, int cardId) {
  ///Populating HashMap
  dataFromDB.forEach((wellbeingItem) {
    String matchDate = wellbeingItem.date;
    DateTime dateFromDb = DateTime.parse(wellbeingItem.date);

    if (dateFromDb.weekday != 1) {
      matchDate = dateFromDb
          .subtract(Duration(days: dateFromDb.weekday - 1))
          .toIso8601String()
          .substring(0, 10);
    } else {
      matchDate = dateFromDb.toIso8601String().substring(0, 10);
    }

    hashMap[matchDate].add(double.parse(
        selectWellbeingItem(cardId: cardId, wellbeingItem: wellbeingItem)
            .toStringAsFixed(2)));
  });

  return hashMap;
}
