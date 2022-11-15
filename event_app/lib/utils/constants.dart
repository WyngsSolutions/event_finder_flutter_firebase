// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/app_user.dart';

class Constants {
  static final Constants _singleton = Constants._internal();
  static String appName = "Events App";
  static Color appThemeColor = Colors.blue;
  static Color appSecondaryColor = Color(0XFF397337);
  static Color cardGradientTop = Color(0XFF61636d);
  static Color cardGradientDown = Color(0XFF1d2030);
  static AppUser appUser = AppUser();
  static List categories = [];
  static double latitude = 0.0;
  static double longitude = 0.0;
  static String areaName = "";
  static String oneSignalId = "13fa3a3e-14ca-4727-a27b-4bb4ed291c38";
  static String oneSignalRestKey = "NzU0N2Y1M2MtNGE3NS00NTI4LWE0NjAtZTkzNDczMjVmOGY3";
  static List cities = [
    'Lahore',
    'Karachi',
    'Islamabad',
    'Quetta',
    'Faisalbad',
    'Multan',
    'Other'
  ];
  //SEARCH FILTERS
  static Map selectedCat = {};
  static String selectedCity = "";
  static String selectedPrice = "";

  factory Constants() {
    return _singleton;
  }

  Constants._internal();

  static void showDialog(String message) {
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text(appName, style: TextStyle(fontWeight: FontWeight.w500),),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('OK')
          )
        ],
      )
    );
  }
}