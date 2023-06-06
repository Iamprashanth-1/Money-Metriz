import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

const double defaultPadding = 16.0;
const appwriteEndpoint = 'https://cloud.appwrite.io/v1';
const appwriteProjectId = '6464d60fd7ce6e1477b6';
const appwriteDatabaseId = 'default';
const appwriteCollectionId = 'todos';
const appwriteSelfSigned = true;
const storageFeildId = '647eb114da16956af0f5';
const appwriteApiKey =
    'f39781477f3e3d7fab3ce5a6931de30b5573bcc268b250b00618f416924a43fa704ba422acb7276ccf9689ce882bced77f1ec1c8434be3c1905c9d6adba569b963234017d144f6c3f0f6f7111275084a764d1a71ac65adec21edbf4a0faecffcfcc9ddb094028175719342ce1bc6f5ed41297e8adb96f9048e15f96127db11c9';

const userProfileBucketId = '647ea45152961336831f';
const tranactionCollectionId = '64759c4e737497dbb488';
const monthlyBudgetCollectionId = '64786d38b7fc4053bac8';
Map monthMap = {
  '1': 'Jan',
  '2': 'Feb',
  '3': 'Mar',
  '4': 'Apr',
  '5': 'May',
  '6': 'Jun',
  '7': 'Jul',
  '8': 'Aug',
  '9': 'Sep',
  '10': 'Oct',
  '11': 'Nov',
  '12': 'Dec',
};

Map category_icon_list_map = {
  'Groceries': Icon(Icons.shopping_cart),
  'Gas': Icon(Icons.local_gas_station),
  'Electricity': Icon(Icons.flash_on),
  'Water': Icon(Icons.opacity),
  'Rent': Icon(Icons.home),
  'Others': Icon(Icons.category),
  'Restaurant': Icon(Icons.restaurant),
  'Transportation': Icon(Icons.directions_car),
  'Insurance': Icon(Icons.local_hospital),
  'Entertainment': Icon(Icons.movie),
  'Education': Icon(Icons.school),
  'Travel': Icon(Icons.flight),
  'Health': Icon(Icons.favorite),
  'Shopping': Icon(Icons.shopping_basket),
  'Investments': Icon(Icons.trending_up),
  'Taxes': Icon(Icons.account_balance)
};
