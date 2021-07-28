import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/utils/utils.dart';

const _dbName = "wellbeing_items_db.db";

// versions could be used to change the database schema once the app is
// already released (since you cannot ask users to reinstall the app)
const _dbVersion = 3;

const _tableName = "WellbeingItems";
const _columns = [
  "id",
  "date",
  "postcode",
  "numSteps",
  "wellbeingScore",
  "sputumColour",
  "mrcDyspnoeaScale",
  "speechRate",
  "speechRateTest",
  "testDuration",
  "audioURL",
  "support_code"
];

/// Singleton [ChangeNotifier] to read/write to DB.
/// Stores the user's wellbeing scores and steps.
class UserWellbeingDB extends ChangeNotifier {
  UserWellbeingDB._(); // private constructor
  static final UserWellbeingDB _instance = UserWellbeingDB._();
  static Database _database;

  factory UserWellbeingDB() =>
      _instance; // factory so we don't return new instance

  /// inserts a wellbeing record.
  /// returns the id of the newly inserted record
  Future<int> insert(WellbeingItem item) async {
    final db = await database;
    final id = await db.insert(_tableName, item.toMap());
    notifyListeners();
    return id;
  }

  Future<int> update({int columnId, value, String Date}) async {
    final db = await database;
    // row to update
    Map<String, dynamic> row = {_columns[columnId]: value};

    final count = await db.update(_tableName, row,
        where: '${_columns[1]} = ?', whereArgs: [Date]);

    notifyListeners();
    print("count from SQL: $count");
    return count;
  }

  Future<int> updateSpeechTest(
      {currentValueSpeechRateTest,
      currentValueTestDuration,
      currentValueSpeechRate,
      currentValueAudioURL,
      Date}) async {
    final db = await database;

    // "speechRate",
    // "speechRateTest",
    // "testDuration",
    // "audioURL"

    Map<String, dynamic> row = {
      _columns[7]: currentValueSpeechRate,
      _columns[8]: currentValueSpeechRateTest,
      _columns[9]: currentValueTestDuration,
      _columns[10]: currentValueAudioURL
    };

    final id = await db.update(_tableName, row,
        where: '${_columns[1]} = ?', whereArgs: [Date]);
    notifyListeners();
    return id;
  }

  /// inserts a [WellbeingItem] constructed with the given data.
  /// returns the id of the newly inserted record

  Future<int> insertWithData(
      {date: String,
      postcode: String,
      wellbeingScore: double,
      numSteps: int,
      sputumColour: double,
      mrcDyspnoeaScale: double,
      speechRate: double,
      speechRateTest: int,
      testDuration: double,
      audioURL: String,
      supportCode: String}) async {
    // assert(wellbeingScore != null);
    return insert(
      WellbeingItem(
          id: null,
          date: date,
          postcode: postcode,
          wellbeingScore: wellbeingScore,
          numSteps: numSteps,
          sputumColour: sputumColour,
          mrcDyspnoeaScale: mrcDyspnoeaScale,
          speechRate: speechRate,
          speechRateTest: speechRateTest,
          testDuration: testDuration,
          audioURL: audioURL,
          supportCode: supportCode),
    );
  }

  /// returns up to n wellbeing items
  Future<List<WellbeingItem>> getLastNWeeks(int n) async {
    final db = await database;
    List<Map> wellbeingMaps = await db.query(_tableName,
        columns: _columns, orderBy: "${_columns[1]} DESC", limit: n);

    for (var value in wellbeingMaps) {
      print("getLastNWeeks: $value");
    }
    final itemList = wellbeingMaps
        .map((wellbeingMap) => WellbeingItem.fromMap(wellbeingMap))
        .toList(growable: false);

    itemList.sort((a, b) => a.id.compareTo(b.id));
    return itemList;
  }

