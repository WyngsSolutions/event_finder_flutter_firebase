// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, curly_braces_in_flow_control_structures
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/screens/my_followings/my_followings.dart';
import 'package:event_app/screens/my_posted_events/my_posted_events.dart';
import 'package:event_app/utils/size_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../../models/app_user.dart';
import '../../services/app_controller.dart';
import '../../utils/constants.dart';
import '../my_followers/my_followers.dart';
import '../signup_screen/signup_screen.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({ Key? key }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  List myEvents = [];
  int followers = 0;
  int following = 0;
  TextEditingController name = TextEditingController(text: Constants.appUser.name);
  //TextEditingController phone = TextEditingController(text: Constants.appUser.phone);
  TextEditingController email = TextEditingController(text: Constants.appUser.email);
  //PHOTO
  XFile? image;
  String imagePath = "";
  final ImagePicker picker = ImagePicker();
  String userImageUrl = "";

  @override
  void initState() {
    super.initState();
    userImageUrl = Constants.appUser.userProfilePicture;
    getMyEvents();
  }

  void getMyEvents()async{
    myEvents.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().getHostEvents(myEvents, Constants.appUser.userId);
    followers = await AppController().getFollowers(Constants.appUser);
    following = await AppController().getUserFollowing(Constants.appUser);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       print(myEvents.length);
     });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery,);
    if(pickedFile!.path != null)
    {
      setState(() {
        image = pickedFile;
        imagePath = pickedFile.path;
      });
    }
  }

  Future<String> uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + basename(image!.path);
    final _firebaseStorage = FirebaseStorage.instance;
    //Upload to Firebase
    var snapshot = await _firebaseStorage.ref().child("user_pictures").child(fileName).putFile(File(image!.path));
    var downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void updateProfile()async{
    if(name.text.isEmpty)
      Constants.showDialog('Please enter name');
    // else if(phone.text.isEmpty)
    //   Constants.showDialog('Please enter phone number');
    else
    { 
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
      if(image != null)
        userImageUrl = await uploadFile();

      dynamic result = await AppController().updateProfileInfo(name.text, '', userImageUrl);
      EasyLoading.dismiss();
      if(result['Status'] == 'Success')
      {
        Get.back(result: true);
        Constants.appUser.name = name.text;
        //Constants.appUser.phone = phone.text;
        Constants.appUser.userProfilePicture = userImageUrl;
        await Constants.appUser.saveUserDetails();
        Constants.showDialog('Profile has been updated successfully');
      }
      else
      {
        Constants.showDialog(result['ErrorMessage']);
      }
    }
  }

  void showUserAccountDeletePasswordDialog() {
    String password = "";
    Get.generalDialog(
      pageBuilder: (context, __, ___) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        title: Text('Delete Account'),
        content: Container(
          width: SizeConfig.blockSizeHorizontal * 90,
          child: MediaQuery.removePadding(
            context: context,
            removeTop : true,
            child: ListView(
              shrinkWrap : true,
              children: [
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 0, left: 0),                   
                  child: Center(
                    child: Text(
                      'Please enter your password to delete your account',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.fontSize * 2,
                        //fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
          
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: 10),                   
                  child: Text(
                    'Account password',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: SizeConfig.fontSize * 1.6
                    ),
                  ),
                ),
                Container(
                  height: SizeConfig.blockSizeVertical * 8,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 1),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: TextField(
                      style: TextStyle(fontSize: SizeConfig.fontSize * 2),
                      obscureText: true,
                      onChanged: (val){
                        password = val;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        hintText: 'Enter account password',
                        hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                        fillColor: Colors.grey[100],
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text('Cancel')
          ),
          TextButton(
            onPressed: () {
              if(password.isNotEmpty && password.length >= 8)
              {
                Get.back();
                deleteAccount(password);
              }
              else
                Constants.showDialog('Password length should be 8 characters');
            },
            child: Text('Delete')
          )
        ],
      )
    );
  }  

  void deleteAccount(String password)async{
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().deleteUserAccount(password);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
      AppUser.deleteUserAndOtherPreferences();
      Get.offAll(SignUpScreen());
    }
    else
      Constants.showDialog(result['ErrorMessage']);
  }

  
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            print('close');
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus)
              currentFocus.unfocus();
          },
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: SizeConfig.blockSizeVertical* 15,
                  padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 6, right: SizeConfig.blockSizeHorizontal * 6, top: SizeConfig.blockSizeVertical * 6),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/top_bg.png'),
                      fit: BoxFit.fill
                    )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: (){
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                      )
                    ],
                  ),
                ),
              
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*3.5,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                
                Stack(
                  children: [
                    GestureDetector(
                      onTap: getImage,
                      child: Center(
                        child: Container(
                          height: SizeConfig.blockSizeVertical*17,
                          width: SizeConfig.blockSizeVertical*17,
                          margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Constants.appThemeColor
                            ),
                            image: DecorationImage(
                              image: (image != null) ? FileImage(File(imagePath)) : (userImageUrl.isEmpty) ? AssetImage('assets/placeholder.jpeg') : CachedNetworkImageProvider(userImageUrl) as ImageProvider,
                              fit: BoxFit.cover
                            )
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                               Container(
                                 decoration: BoxDecoration(
                                   color: Constants.appThemeColor,
                                   shape: BoxShape.circle
                                 ),
                                 child: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.edit, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*8, right :SizeConfig.blockSizeHorizontal*8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            Get.to(MyFollowers());
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Followers',
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 1.8,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              Text(
                                '$followers',
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 2.2,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            Get.to(MyFollowings());
                          },
                          child: Column(
                            children: [
                              Text(
                                'Following',
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 1.8,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              Text(
                                '$following',
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 2.2,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: (){
                            Get.to(MyPostedEvents());
                          },
                          child: Column(
                            children: [
                              Text(
                                'Total Posts',
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 1.8,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                              Text(
                                '${myEvents.length}',
                                style: TextStyle(
                                  fontSize: SizeConfig.fontSize * 2.2,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Constants.appThemeColor
                    )
                  ),
                  child: Center(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      controller: name,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: TextStyle(fontSize: SizeConfig.fontSize *1.8),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.person)
                      ),
                    ),
                  ),
                ),
              
                // Container(
                //   height: SizeConfig.blockSizeVertical*6.5,
                //   margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical *1.8, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //     border: Border.all(
                //       width: 1,
                //       color: Constants.appThemeColor
                //     )
                //   ),
                //   child: Center(
                //     child: TextField(
                //       textAlignVertical: TextAlignVertical.center,
                //       style: TextStyle(fontSize: SizeConfig.fontSize *1.8),
                //       controller: phone,
                //       decoration: InputDecoration(
                //         hintText: 'Phone',
                //         hintStyle: TextStyle(fontSize: SizeConfig.fontSize *1.8),
                //         border: InputBorder.none,
                //         prefixIcon: Icon(Icons.call)
                //       ),
                //     ),
                //   ),
                // ),
              
                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: Constants.appThemeColor
                    )
                  ),
                  child: Center(
                    child: TextField(
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(fontSize: SizeConfig.fontSize *1.8, color: Colors.grey[500]),
                      controller: email,
                      readOnly: true,
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(fontSize: SizeConfig.fontSize *1.8),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.email)
                      ),
                    ),
                  ),
                ),
                    
                GestureDetector(
                  onTap: updateProfile,
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*3, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                    height: SizeConfig.blockSizeVertical * 6.5,
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child : Center(
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 2.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: showUserAccountDeletePasswordDialog,
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6, bottom: SizeConfig.blockSizeVertical*3),
                    height: SizeConfig.blockSizeVertical * 6.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Constants.appThemeColor,
                        width: 0.7
                      )
                    ),
                    child : Center(
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 2.0,
                          color: Constants.appThemeColor,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                )
              
              ],
            ),
          ),
        ),
      ),
    );
  }
}