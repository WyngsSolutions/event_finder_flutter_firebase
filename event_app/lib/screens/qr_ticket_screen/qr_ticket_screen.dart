import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketScreen extends StatefulWidget {

  final Map eventDetail;
  const TicketScreen({ Key? key , required this.eventDetail}) : super(key: key);

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
 
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
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
                  'My Ticket',
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize*3.5,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical*5, horizontal: SizeConfig.blockSizeHorizontal*7),
                  child: Center(
                    child: QrImage(
                      data: "1234567890",
                      version: QrVersions.auto,
                      size: double.infinity
                    ),
                  ),
                )
              )
            ]
          )
        )
      ),
      bottomNavigationBar: GestureDetector(
        onTap: (){},
        child: Container(
          margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*5, left: SizeConfig.blockSizeHorizontal*6, right: SizeConfig.blockSizeHorizontal*6),
          height: SizeConfig.blockSizeVertical * 6.5,
          decoration: BoxDecoration(
            color: Constants.appThemeColor,
            borderRadius: BorderRadius.circular(5)
          ),
          child : Center(
            child: Text(
              'Download',
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