  /// returns last week day-by-day data
  Future<List<WellbeingItem>> getLastWeekOfSpecificColumns({int id}) async {
    final db = await database;

    /// Generating a list of columns we want to get
    List<String> allNeededColumns = ["${_columns[1]}", "${_columns[id]}"];
    // print("allNeededColumns: $allNeededColumns");

    /// Genrating start and end date
    final startDate = DateTime.now().toIso8601String().substring(0, 10);
    final endDate = DateTime.now()
        .subtract(Duration(days: 6))
        .toIso8601String()
        .substring(0, 10);
    List<Map> wellbeingMaps = await db.query(
      _tableName,
      columns: allNeededColumns,
      where: '''date BETWEEN '$endDate' AND '$startDate' ''',
      orderBy: "${allNeededColumns[0]}",
      // groupBy: "[date]"
    );

    wellbeingMaps.forEach((element) {
      print("getLastWeekOfSpecificColumns: $element");
    });

    final itemList = wellbeingMaps
        .map((wellbeingMap) => WellbeingItem.fromMap(wellbeingMap))
        .toList();
    return itemList;
  }

  /// returns data either for Month or Year
  ///  input W for week
  ///  input m for month (keep lowercase)
  ///  Shows month data by default
  Future<List<WellbeingItem>> getLastMonthYearSpecificColumns(
      {List<int> ids, String timeframe = "W"}) async {
    final db = await database;

    /// string of columns
    List<String> listOfColumns = [];
    ids.forEach((id) => listOfColumns.add("${_columns[id]}"));

    /// Generating a list of columns we want to get
    List<String> allNeededColumns = [];
    ids.forEach((id) => (id == 3)
        ? allNeededColumns.add("sum(${_columns[id]}) as ${_columns[id]}")
        : allNeededColumns.add("avg(${_columns[id]}) as ${_columns[id]}"));

    /// Genrating start and end date
    final startDate = DateTime.now().toIso8601String().substring(0, 10);
    String endDate = "";
    if (timeframe == "W") {
      if (DateTime.now().weekday == 7) {
        endDate = DateTime.now()
            .subtract(Duration(days: 21))
            .toIso8601String()
            .substring(0, 10);
      } else {
        endDate = DateTime.now()
            .subtract(Duration(days: DateTime.now().weekday))
            .subtract(Duration(days: 21))
            .toIso8601String()
            .substring(0, 10);
      }
    } else {
      endDate = DateTime.utc(
              DateTime.now().year - 1, DateTime.now().month, DateTime.now().day)
          .toIso8601String()
          .substring(0, 10);
    }

    List<Map> wellbeingMaps = await db.rawQuery('''
            SELECT STRFTIME('%$timeframe',date) as IsoSting, date, ${allNeededColumns.join(", ")}
            FROM $_tableName
            WHERE date BETWEEN '$endDate' AND '$startDate' 
            GROUP BY STRFTIME('%$timeframe',date)
            ORDER BY date
            ''');

    print(startDate);
    wellbeingMaps.forEach((element) {
      print("$element");
    });

    final itemList = wellbeingMaps
        .map((wellbeingMap) => WellbeingItem.fromMap(wellbeingMap))
        .toList();

    return itemList;
  }

  ///Get overall trends for all the data - grouped by weeks
  Future<List<WellbeingItem>> getOverallTrendsForPastFourMonth(
      numbOfMonth) async {
    final db = await database;
    final startDate = DateTime.now().toIso8601String().substring(0, 10);
    final endDate = DateTime.utc(DateTime.now().year,
            DateTime.now().month - numbOfMonth, DateTime.now().day)
        .toIso8601String()
        .substring(0, 10);
    List<Map> wellbeingMaps = await db.rawQuery('''
    SELECT STRFTIME('%W',date) as IsoSting,
    date,
    sum(numSteps) as numSteps,
    avg(wellbeingScore) as wellbeingScore,
    avg(sputumColour) as sputumColour,
    avg(mrcDyspnoeaScale) as mrcDyspnoeaScale,
    avg(speechRate) as speechRate
    FROM $_tableName
    WHERE date BETWEEN '$endDate' AND '$startDate' 
    GROUP BY STRFTIME('%W',date)
    ''');

    wellbeingMaps.forEach((element) {
      print("$element");
    });

    final itemList = wellbeingMaps
        .map((wellbeingMap) => WellbeingItem.fromMap(wellbeingMap))
        .toList(growable: false);

    return itemList;
  }

