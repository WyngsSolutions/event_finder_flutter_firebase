// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AppUser{

  String userId = "";
  String name = "";
  String phone = "";
  String email = "";
  String userProfilePicture = "";
  String oneSignalUserId = "";
  List myFavourites =[];
  bool proUser = false;
  bool isAdmin = false;

  AppUser({this.userId = "", this.name = "", this.email = "", this.userProfilePicture = "", this.oneSignalUserId = "", this.phone = "", this.myFavourites = const[], this.proUser = false, this.isAdmin = false});

  factory AppUser.fromJson(dynamic json) {
    AppUser user = AppUser(
      userId: json['userId'],
      name : json['name'],
      phone : json['phone'],
      email : json['email'],
      userProfilePicture : json['userProfilePicture'],
      oneSignalUserId : json['oneSignalUserId'],
      myFavourites : json['myFavourites'],
      proUser : json['proUser'],
      isAdmin : json['isAdmin'],
    );
    return user;
  }

  Future saveUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userId", userId);
    prefs.setString("name", name);
    prefs.setString("email", email);
    prefs.setString("phone", phone);
    prefs.setString("oneSignalUserId", oneSignalUserId);
    prefs.setString("userProfilePicture", userProfilePicture);
    prefs.setBool("proUser", proUser);
    prefs.setBool("isAdmin", isAdmin);
  }

  static Future<AppUser> getUserDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AppUser user = AppUser();
    user.userId = prefs.getString("userId") ?? "";
    user.name = prefs.getString("name") ?? "";
    user.oneSignalUserId =  prefs.getString("oneSignalUserId") ?? "";
    user.email =  prefs.getString("email") ?? "";
    user.phone = prefs.getString('phone') ?? "";
    user.userProfilePicture =  prefs.getString("userProfilePicture") ?? "";
    user.proUser = prefs.getBool("proUser") ?? false;
    user.isAdmin = prefs.getBool("isAdmin") ?? false;
    return user;
  }

  static Future deleteUserAndOtherPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static Future saveOneSignalUserID(String oneSignalId)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("OneSignalUserId", oneSignalId);
  }

  static Future getOneSignalUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("OneSignalUserId") ?? "";
  }

  ///*********FIRESTORE METHODS***********\\\\
  Future<dynamic> signUpUser(AppUser user) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(user.userId).set({
      'userId': user.userId,
      'name': user.name,
      'userProfilePicture' : user.userProfilePicture,
      'email' : user.email,
      'oneSignalUserId' : '',  
      'myFavourites' : [],
      'phone' : user.phone,
      'proUser' : user.proUser,
      'isAdmin' : user.isAdmin,
    }).then((_) async {
      print("success!");
      //await user.saveUserDetails();
      return user;
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }

  static Future<dynamic> getLoggedInUserDetail(AppUser user) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .doc(user.userId)
    .get()
    .then((value) async {
      if(value.exists)
      {
        print(value.data()!);
        AppUser userTemp = AppUser.fromJson(value.data());
        userTemp.userId = user.userId;
        //await userTemp.saveUserDetails();
        return userTemp;
      }
      else
      {
        //Signup google/facebook user as first time login
         AppUser userTemp = await AppUser().signUpUser(user);
         return userTemp;
      }
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }

  static Future<dynamic> getUserDetailByUserId(String userId) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .where('userId', isEqualTo: userId)
    .get()
    .then((value) async {
      AppUser userTemp = AppUser.fromJson(value.docs[0].data());
      userTemp.userId = userId;
      return userTemp;
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }

  static Future<dynamic> getUserDetailByEmail(String email) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .where('email', isEqualTo: email)
    .get()
    .then((value) async {
      AppUser userTemp = AppUser.fromJson(value.docs[0].data());
      return userTemp;
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }

  static Future<dynamic> updateUserProfile(String userName, String profilePictureUrl, List myFavourites) async {
    try{
      final firestoreInstance = FirebaseFirestore.instance;
      return await firestoreInstance.collection("users").doc(Constants.appUser.userId).update({
        'userName': userName,
        'userProfilePicture' : profilePictureUrl,
        'myFavourites' : myFavourites
      }).then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
      });
    }
    catch(e){
      return false;
    }
  }

  static Future<dynamic> checkIfAppleUserIdExists(String appleUserIdentier) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance
    .collection("users")
    .where('appleUserIdentier', isEqualTo: appleUserIdentier)
    .get()
    .then((value) async {
      AppUser userTemp = AppUser.fromJson(value.docs[0].data());
      userTemp.userId = value.docs[0].id;
      return userTemp;
    }).catchError((error) {
      print("Failed to add user: $error");
      return AppUser();
    });
  }

  static bool isGuestUser(){
    if(Constants.appUser.email == 'guess@gmail.com')
      return true;
    else
      return false;
  }
}
