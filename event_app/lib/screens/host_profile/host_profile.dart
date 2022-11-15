import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_app/models/app_user.dart';
import 'package:event_app/screens/chat_screen/chat_screen.dart';
import 'package:event_app/utils/constants.dart';
import 'package:event_app/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../services/app_controller.dart';
import '../event_detail/event_detail.dart';

class HostProfile extends StatefulWidget {
  
  final AppUser hostDetail;
  const HostProfile({ Key? key, required this.hostDetail }) : super(key: key);

  @override
  State<HostProfile> createState() => _HostProfileState();
}

class _HostProfileState extends State<HostProfile> {

  List hostEvents = [];
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  
  @override
  void initState() {
    super.initState();
    getHostEvents();
  }

  void getHostEvents()async{
    hostEvents.clear();
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().getHostEvents(hostEvents, widget.hostDetail.userId);
    isFollowing = await AppController().isUserFollowingProfileUser(widget.hostDetail);
    followers = await AppController().getFollowers(widget.hostDetail);
    following = await AppController().getUserFollowing(widget.hostDetail);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
     setState(() {
       print(hostEvents.length);
     });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void followUser()async{
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().addFollowUser(widget.hostDetail);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
      setState(() {
        followers = followers + 1;   
        isFollowing = true;     
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }

  void unfollowUser()async{
    EasyLoading.show(status: 'Please wait', maskType: EasyLoadingMaskType.black);
    dynamic result = await AppController().removeUserFollow(widget.hostDetail);
    EasyLoading.dismiss();
    if(result['Status'] == 'Success')
    {
      setState(() {
        followers = followers - 1;    
        isFollowing = false;         
      });
    }
    else
    {
      Constants.showDialog(result['ErrorMessage']);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
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

                        IconButton(
                          onPressed: (){
                            if(!isFollowing)
                              followUser();
                            else
                              unfollowUser();
                          },
                          icon: Icon((!isFollowing) ? Icons.person_add_alt_outlined : Icons.person_off_outlined, color: Colors.white, size: SizeConfig.blockSizeVertical * 4,),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Container(
                height: SizeConfig.blockSizeVertical*25,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        height: SizeConfig.blockSizeVertical * 22,
                        width: SizeConfig.blockSizeVertical * 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: (widget.hostDetail.userProfilePicture.isEmpty) ? const AssetImage('assets/placeholder.jpeg') : CachedNetworkImageProvider(widget.hostDetail.userProfilePicture) as ImageProvider,
                            fit: BoxFit.cover
                          )
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if(widget.hostDetail.proUser)
                            Container(
                              height: SizeConfig.blockSizeVertical * 5,
                              width: SizeConfig.blockSizeVertical * 5,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/verified.png'),
                                  fit: BoxFit.cover
                                )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      
              Text(
                widget.hostDetail.name,
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*2.2,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*8, right :SizeConfig.blockSizeHorizontal*8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
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
                    Expanded(
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
                    Expanded(
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
                            '${hostEvents.length}',
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 2.2,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      
              if(widget.hostDetail.proUser)
              GestureDetector(
                onTap: (){
                  Get.to(ChatScreen(chatUser: widget.hostDetail, vendorName: widget.hostDetail.name));
                },
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2),
                  height: SizeConfig.blockSizeVertical * 6,
                  width: SizeConfig.blockSizeHorizontal *50,
                  decoration: BoxDecoration(
                    color: Constants.appThemeColor,
                    borderRadius: BorderRadius.circular(30)
                  ),
                  child : Center(
                    child: Text(
                      'Contact Host',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
      
              (hostEvents.isEmpty) ? Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*15, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                  child: Center(
                    child: Text(
                      'No Events Added',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize*2.2,
                        color: Colors.grey[400]!
                      ),
                    ),
                  ),
             ) : Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2.5, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    itemCount: hostEvents.length,
                    itemBuilder: (_, i) {
                      return eventCell(hostEvents[i], i);
                    },
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget eventCell(dynamic eventDetail, int index){
    String eventImage = eventDetail['eventImageUrl'];
    double distanceInMeters = Geolocator.distanceBetween(Constants.latitude, Constants.longitude, eventDetail['latitude'], eventDetail['longitude']);
    double distanceInKm = distanceInMeters/1000;

    return GestureDetector(
      onTap: (){
        Get.to(EventDetailScreen(eventDetail: eventDetail));
      },
      child: Container(
        height: SizeConfig.blockSizeVertical * 32,
        margin: EdgeInsets.only(top: (index==0) ? 0 : SizeConfig.blockSizeVertical * 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[300],
          image: DecorationImage(
            image: CachedNetworkImageProvider(eventImage),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*1, right: SizeConfig.blockSizeVertical*1),
                padding: EdgeInsets.fromLTRB(15, 3, 15, 5),
                height: SizeConfig.blockSizeVertical*3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Constants.appThemeColor
                ),
                child: Text(
                  (eventDetail['eventPrice'] == "0") ? 'Free' : 'Entry : Rs ${eventDetail['eventPrice']}',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: SizeConfig.fontSize * 1.7,
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: SizeConfig.blockSizeVertical*8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                )
              ),
              child: Row(
                children: [
                  Container(
                    height: SizeConfig.blockSizeVertical * 5.5,
                    width: SizeConfig.blockSizeVertical * 5.5,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(eventDetail['userImage']),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            eventDetail['eventTitle'],
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 1.8,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 2,),
                          Text(
                            'Posted by ${eventDetail['userName']}',
                            maxLines: 1,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 1.4,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical*1.7),
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color : Colors.white, size: SizeConfig.blockSizeVertical*2.5,),
                        Container(
                          margin: const EdgeInsets.only(left: 2),
                          child: Text(
                            '${distanceInKm.toStringAsFixed(1)}km',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: SizeConfig.fontSize * 1.9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
    
}