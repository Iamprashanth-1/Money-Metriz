import 'package:shared_preferences/shared_preferences.dart';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../services/appwrite.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'dart:convert';

class AuthService {
  final Account _account = Account(Appwrite.instance.client);
  // final _user = Users.Users(Appwrite.instance.client as Users.Client);

  final String databaseId = '6464d86842d0a340597d';
  // final String collectionId = '64759c4e737497dbb488';

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

  Future<void> logout() {
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
        collectionId: monthlyBudgetCollectionId,
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

  Future getDocuments(collectionId, year, month) async {
    var userId = await getuser();
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
        if (tempdate.year.toString() == year &&
            tempdate.month.toString() == month) {
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
  }

  Future<Map> getuserdata() async {
    var userid = await getuser();
    // print(userid);
    final response =
        await http.get(Uri.parse('$appwriteEndpoint/users/$userid'), headers: {
      'content-type': 'application/json',
      'X-Appwrite-Project': appwriteProjectId,
      'X-Appwrite-Response-Format': '1.0.0',
      'X-Appwrite-Key': appwriteApiKey,
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
      'X-Appwrite-Project': appwriteProjectId,
      'X-Appwrite-Response-Format': '1.0.0',
      'X-Appwrite-Key': appwriteApiKey,
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
      'X-Appwrite-Project': appwriteProjectId,
      'X-Appwrite-Response-Format': '1.0.0',
      'X-Appwrite-Key': appwriteApiKey,
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
      'X-Appwrite-Project': appwriteProjectId,
      'X-Appwrite-Response-Format': '1.0.0',
      'X-Appwrite-Key': appwriteApiKey,
    }, body: {
      "name": name
    }); //, 'origin': 'http://localhost:8080''));
    Map<String, dynamic> userMap = json.decode(response.body);
    // print(userMap);
    return "${userMap['status']}";
  }
}
