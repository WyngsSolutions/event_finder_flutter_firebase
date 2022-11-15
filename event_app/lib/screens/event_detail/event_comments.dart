// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, avoid_print
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../services/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class EventComments extends StatefulWidget {

  final Map eventDetails;
  const EventComments({ Key? key, required this.eventDetails }) : super(key: key);

  @override
  State<EventComments> createState() => _EventCommentsState();
}

class _EventCommentsState extends State<EventComments> {
 
  List allEventComments = [];
  TextEditingController commentField = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAllEventComments();
  }

  void getAllEventComments()async{
    allEventComments.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().getAllEventComments(allEventComments, widget.eventDetails);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       print(allEventComments.length);
     });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  Future<void> enterCommentOnEvent() async {
    if(commentField.text.isEmpty)
      Constants.showDialog('Please enter comment');
    else
    {
      EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
      dynamic result = await AppController().addEventComment(widget.eventDetails, commentField.text);
      EasyLoading.dismiss();
      if(result['Status'] == 'Success')
      {
      setState(() {
        commentField.text = "";
        getAllEventComments();
      });
      }
      else
      {
        Constants.showDialog(result['ErrorMessage']);
      }
    }
  }


  void showReportView(Map commentDetail)async
  {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext bc){
        return Container(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*7, vertical: SizeConfig.blockSizeVertical*3),
          height: SizeConfig.blockSizeVertical*52,
          decoration: BoxDecoration(
            color: Constants.appThemeColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40)
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Report Comment To Admin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.fontSize * 2.3,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
                child: Text(
                  'Let the admin know what\'s wrong with this comment. Your details will be kept anonymous for this report',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 1.8,
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  Get.back();
                  AppController().reportComment(commentDetail, 'Other');
                  Constants.showDialog('You have reported the comment to admin');
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5),
                  height: SizeConfig.blockSizeVertical*5.5,
                  width: SizeConfig.blockSizeHorizontal*80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'Spam',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Get.back();
                  AppController().reportComment(commentDetail, 'Harassment');
                  Constants.showDialog('You have reported the comment to admin');
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5),
                  height: SizeConfig.blockSizeVertical*5.5,
                  width: SizeConfig.blockSizeHorizontal*80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'Harassment',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Get.back();
                  AppController().reportComment(commentDetail, 'Hate Speech');
                  Constants.showDialog('You have reported the comment to admin');
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5),
                  height: SizeConfig.blockSizeVertical*5.5,
                  width: SizeConfig.blockSizeHorizontal*80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'Hate Speech',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Get.back();
                  AppController().reportComment(commentDetail, 'Other');
                  Constants.showDialog('You have reported the comment to admin');
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5),
                  height: SizeConfig.blockSizeVertical*5.5,
                  width: SizeConfig.blockSizeHorizontal*80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Center(
                    child: Text(
                      'Other',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
    );
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
                        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                      ),
                    ],
                  )
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Text(
                'Comments',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*3.5,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            
            Expanded(
              child: (allEventComments.isEmpty) ? Container(
                margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: Center(
                  child: Text(
                    'No Comments',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize*2.2,
                      color: Colors.grey[400]!
                    ),
                  ),
                ),
              ): Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: allEventComments.length,
                    itemBuilder: (_, i) {
                      return commentCell(allEventComments[i], i);
                    },
                    shrinkWrap: true,
                  ),
                ),
              ),
            ),

            Container(
              //height: SizeConfig.blockSizeVertical * 9,
              margin: EdgeInsets.only(bottom: (Platform.isIOS) ? 15 : 15, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
              child: Center(
                child: TextField(
                  controller: commentField,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    fillColor:  Colors.grey[100],
                    filled: true,
                    hintText: 'Add comment...',
                    contentPadding: EdgeInsets.only(left: 20, top: 18, bottom: 18, right: 5),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(width: 1,color: Color(0XFFD4D4D4)),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0XFFD4D4D4)),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                        IconButton(
                          icon: Icon(Icons.send, color: Constants.appThemeColor), 
                          onPressed: (){
                            enterCommentOnEvent();
                            FocusScope.of(context).requestFocus(FocusNode());
                          }
                        )
                      ],
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

  Widget commentCell(dynamic commentDetail, int index){
    return GestureDetector(
      onTap: (){
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*3, vertical: SizeConfig.blockSizeVertical*1.5),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 0.5
            )
          )
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 6,
              width: SizeConfig.blockSizeVertical * 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: DecorationImage(
                  image: (commentDetail['userImage'].isNotEmpty) ? CachedNetworkImageProvider(commentDetail['userImage']) : AssetImage('assets/placeholder.jpeg') as ImageProvider,
                  fit: BoxFit.cover
                )
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          commentDetail['userName'],
                          style: TextStyle(
                            fontSize: SizeConfig.fontSize*2.0,
                            color: Colors.black
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            if(Constants.appUser.userId == commentDetail['userId'])
                              Constants.showDialog('You cannot report your own comment');
                            else
                              showReportView(commentDetail);
                          },
                          child: Icon(Icons.report_outlined, size: SizeConfig.blockSizeVertical*3, color: Colors.grey[400],)
                        )
                      ],
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 5),
                      child: Text(
                        commentDetail['userComment'],
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize*1.7,
                          color: Colors.grey[500]!
                        ),
                      ),
                    ),
                  ],
                ),
              )
            )
          ]
        ),
      )
    );
  }
}