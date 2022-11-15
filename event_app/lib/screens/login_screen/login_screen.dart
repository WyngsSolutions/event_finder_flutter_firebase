// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, curly_braces_in_flow_control_structures
import 'package:event_app/screens/location_screen/location_screen.dart';
import 'package:event_app/screens/signup_screen/signup_screen.dart';
import 'package:event_app/utils/size_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/app_controller.dart';
import '../../utils/constants.dart';
import '../forgot_password/forgot_password.dart';

class LoginScreen extends StatefulWidget {
  
  final bool showBackButton;
  const LoginScreen({ Key? key, required this.showBackButton }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void signInPressed() async
  {
    if(email.text.isEmpty)
      Constants.showDialog("Please enter email");
    else if(!GetUtils.isEmail(email.text))
      Constants.showDialog("Please enter valid email");
    else if(password.text.isEmpty)
      Constants.showDialog("Please enter password");
    else if(password.text.length < 8)
      Constants.showDialog("Password lenght should be atleast 8 characters");
    else
    {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
      dynamic result =  await AppController().signInUser(email.text, password.text);
      EasyLoading.dismiss();
      if(result['Status'] == 'Success'){
        await Constants.appUser.saveUserDetails();
        Get.offAll(LocationPermissonScreen());
      }
      else{
        Constants.showDialog(result['ErrorMessage']);
      }
    }
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
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus)
              currentFocus.unfocus();
          },
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                height: SizeConfig.blockSizeVertical* 20,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (widget.showBackButton) ?
                        IconButton(
                          onPressed: (){
                            Get.back();  
                          },
                          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                        ) : Container(),
                      ]
                    ),
                  ],
                ),
              ),
              
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*3.5,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  child: Text(
                    'Continue to your account',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.2,
                    ),
                  ),
                ),
              
                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*6, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
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
                      style: TextStyle(fontSize: SizeConfig.fontSize* 1.8),
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.email)
                      ),
                    ),
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
                      obscureText: true,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      controller: password,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock)
                      ),
                    ),
                  ),
                ),
              
                GestureDetector(
                  onTap: (){
                    Get.to(ForgotPassword());
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                    child : Text(
                      'Forgot password?',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 1.8,
                        color: Constants.appThemeColor,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              
                GestureDetector(
                  onTap: signInPressed,
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*6, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                    height: SizeConfig.blockSizeVertical * 6.5,
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child : Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize * 2.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*3, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  child: Center(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: GoogleFonts.poppins(color: Constants.appThemeColor, fontSize: SizeConfig.fontSize * 1.7),
                        children: <TextSpan>[
                            TextSpan(
                              text: 'Signup',
                              style: GoogleFonts.montserrat(
                                color: Constants.appThemeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.fontSize * 2.0
                              ),
                              recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(SignUpScreen());
                              }
                            )
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
              
              ],
            ),
          ),
        ),
      ),
    );
  }
}