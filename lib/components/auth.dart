import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../services/appwrite.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'dart:convert';
import '../screens/login.dart';
import '../utils.dart';

class AuthService {
  final Account _account = Account(Appwrite.instance.client);
  final _storage = Storage(Appwrite.instance.client);
  // final _user = Users.Users(Appwrite.instance.client as Users.Client);

  final String databaseId = '6464d86842d0a340597d';
  // final String collectionId = '64759c4e737497dbb488';
  final String _unAuthMessage =
      "AppwriteException: user_unauthorized, The current user is not authorized to perform the requested action. (401)";

  Future<models.Account> signUp(
      {String? name, required String email, required String password}) async {
    await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    return login(email: email, password: password);
  }

  Future<models.Account> login(
      {required String email, required String password}) async {
    try {
      var userData = await _account.createEmailSession(
        email: email,
        password: password,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userData.userId);
    } catch (e) {
    } finally {}

    return _account.get();
  }

  Future uploadUserImage(bytes, fileName) async {
    final file = await _storage.createFile(
      bucketId: userProfileBucketId!,
      fileId: ID.unique(),
      file: InputFile.fromBytes(bytes: bytes, filename: fileName),
    );
    try {
      return file.toMap()['\$id'];
    } catch (e) {
      return '';
    }
    print(file.toMap());
  }

  Future getProfileView(fileId) async {
    final file = await _storage.getFileView(
        fileId: fileId, bucketId: userProfileBucketId!);
    // print(file);
    return file;
  }

  Future<void> logout() async {
    await removeuserSession();
    return _account.deleteSession(sessionId: 'current');
  }

