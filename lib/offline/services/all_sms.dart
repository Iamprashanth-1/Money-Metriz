import 'package:telephony/telephony.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';

import 'dart:core';

import 'dart:async';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // If _database is null, instantiate it.
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Construct the path to the database
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'sms_db.db');

    // Open the database
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create the table
    await db.execute('''
      CREATE TABLE if not exists sms_data (
        id INTEGER  PRIMARY KEY,
        bankName TEXT,
        accountNumber TEXT,
        transType TEXT,
        creditAmount float,
        debitAmount float,
        availableBalance float,
        transDate timestamp,
        date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE if not exists sms_max_time (
        id INTEGER  PRIMARY KEY,
        date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE if not exists sms_accounts (
        id INTEGER  PRIMARY KEY,
        accountNumber TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> queryAll(filters) async {
    Database db = await database;

    return await db.rawQuery(
        "SELECT *,strftime('%Y', transDate) as year_col FROM sms_data WHERE 1=1 $filters order by transDate desc ");
  }

  Future<List<Map<String, dynamic>>> rawquery(query) async {
    Database db = await database;
    return await db.rawQuery(query);
  }

  Future remove(accounts) async {
    print(accounts);
    Database db = await database;
    await db
        .delete('sms_data', where: 'accountNumber = ?', whereArgs: [accounts]);
    await db.delete('sms_accounts',
        where: 'accountNumber = ?', whereArgs: [accounts]);
    await db.delete('sms_max_time',
        where: 'accountNumber = ?', whereArgs: [accounts]);

    return '';
  }

  Future<void> rawinsert(list) async {
    Database db = await database;
    Batch batch = db.batch();

    // for (var li in list) {
    //   await db
    //       .rawInsert("Insert into sms_accounts(accountNumber) values ('$li')");
    // }
    for (String item in list) {
      batch.insert('sms_accounts', {'accountNumber': item});
    }
    batch.commit();
  }
}

Future<String> loadJsonAsset(String assetPath) async {
  return await rootBundle.loadString(assetPath);
}

getallbanksdata() async {
  var jsonString = await loadJsonAsset('assets/data.json');
  Map<String, dynamic> data = json.decode(jsonString);
  return data;

  Map<dynamic, dynamic> jsonMap = jsonDecode(jsonString);
  List<dynamic> valueList = List.from(jsonMap.values);

  return valueList.toList();
}

Future<String> getValues(bankname) async {
  Map<String, dynamic> jsonData = await getallbanksdata();
  List<dynamic> values = jsonData.values.toList();

  for (var s in values) {
    if (bankname.toLowerCase().contains(s.toLowerCase())) {
      return s;
      break;
    }
  }
  return '';
}

// var banks = getValues();

Map<dynamic, dynamic> parse_sms(mssg, bankname) {
  String message = mssg;
  bool accountexists = true;
  String accountNumbers = '';
  RegExp floatRegex = RegExp(r'\d+\.\d{2}');
  List nmessage;
  Iterable<RegExpMatch> matches = floatRegex
      .allMatches(message.replaceAll(',', '').replaceAll(RegExp(r'\s+'), ' '));
  RegExp fg = RegExp(r'\b\d+(?:,\d{3})*(?:\.\d+)?\b');
  RegExp bal = RegExp(r"(?<=bal(?:ance)?\s).*");

  RegExp bankacc = RegExp(r'(?<=a\/c |acct |Account )\b[a-zA-Z\d]+|\*\*[\d]+',
      caseSensitive: false);

  String duplicmssg = message
      .replaceAll('no.', '')
      .replaceAll('no', '')
      .replaceAll(RegExp(r'\s+'), ' ');
  Iterable<RegExpMatch> bankaccmatch = bankacc.allMatches(duplicmssg);
  List<String> accou =
      bankaccmatch.map((match) => match.group(0) ?? '').toList();
  for (var acc in accou) {
    if (acc == 'is') {
      accountexists = false;
    } else {
      bool hasDigit = RegExp(r"\d").hasMatch(acc);
      if (hasDigit) {
        accountNumbers = acc.substring(acc.length - 3);
        break;
      }
    }
  }

  // List<String> floatValues =
  //     matches.map((match) => match.group(0) ?? '').toList();
  // print(floatValues);
  Map<dynamic, dynamic> all_data = {
    "accountNumber": '',
    "bankName": '',
    "creditAmount": 0.0,
    "debitAmount": 0.0,
    "availableBalance": 0.0
  };

  if (message.toLowerCase().contains('otp')) {
    return all_data;
  }
  nmessage = message.replaceAll(',', ' ').split(' ');
  String km = 'XXX';
  bool credit_first_val = false;
  bool debit_first_val = false;
  bool available_balance = false;
  bool available_balance_bool = false;
  List floatValues = [];
  for (var i in nmessage) {
    if (i.contains('-') ||
        i.contains(':') ||
        i.contains('X') ||
        i.contains('*')) {
      continue;
    } else {
      Iterable<RegExpMatch> matc =
          fg.allMatches(i.replaceAll(',', '').replaceAll('INR', ' '));
      List<String> floa = matc.map((match) => match.group(0) ?? '').toList();
      if (floa.isNotEmpty) {
        var ks = floa[0].toString().split('.')[0];
        if (ks.toString().length < 10) {
          floatValues = floatValues + floa;
        }
      }
    }
  }
  double availableBalance_final = 0.0;
  try {
    if (message.toLowerCase().contains('bal')) {
      available_balance_bool = true;
      Match? match = bal.firstMatch(message.toLowerCase().replaceAll(':', ''))!;
      String? srf = match.group(0)!;
      srf = srf.toLowerCase();
      srf = srf
          .replaceAll('inr', '')
          .replaceAll('inr.', '')
          .replaceAll('rs', '')
          .replaceAll('rs.', '');
      List mhg = srf.split(' ');
      for (var ks in mhg) {
        bool foundbal = false;
        RegExp regExp = RegExp(r"([A-Z]{2,3})?[\s]?(\d+(\.\d{1,2})?)");
        Iterable<Match> matches = regExp.allMatches(ks);

        for (Match match in matches) {
          String matchString = match.group(0)!;

          double doubleValue = double.tryParse(matchString) ?? 0.0;
          if (doubleValue != 0.0) {
            foundbal = true;
            availableBalance_final = doubleValue;
            break;
          }
        }
        if (foundbal) {
          break;
        }
      }
    }
  } catch (e) {}
  if (accountNumbers.isNotEmpty) {
    all_data['accountNumber'] = accountNumbers.replaceAll('.', '');
  } else {
    all_data['accountNumber'] = '';
  }
  for (var i in nmessage) {
    // if (i.toLowerCase().contains("XX".toLowerCase()) ||
    //     i.toLowerCase().contains("**".toLowerCase())) {
    //   all_data['accountNumber'] = i;
    //   continue;
    // }
    if (all_data['debitAmount'] != 0.0 || all_data['creditAmount'] != 0.0) {
      break;
    }

    if (i is String) {
      if (i.toLowerCase().contains('debit') ||
          i.toLowerCase().contains('sent') ||
          i.toLowerCase().contains('withdraw') ||
          i.toLowerCase().contains('paid')) {
        debit_first_val = true;
        all_data['transType'] = 'DEBIT';
        continue;
      } else if (i.toLowerCase().contains('credite') && !debit_first_val) {
        credit_first_val = true;
        all_data['transType'] = 'CREDIT';
        continue;
      }
    }
    if (debit_first_val) {
      all_data['debitAmount'] = floatValues[0];
      debit_first_val = false;
      available_balance = true;
      credit_first_val = false;
      continue;
    }
    if (credit_first_val) {
      all_data['creditAmount'] = floatValues[0];
      credit_first_val = false;
      available_balance = true;
      debit_first_val = false;
      continue;
    }
  }

  if (available_balance && available_balance_bool) {
    try {
      all_data['availableBalance'] = availableBalance_final;
      available_balance = false;
    } catch (e) {}
    ;
  }

  return all_data;
}

final Telephony telephony = Telephony.instance;

queryAndStoreSMS(last_time_stamp) async {
  var permissionsGranted = await telephony.requestSmsPermissions;
  if (permissionsGranted is Null) {
    print('Permissions not granted');
    return;
  }
  Database db = await DatabaseHelper().database;
  // List allaccounts = [];
  // await db.rawQuery('select * from sms_accounts').then((value) {
  //   if (value.isEmpty) {
  //     print('No accounts found');
  //     return;
  //   }
  //   for (var i in value) {
  //     allaccounts.add(i['accountNumber']);
  //   }
  // });
  print(last_time_stamp);

  // Get all SMS messages from the device
  List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      filter: SmsFilter.where(SmsColumn.DATE)
          .greaterThan(last_time_stamp.toString()),
      sortOrder: [
        OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        OrderBy(SmsColumn.BODY)
      ]);

  // Insert each SMS message into the database

  int? sms_max_date = 0;
  for (SmsMessage message in messages) {
    int? sdate = message.date;
    if (sms_max_date! < sdate!) {
      sms_max_date = message.date;
    }
    try {
      var bankName = await getValues(message.address);
      if (bankName.isNotEmpty) {
        Map<dynamic, dynamic> finalData =
            parse_sms(message.body, message.address);
        // print(finalData);

        if (finalData.containsKey('accountNumber') &&
            (finalData['creditAmount'] != 0.0 ||
                finalData['debitAmount'] != 0.0) &&
            finalData.containsKey('transType')) {
          await db.rawInsert(
              "INSERT INTO sms_data(bankName, accountNumber, transType,creditAmount,debitAmount,availableBalance,transDate,date) VALUES('${bankName.toString()}','${finalData['accountNumber'].toString()}','${finalData['transType'].toString()}',${double.parse(finalData['creditAmount'].toString())},${double.parse(finalData['debitAmount'].toString())},${double.parse(finalData['availableBalance'].toString())}, datetime(${message.date}/1000, 'unixepoch', 'localtime') ,'${message.date}')");
        }
      }

      // await db.insert(
      //   'sms',
      //   {
      //     'address': message.address,
      //     'body': message.body,
      //     'date': message.date,
      //   },
      //   conflictAlgorithm: ConflictAlgorithm.replace,
      // );
    } catch (e) {
      print(e);
    }
  }

  await db.rawInsert("Insert into sms_max_time(date) values('$sms_max_date')");
  print('Done');
  // Close the database
  // await db.close();
}

Future _openDatabase() async {
  final database = openDatabase(
    // Path to database file
    join(await getDatabasesPath(), 'sms_db.db'),

    // Version of the database schema
    onCreate: (db, version) {
      // SQL code to create the table
      return db.execute(
        'CREATE TABLE my_table(id INTEGER PRIMARY KEY, name TEXT)',
      );
    },

    // Increase the version number if you need to update the database schema
    version: 1,
  );
  return database;
}

// Query the database
getdata(query) async {
  final database = await _openDatabase();

  // final List<Map<String, dynamic>> results = await database.query(
  //   'sms_data',
  //   // Columns to retrieve
  //   columns: [
  //     'bankName',
  //     'accountNumber',
  //     'transType',
  //     'creditAmount',
  //     'debitAmount',
  //     'availableBalance',
  //     'date'
  //   ],

  //   // LIMIT clause
  //   limit: 3000,
  // );
  final res = await database.rawQuery(query);
  // print(res);
  return res.toList();
  print(res);
  // for (Map<String, Object> dataMap in res) {
  //   dataMap.forEach((key, value) {
  //     print('$key: $value');
  //   });
  // }
  // print(res.rows);

// Iterate over the results and print them
  // for (final row in res) {
  //   print(
  //       'id: ${row['bankName']}, name: ${row['accountNumber']} , name: ${row['transType']} , name: ${row['creditAmount']} , name: ${row['debitAmount']} , name: ${row['availableBalance']} , name: ${row['date']}');
  // }
}

// import 'package:sms/sms.dart';

// void queryAndStoreSMSByDate() async {
//   // Create an SmsQuery object
//   final SmsQuery query = SmsQuery();
//       final List<Map<String, dynamic>> smsList = await querySmsMessages();

//   // Filter SMS messages by date range
//   final List<SmsMessage> messages = await query.querySms(
//     kinds: [SmsQueryKind.Inbox],
//     count: 10,
//     sort: true,
//   );

//   // Open the SQLite database
//   final Database db = await openDatabase('sms_database.db', version: 1,
//       onCreate: (Database db, int version) async {
//     // Create the SMS table
//     await db.execute('''
//       CREATE TABLE sms (
//         id INTEGER PRIMARY KEY,
//         address TEXT,
//         body TEXT,
//         date TEXT
//       )
//     ''');
//   });

//   // Insert each SMS message into the database
//   for (SmsMessage message in messages) {
//     print(message.date);
//     print(message.body);
//     await db.insert('sms', {
//       'address': message.address,
//       'body': message.body,
//       'date': message.date.toString(),
//     });
//   }

//   // Close the database
//   await db.close();
// }
