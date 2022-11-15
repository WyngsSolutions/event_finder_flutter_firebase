// ignore_for_file: curly_braces_in_flow_control_structures
import 'dart:async';
import 'package:event_app/screens/location_screen/location_screen.dart';
import 'package:event_app/services/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/app_user.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class SplashScreen extends StatefulWidget {
  
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      checkIfUserLoggedIn();
    });
  }

  void checkIfUserLoggedIn() async {
    //Check User Login
    Constants.appUser = await AppUser.getUserDetail();
    await AppController().getAllCategories();
    if(Constants.appUser.email.isEmpty)   
    {
      await AppController().signInGuestUser();
      Constants.appUser = await AppUser.getUserDetailByUserId(Constants.appUser.userId);
      Get.offAll(LocationPermissonScreen(),);
      //Get.offAll(const SignUpScreen(),);
    }
    else
    {
      Constants.appUser = await AppUser.getUserDetailByUserId(Constants.appUser.userId);
      Get.offAll(LocationPermissonScreen(),);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(100),
        child: Center(
            child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/logo.png'),
                fit: BoxFit.contain
              )
            ),
          )
        ),
      ),
    );
  }
}
