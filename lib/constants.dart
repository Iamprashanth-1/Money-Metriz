import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

const double defaultPadding = 16.0;
const appwriteEndpoint = 'https://cloud.appwrite.io/v1';
const appwriteProjectId = '';
const appwriteDatabaseId = 'default';
const appwriteCollectionId = 'todos';
const appwriteSelfSigned = true;
const storageFeildId = '';
const appwriteApiKey = '';

const userProfileBucketId = '';
const tranactionCollectionId = '';
const monthlyBudgetCollectionId = '';
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
