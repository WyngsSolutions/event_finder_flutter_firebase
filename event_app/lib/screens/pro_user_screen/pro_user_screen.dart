import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/app_user.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../chat_screen/chat_screen.dart';

class ProUserScreen extends StatefulWidget {
  const ProUserScreen({ Key? key }) : super(key: key);

  @override
  State<ProUserScreen> createState() => _ProUserScreenState();
}

class _ProUserScreenState extends State<ProUserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: (){
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                'Become Pro User',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*3.5,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            Container(
              height: SizeConfig.blockSizeVertical* 15,
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 6),
              padding: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 6, right: SizeConfig.blockSizeHorizontal * 6),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/verified.png'),
                  fit: BoxFit.contain
                )
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*3, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                'To earn pro user status you will have to chat with our support and support will check and verify your details. Once all details are verified your account will be updated to Pro. Following our the advantages of pro account :',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*2,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                '- Pro badge on your profile',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*2,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
             Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                '- Events posted as Featured Events',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*2,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                '- Ability for user to chat with you',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*2,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                '- Priority Support',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*2,
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
              
          ]
        )
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () async {
          AppUser admin = await AppUser.getUserDetailByEmail('imran4125@gmail.com');
          Get.back();
          Get.to(ChatScreen(chatUser: admin, vendorName: 'Support'));
        },
        child: Container(
          margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*6, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
          height: SizeConfig.blockSizeVertical * 6.5,
          decoration: BoxDecoration(
            color: Constants.appThemeColor,
            borderRadius: BorderRadius.circular(5)
          ),
          child : Center(
            child: Text(
              'Proceed',
              style: TextStyle(
                fontSize: SizeConfig.fontSize * 2.0,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}