import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import '../../services/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class MyFollowings extends StatefulWidget {
  const MyFollowings({ Key? key }) : super(key: key);

  @override
  State<MyFollowings> createState() => _MyFollowingsState();
}

class _MyFollowingsState extends State<MyFollowings> {
  
  List followingList = [];

  @override
  void initState() {
    super.initState();
    getMyFollowers();
  }

  void getMyFollowers()async{
    followingList.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().getAllMyFollowings(followingList);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       print(followingList.length);
     });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
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
                  'My Followings',
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize*3.5,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              (followingList.isEmpty) ? Expanded(
                child: Container(
                    margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*7, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                    child: Center(
                      child: Text(
                        'No Followings Found',
                        style: TextStyle(
                          fontSize: SizeConfig.fontSize*2.2,
                          color: Colors.grey[400]!
                        ),
                      ),
                    ),
                  ),
              ): Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      itemCount: followingList.length,
                      itemBuilder: (_, i) {
                        return followersCell(followingList[i], i);
                      },
                      shrinkWrap: true,
                    ),
                  ),
                ),
              ),
            ]
          )
        )
      ),
    );
  }

  Widget followersCell(Map followingsUserDetail, int index){
    return GestureDetector(
      onTap: (){
      },
      child: Container(
        height: SizeConfig.blockSizeVertical*12,
        margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1),
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal*1, vertical: SizeConfig.blockSizeVertical*1),
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
              height: SizeConfig.blockSizeVertical * 9,
              width: SizeConfig.blockSizeVertical * 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: DecorationImage(
                  image: (followingsUserDetail['followingUserPhoto'].isNotEmpty) ? CachedNetworkImageProvider(followingsUserDetail['followingUserPhoto']) : AssetImage('assets/placeholder.jpeg') as ImageProvider,
                  fit: BoxFit.cover
                )
              ),
            ),
            Expanded(
              child: Container(
                height: SizeConfig.blockSizeVertical*12,
                //color: Colors.red,
                margin: EdgeInsets.only(left: SizeConfig.blockSizeHorizontal*5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      followingsUserDetail['followingUserName'],
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize*2.0,
                        color: Colors.black
                      ),
                    ),
                  ],
                )
              )
            )
          ]
        ),
      )
    );
  }
}