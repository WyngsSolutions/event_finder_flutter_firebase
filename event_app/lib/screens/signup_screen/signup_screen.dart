// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, curly_braces_in_flow_control_structures, deprecated_member_use
import 'package:event_app/screens/location_screen/location_screen.dart';
import 'package:event_app/screens/login_screen/login_screen.dart';
import 'package:event_app/utils/size_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/app_controller.dart';
import '../../utils/constants.dart';

class SignUpScreen extends StatefulWidget {
  
  const SignUpScreen({ Key? key }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void signUpPressed() async
  {
    if(name.text.isEmpty)
      Constants.showDialog("Please enter name");
    // else if(phone.text.isEmpty)
    //   Constants.showDialog("Please enter phone number");
    else if(email.text.isEmpty)
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
      dynamic result =  await AppController().signUpUser(name.text, '', email.text, password.text);
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
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/top_bg.png'),
                      fit: BoxFit.fill
                    )
                  ),
                ),
              
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*3.5,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                  child: Text(
                    'Fill up the form to join',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.2,
                    ),
                  ),
                ),
              
                Container(
                  height: SizeConfig.blockSizeVertical*6.5,
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
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
                      style: TextStyle(fontSize: SizeConfig.fontSize *1.8),
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
                //   margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
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
                //       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                //       keyboardType: TextInputType.number,
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
                      style: TextStyle(fontSize: SizeConfig.fontSize *1.8),
                      keyboardType: TextInputType.emailAddress,
                      controller: email,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: TextStyle(fontSize: SizeConfig.fontSize *1.8),
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
                      controller: password,
                      style: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(fontSize: SizeConfig.fontSize*1.8),
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.lock)
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
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'By signing up, you agree to our ',
                        style: GoogleFonts.poppins(color: Colors.black, fontSize: SizeConfig.fontSize * 1.7),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Terms of service',
                            style: GoogleFonts.montserrat(
                              color: Constants.appThemeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: SizeConfig.fontSize * 1.8
                            ),
                            recognizer: TapGestureRecognizer()
                            ..onTap = () {
                                launch('http://wyngslogistics.com/#/policy');
                              }
                            ),
                            TextSpan(
                              text: ' and ',
                              style: GoogleFonts.montserrat(
                                color: Colors.black,
                                fontSize: SizeConfig.fontSize * 1.8
                              ),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: GoogleFonts.montserrat(
                                color: Constants.appThemeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.fontSize * 1.8
                              ),
                              recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launch('http://wyngslogistics.com/#/policy');
                              }
                            )
                          ]
                        ),
                      ),
                    ),
                  ),
                ),
                  
                GestureDetector(
                  onTap: signUpPressed,
                  child: Container(
                    margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*5, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                    height: SizeConfig.blockSizeVertical * 6.5,
                    decoration: BoxDecoration(
                      color: Constants.appThemeColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child : Center(
                      child: Text(
                        'Sign Up',
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
                        text: 'Already have an account? ',
                        style: GoogleFonts.poppins(color: Colors.black, fontSize: SizeConfig.fontSize * 1.7),
                        children: <TextSpan>[
                            TextSpan(
                              text: 'Login',
                              style: GoogleFonts.montserrat(
                                color: Constants.appThemeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: SizeConfig.fontSize * 2.0
                              ),
                              recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(LoginScreen(showBackButton: false,));
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