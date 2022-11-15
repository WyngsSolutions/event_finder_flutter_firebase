// ignore_for_file: unnecessary_string_interpolations, avoid_unnecessary_containers, prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/app_user.dart';
import '../../services/chat_helper.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';
import '../chat_screen/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {

  Stream<QuerySnapshot>? chatRoomsStream;

  @override
  void initState() {
    super.initState();
    ChatDatabaseModel().getUserChatRooms(Constants.appUser.userId).then((value){
      setState(() {
        chatRoomsStream = value;        
      });
    });
  }

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
                'My Chats',
                style: TextStyle(
                  fontSize: SizeConfig.fontSize*3.5,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: chatMessageList(),
              ),
            )  
          ]
        )
      )
    );
  }

  Widget chatMessageList(){
    return StreamBuilder<QuerySnapshot>(
      stream: chatRoomsStream,
      builder: (context, snapshot){
        return snapshot.hasData ? (snapshot.data!.docs.isNotEmpty) ? MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index){
              return MessageCell(messageData: snapshot.data!.docs[index].data() as Map<dynamic, dynamic>);
            }
          ),
        ) : Container(
          margin: EdgeInsets.only(bottom: 50),
          child: Center(
            child: Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.black,
                fontSize: SizeConfig.fontSize * 2.5,
                //fontWeight: FontWeight.bold
              ),
            ),
          ),
        )
        : Container();
      }
    );
  }
}

class MessageCell extends StatefulWidget {

  final Map messageData;
  MessageCell({required this.messageData});

  @override
  _MessageCellState createState() => _MessageCellState();
}

class _MessageCellState extends State<MessageCell> {

  late AppUser chatUser;
  String chatUserID = "";
  String chatUserName = "";
  String chatUserArtist = "";
  String chatUserProfile = "";
  
  @override
  void initState() {
    super.initState();
    chatUserID = widget.messageData['chatRoomId'];
    chatUserID = chatUserID.replaceFirst("_", "");
    chatUserID = chatUserID.replaceFirst("${Constants.appUser.userId}", "");
    getUserDetail();
  }

  getUserDetail() async {
    chatUser = await AppUser.getUserDetailByUserId(chatUserID);
    print(chatUser.userProfilePicture);
    chatUserProfile = chatUser.userProfilePicture;
    chatUserName = chatUser.name;
    if(mounted)
      setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final lastMsgTime = widget.messageData['lastMessageTimeStamp'].toDate();
    String dateText = timeago.format(lastMsgTime); 
    return GestureDetector(
      onTap: (){
        Get.to(ChatScreen(chatUser: chatUser, vendorName: chatUserName));
      },
      child: Container(
        height: SizeConfig.blockSizeVertical * 11,
        margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical*2, left: SizeConfig.blockSizeHorizontal*4, right: SizeConfig.blockSizeHorizontal*4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 0.2,
              color: Constants.appThemeColor
            ),
          )
        ),
        child: Row(
          children: [
            Container(
              height: SizeConfig.blockSizeVertical * 8,
              width: SizeConfig.blockSizeVertical * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: (chatUserProfile.isEmpty) ?  AssetImage('assets/user.png') as ImageProvider : CachedNetworkImageProvider(chatUserProfile),
                  fit: BoxFit.cover
                )
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left : 20, right: 10, top: 0, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Align(
                      alignment:  Alignment.topRight,
                      child: Container(
                        child: Text(
                          '$dateText',
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: SizeConfig.fontSize *1.2,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '$chatUserName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: SizeConfig.fontSize * 1.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.only(top: 2, bottom: 0),
                      child: Text(
                        (widget.messageData['last_msg'].toString().contains('firebasestorage')) ? 'Photo message' :'${widget.messageData['last_msg']}',
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: SizeConfig.fontSize * 1.7,
                        ),
                      ),
                    ),               
                  ],
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}