  void delete() async {
    final base = await getDatabasesPath();
    deleteDatabase(join(base, _dbName));
    _database = null; // will be created next time its needed
    notifyListeners();
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await _init();
    }
    return _database;
  }

  /// returns `true` if there are 0 rows in the DB
  Future<bool> get empty async {
    final db = await database;
    return firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $_tableName')) ==
        0;
  }

  Future<bool> getDataAlreadyExists({String checkDate}) async {
    final db = await database;
    return firstIntValue(await db.rawQuery('''SELECT EXISTS(SELECT 1 
               FROM $_tableName 
               WHERE date="$checkDate");''')) == 1;
  }

  Future<Database> _init() async {
    final dir = await getDatabasesPath();
    final dbPath = join(dir, _dbName);
    return openDatabase(dbPath, version: _dbVersion, onCreate: _onCreate);
  }

  /// Creates the DB and is call above in _init()
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
      ${_columns[0]} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${_columns[1]} TEXT,
      ${_columns[2]} TEXT,
      ${_columns[3]} INTEGER,
      ${_columns[4]} DOUBLE,
      ${_columns[5]} DOUBLE,
      ${_columns[6]} DOUBLE,
      ${_columns[7]} DOUBLE,
      ${_columns[8]} INTEGER,
      ${_columns[9]} DOUBLE,    
      ${_columns[10]} TEXT,
      ${_columns[11]} TEXT
    )
      ''');
    /*"id",
      "date",
      "postcode",
      "numSteps",
      "wellbeingScore",
      "sputumColour",
      "mrcDyspnoeaScale",
      "speechRate",
      "speechRateTest",
      "testDuration",
      "audioURL",
      "support_code"*/
  }
}

/// Data item of a week's wellbeing record.
class WellbeingItem {
  int id;
  String date;
  String postcode; // it's possible that the user moves house
  int numSteps;
  double wellbeingScore;
  double sputumColour;
  double mrcDyspnoeaScale;
  double speechRate;
  int speechRateTest;
  double testDuration;
  String audioURL;
  String supportCode;

  WellbeingItem(
      {this.id, // this should prob be left null so SQL will handle it
      this.date,
      this.postcode,
      this.numSteps,
      this.wellbeingScore,
      this.sputumColour,
      this.mrcDyspnoeaScale,
      this.speechRate,
      this.speechRateTest,
      this.testDuration,
      this.audioURL,
      this.supportCode});

  WellbeingItem.fromMap(Map<String, dynamic> map) {
    id = map[_columns[0]];
    date = map[_columns[1]];
    postcode = map[_columns[2]];
    numSteps = map[_columns[3]];
    wellbeingScore = map[_columns[4]];
    sputumColour = map[_columns[5]];
    mrcDyspnoeaScale = map[_columns[6]];
    speechRate = map[_columns[7]];
    speechRateTest = map[_columns[8]];
    testDuration = map[_columns[9]];
    audioURL = map[_columns[10]];
    supportCode = map[_columns[11]];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      // id might be null
      _columns[1]: date,
      _columns[2]: postcode,
      _columns[3]: numSteps,
      _columns[4]: wellbeingScore,
      _columns[5]: sputumColour,
      _columns[6]: mrcDyspnoeaScale,
      _columns[7]: speechRate,
      _columns[8]: speechRateTest,
      _columns[9]: testDuration,
      _columns[10]: audioURL,
      _columns[11]: supportCode,
    };
    if (id != null) {
      map[_columns[0]] = id;
    }
    return map;
  }
}