  Future<void> removeuserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future getuser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String text = prefs.getString('userId') ?? '';
    return text.toString();
  }

  Future<models.Document> insertDocument(
      {required Map<String, dynamic> data, collectionId}) async {
    var userId = await getuser();
    data['userId'] = userId;
    return Databases(Appwrite.instance.client).createDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: ID.unique(),
      data: data,
    );
  }

  // Future updateUserPassword(password) async {
  //   var userId = await getuser();
  //   User result = await _user.updatePassword(
  //     userId: userId,
  //     password: password,
  //   );
  //   return '';
  // }

  Future checkmonthlybudgetadded(String monthyear) async {
    var userId = await getuser();
    final result = await Databases(Appwrite.instance.client).listDocuments(
        databaseId: databaseId,
        collectionId: monthlyBudgetCollectionId!,
        queries: [
          Query.equal("userId", [userId]),
          Query.equal("monthYear", [monthyear])

          // Query.orderDesc("updatedAt"),
        ]);
    List<Map<String, dynamic>> documents = [];
    result.documents.forEach((element) {
      documents.add(element.data);
    });
    if (documents.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future updateDocument(collectionId, documentId, data) async {
    // var userId = await getuser();
    return Databases(Appwrite.instance.client).updateDocument(
      databaseId: databaseId,
      collectionId: collectionId,
      documentId: documentId,
      data: data,
    );
  }

  Future getStorageDocument(_StorageCollectionId, context) async {
    var userId = await getuser();
    try {
      var result = await Databases(Appwrite.instance.client).listDocuments(
        databaseId: databaseId,
        collectionId: _StorageCollectionId,
        queries: [
          Query.equal("userId", [userId]),
        ],
      );
      List<Map<String, dynamic>> documents = [];
      result.documents.forEach((element) {
        documents.add(element.data);
      });
      documents.sort((a, b) => b["\$createdAt"].compareTo(a["\$createdAt"]));

      if (documents.length > 0) {
        return documents[0]['feildId'];
      } else {
        return '';
      }
    } catch (e) {
      return Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  Future getAuthStatus() async {
    final authNotifier = await _account.getSession(sessionId: 'current');
    try {
      return authNotifier.current;
    } catch (e) {
      return 'False';
    }
  }

  Future getDocuments(collectionId, year, month, context) async {
    var userId = await getuser();
    try {
      final result = await Databases(Appwrite.instance.client).listDocuments(
          databaseId: databaseId,
          collectionId: collectionId,
          queries: [
            Query.equal("userId", [userId]),
            // Query.greaterThanEqual("createdAt", '2021-09-01T00:00:00Z'),
            // Query.lessThanEqual("createdAt", '2023-09-30T00:00:00Z'),
            // Query.orderDesc("updatedAt"),
          ]);
      List<Map<String, dynamic>> documents = [];
      result.documents.forEach((element) {
        var tempdate = DateTime.parse(element.data['createdAt']);
        if (year != null && month != null) {
          if (tempdate.year.toString() == year.toString() &&
              tempdate.month.toString() == month.toString()) {
            documents.add(element.data);
          }
        }
        // if (tempdate.year == int.parse(year) &&
        //     tempdate.month == int.parse(month)) {
        //   print('juu');
        //   documents.add(element.data);
        // }
        // documents.add(element.data);
      });
      // print(documents);

      documents.sort((a, b) => b["createdAt"].compareTo(a["createdAt"]));

      return documents;
    } catch (e) {
      if (e.toString().contains('unauthorized')) {
        StatusMessagePopup(
                message: 'Session Expired', duration: Duration(seconds: 2))
            .show(context);
        await removeuserSession();
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    }
  }

  Future getDocumentsForCurrentYear(collectionId, year, context) async {
    var userId = await getuser();
    try {
      final result = await Databases(Appwrite.instance.client).listDocuments(
          databaseId: databaseId,
          collectionId: collectionId,
          queries: [
            Query.equal("userId", [userId]),
            // Query.greaterThanEqual("createdAt", '2021-09-01T00:00:00Z'),
            // Query.lessThanEqual("createdAt", '2023-09-30T00:00:00Z'),
            // Query.orderDesc("updatedAt"),
          ]);
      List<Map<String, dynamic>> documents = [];
      result.documents.forEach((element) {
        var tempdate = DateTime.parse(element.data['createdAt']);
        if (year != null) {
          if (tempdate.year.toString() == year.toString()) {
            documents.add(element.data);
          }
        }
        // if (tempdate.year == int.parse(year) &&
        //     tempdate.month == int.parse(month)) {
        //   print('juu');
        //   documents.add(element.data);
        // }
        // documents.add(element.data);
      });
      // print(documents);

      documents.sort((a, b) => a["createdAt"].compareTo(b["createdAt"]));

      return documents;
    } catch (e) {
      if (e.toString().contains('unauthorized')) {
        StatusMessagePopup(
                message: 'Session Expired', duration: Duration(seconds: 2))
            .show(context);
        await removeuserSession();
        return Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    }
  }

  Future<Map> getuserdata() async {
    var userid = await getuser();
    // print(userid);
    final response =
        await http.get(Uri.parse('$appwriteEndpoint/users/$userid'), headers: {
      'content-type': 'application/json',
      'X-Appwrite-Project': appwriteProjectId!,
      'X-Appwrite-Response-Format': '1.0.0',
      'X-Appwrite-Key': appwriteApiKey!,
    }); //, 'origin': 'http://localhost:8080''));
    Map<String, dynamic> userMap = json.decode(response.body);

    return userMap;
  }

  Future<String> updatepassword(password) async {
    var userid = await getuser();
    // print(userid);
    final response = await http
        .patch(Uri.parse('$appwriteEndpoint/users/$userid/password'), headers: {
      'Content-type': 'application/x-www-form-urlencoded',
      'X-Appwrite-Project': appwriteProjectId!,
      'X-Appwrite-Response-Format': '1.0.0',
      'X-Appwrite-Key': appwriteApiKey!,
    }, body: {
      "password": password
    }); //, 'origin': 'http://localhost:8080''));
    Map<String, dynamic> userMap = json.decode(response.body);
    // print(userMap);
    return "${userMap['status']}";
  }

  Future<String> updateEmail(email) async {
    var userid = await getuser();
    // print(userid);
    final response = await http
        .patch(Uri.parse('$appwriteEndpoint/users/$userid/email'), headers: {
      'Content-type': 'application/x-www-form-urlencoded',
      'X-Appwrite-Project': appwriteProjectId!,
      'X-Appwrite-Response-Format': '1.0.0',
      'X-Appwrite-Key': appwriteApiKey!,
    }, body: {
      "email": email
    }); //, 'origin': 'http://localhost:8080''));
    Map<String, dynamic> userMap = json.decode(response.body);
    // print(userMap);
    return "${userMap['status']}";
  }

  Future<String> updateName(name) async {
    var userid = await getuser();
    // print(userid);
    final response = await http
        .patch(Uri.parse('$appwriteEndpoint/users/$userid/name'), headers: {
      'Content-type': 'application/x-www-form-urlencoded',
      'X-Appwrite-Project': appwriteProjectId!,
      'X-Appwrite-Response-Format': '1.0.0',
      'X-Appwrite-Key': appwriteApiKey!,
    }, body: {
      "name": name
    }); //, 'origin': 'http://localhost:8080''));
    Map<String, dynamic> userMap = json.decode(response.body);
    // print(userMap);
    return "${userMap['status']}";
  }
}
