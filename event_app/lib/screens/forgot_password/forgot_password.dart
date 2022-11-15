// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, curly_braces_in_flow_control_structures
import 'package:event_app/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../services/app_controller.dart';
import '../../utils/constants.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({ Key? key }) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  
  TextEditingController email = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void submitPressed() async
  {
    if(email.text.isEmpty)
      Constants.showDialog("Please enter email");
    else if(!GetUtils.isEmail(email.text))
      Constants.showDialog("Please enter valid email");
    else
    {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
      dynamic result =  await AppController().forgotPassword(email.text);
      EasyLoading.dismiss();
      if(result['Status'] == 'Success'){
        Get.back();
        Constants.showDialog('An email with instructions to reset your password is sent on your email address');
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
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: SizeConfig.blockSizeVertical* 20,
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 6, vertical: SizeConfig.blockSizeVertical * 6),
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
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  )
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*4, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
              child: Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*3.5,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
              child: Text(
                'Please enter your email to receive password reset instructions',
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
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: SizeConfig.fontSize* 1.8),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(fontSize: SizeConfig.fontSize* 1.8),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.email)
                  ),
                ),
              ),
            ),

           
            GestureDetector(
              onTap: submitPressed,
              child: Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*6, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
                height: SizeConfig.blockSizeVertical * 6.5,
                decoration: BoxDecoration(
                  color: Constants.appThemeColor,
                  borderRadius: BorderRadius.circular(5)
                ),
                child : Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize * 2.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}