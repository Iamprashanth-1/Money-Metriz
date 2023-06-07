import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils.dart';

const kPrimaryColor = Color(0xFF6F35A5);
const kPrimaryLightColor = Color(0xFFF1E6FF);

const double defaultPadding = 16.0;
const appwriteEndpoint = 'https://cloud.appwrite.io/v1';
var appwriteProjectId = dotenv.env['appwriteProjectId'];
const appwriteDatabaseId = 'default';
const appwriteCollectionId = 'todos';
const appwriteSelfSigned = true;
var storageFeildId = dotenv.env['storageFeildId'];
var appwriteApiKey = dotenv.env['appwriteApiKey'];

var userProfileBucketId = dotenv.env['userProfileBucketId'];
var tranactionCollectionId = dotenv.env['tranactionCollectionId'];
var monthlyBudgetCollectionId = dotenv.env['monthlyBudgetCollectionId'];
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
  'Groceries': Icon(
    Icons.shopping_cart,
    color: generateRandomColor(),
  ),
  'Gas': Icon(
    Icons.local_gas_station,
    color: generateRandomColor(),
  ),
  'Electricity': Icon(
    Icons.flash_on,
    color: generateRandomColor(),
  ),
  'Water': Icon(
    Icons.opacity,
    color: generateRandomColor(),
  ),
  'Rent': Icon(
    Icons.home,
    color: generateRandomColor(),
  ),
  'Others': Icon(
    Icons.category,
    color: generateRandomColor(),
  ),
  'Restaurant': Icon(
    Icons.restaurant,
    color: generateRandomColor(),
  ),
  'Transportation': Icon(
    Icons.directions_car,
    color: generateRandomColor(),
  ),
  'Insurance': Icon(
    Icons.local_hospital,
    color: generateRandomColor(),
  ),
  'Entertainment': Icon(
    Icons.movie,
    color: generateRandomColor(),
  ),
  'Education': Icon(
    Icons.school,
    color: generateRandomColor(),
  ),
  'Travel': Icon(
    Icons.flight,
    color: generateRandomColor(),
  ),
  'Health': Icon(
    Icons.favorite,
    color: generateRandomColor(),
  ),
  'Shopping': Icon(
    Icons.shopping_basket,
    color: generateRandomColor(),
  ),
  'Investments': Icon(
    Icons.trending_up,
    color: generateRandomColor(),
  ),
  'Taxes': Icon(
    Icons.account_balance,
    color: generateRandomColor(),
  ),
};
