// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, avoid_print
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import '../../models/app_user.dart';
import '../../services/ads_controllder.dart';
import '../../services/app_controller.dart';
import '../../services/chat_helper.dart';
import '../../utils/constants.dart';
import '../../utils/size_config.dart';

class ChatScreen extends StatefulWidget {
  
  final String vendorName;
  final AppUser chatUser;
  ChatScreen({required this.chatUser, required this.vendorName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  TextEditingController messageController = TextEditingController();
  late String chatRoomId;
  Stream<QuerySnapshot>? chatMessageStream;
  final _controller = ScrollController();
  int groupMessages = 0;
  String type = "text";
  //Photo
  final FirebaseStorage _storage = FirebaseStorage.instance;
  File? _image;
  final picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    AdsController().showInterstitialAd();
    generateChatRoomId();
    ChatDatabaseModel().getConversationMessages(chatRoomId).then((value){
      setState(() {
        chatMessageStream = value;
      });
    });
  }

  void generateChatRoomId(){
    chatRoomId = getChatRoomID(widget.chatUser.userId,Constants.appUser.userId);
  }

  void createChatRoom(){
    chatRoomId = getChatRoomID(widget.chatUser.userId,Constants.appUser.userId);
    List<String> users = [widget.chatUser.userId, Constants.appUser.userId];
    Map<String, dynamic> chatRoomMap = {
      "users" : users,
      "chatRoomId" : chatRoomId,
      'lastMessageTimeStamp' : FieldValue.serverTimestamp(),
      'vendorName' : widget.vendorName,
    };

    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).
      set(chatRoomMap).then((_) async {
        print("success!");
      }).catchError((error) {
        print("Failed to update: $error");
    });
  }

  String getChatRoomID(String a , String b){
    if(a.substring(0,1).codeUnitAt(0) > b.substring(0,1).codeUnitAt(0))
      return "$b\_$a";
    else
      return "$a\_$b";
  }

  void sendMessagePressed(){
    if(messageController.text.trim().isEmpty)
      Constants.showDialog('Please enter message');
    else
    {
      if(groupMessages ==0)
      {
        createChatRoom();
        groupMessages = 1;
      }

      Map<String, dynamic> messageMap = {
        'message' : messageController.text,
        'sendBy' : Constants.appUser.userId,
        'timestamp' : FieldValue.serverTimestamp()
      };
      ChatDatabaseModel().sendConversationMessage(chatRoomId, messageMap);
      AppController().sendChatNotificationToUser(widget.chatUser);
      messageController.text = '';
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
    }
  } 

  ///************ PHOTO CHAT METHOD ****************///
  void showExtraView() async
  {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: Get.context!,
      builder: (BuildContext bc){
        return Container(
          height: SizeConfig.blockSizeVertical * 28,
          decoration: BoxDecoration(
            color: Constants.appThemeColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: SizeConfig.blockSizeHorizontal*15, right: SizeConfig.blockSizeHorizontal*15),
                child: Center(
                  child: Text(
                    'Select Photo',
                    style: TextStyle(
                      fontSize: SizeConfig.fontSize * 3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              GestureDetector(
                onTap: pickFromCamera,
                child: Container(
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 3, left: SizeConfig.blockSizeHorizontal*15, right: SizeConfig.blockSizeHorizontal*15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)                    
                  ),
                  height: SizeConfig.blockSizeVertical *6,
                  child: Center(
                    child: Text(
                      'Camera',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2.0,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: pickFromGallery,
                child: Container(
                  margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2, left: SizeConfig.blockSizeHorizontal*15, right: SizeConfig.blockSizeHorizontal*15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)                    
                  ),
                  height: SizeConfig.blockSizeVertical *6,
                  child: Center(
                    child: Text(
                      'Gallery',
                      style: TextStyle(
                        fontSize: SizeConfig.fontSize * 2.0,
                        color: Constants.appThemeColor,
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        );
      }
    );
  }

  void pickFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if(pickedFile != null)
    {
      _image = File(pickedFile.path);
      setState(() {});
      type = "Photo";
      EasyLoading.show( status: 'Please wait',maskType: EasyLoadingMaskType.black,);
      String imageUrl = await uploadFile();
      EasyLoading.dismiss();
      sendPhotoMessagePressed(imageUrl);
      Get.back();
      FocusScope.of(Get.context!).requestFocus(FocusNode());
    }
  }

  void pickFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if(pickedFile != null)
    {
      _image = File(pickedFile.path);
      setState(() {});
      type = "Photo";
      EasyLoading.show( status: 'Please wait',maskType: EasyLoadingMaskType.black,);
      String imageUrl = await uploadFile();
      EasyLoading.dismiss();
      sendPhotoMessagePressed(imageUrl);
      Get.back();
      FocusScope.of(Get.context!).requestFocus(FocusNode());
    }
  }

  Future<String> uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString() + basename(_image!.path);
    final _firebaseStorage = FirebaseStorage.instance;
    //Upload to Firebase
    var snapshot = await _firebaseStorage.ref().child("chat_pictures").child(fileName).putFile(File(_image!.path));
    var downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void sendPhotoMessagePressed(String photoUrl){
    Map<String, dynamic> messageMap = {
      'message' : photoUrl,
      'sendBy' : Constants.appUser.userId,
      'timestamp' : FieldValue.serverTimestamp(),
      'type' : type
    };
    ChatDatabaseModel().sendConversationMessage(chatRoomId, messageMap);
    AppController().sendChatNotificationToUser(widget.chatUser);
    messageController.text = '';
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }  

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        elevation: 0,
        backgroundColor: Constants.appThemeColor,
        brightness: Brightness.dark,
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        centerTitle: true,
        title:  Text(
          (Constants.appUser.isAdmin) ? '${widget.vendorName}' : 'Support',
          style: TextStyle(
            fontSize: SizeConfig.fontSize * 2.5,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
      ),
      body: Container(
        child : Column(
          children: [              
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(20,15, 20, 5),
                  child: chatMessageList(),
                ),
              ),
              Container(
                child: Container(
                  //height: SizeConfig.blockSizeVertical * 9,
                  margin: EdgeInsets.only(bottom: (Platform.isIOS) ? 15 : 10,),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Center(
                    child: TextField(
                      controller: messageController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        fillColor:  Colors.grey[100],
                        filled: true,
                        hintText: 'Send a message...',
                        contentPadding: EdgeInsets.only(left: 15, top: 18, bottom: 18, right: 5),
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
                              icon: Icon(Icons.attach_file_sharp, color: Constants.appThemeColor), 
                              onPressed: (){
                                showExtraView();
                                FocusScope.of(context).requestFocus(FocusNode());
                              }
                            ),

                            IconButton(
                              icon: Icon(Icons.send, color: Constants.appThemeColor), 
                              onPressed: (){
                                type = "text";
                                sendMessagePressed();
                                FocusScope.of(context).requestFocus(FocusNode());
                              }
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ),
      )
    );
  }

  Widget chatMessageList(){
    return StreamBuilder<QuerySnapshot>(
      stream: chatMessageStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
          controller: _controller,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index){
            groupMessages = snapshot.data!.docs.length;
            return MessageTitle(messageDetail: snapshot.data!.docs[index].data() as Map<dynamic, dynamic>, selectedChatUser: widget.chatUser,);
          }
        ): Container();
      }
    );
  }
}

class MessageTitle extends StatefulWidget {
  
  final AppUser selectedChatUser;
  final Map messageDetail;
  MessageTitle({required this.messageDetail, required this.selectedChatUser});

  @override
  _MessageTitleState createState() => _MessageTitleState();
}

class _MessageTitleState extends State<MessageTitle> {

  bool isSendByMe = true;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool photoType = (widget.messageDetail['type'] == "Photo") ? true : false;
    isSendByMe = (widget.messageDetail['sendBy'] == Constants.appUser.userId) ? true : false; 
    String formattedDate = '';
    if(widget.messageDetail['timestamp'] != null)
    {
      var dateTime = widget.messageDetail['timestamp'].toDate();
      formattedDate = DateFormat('hh:mm a').format(dateTime);
    }
    
    return Align(
      alignment: (isSendByMe) ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: (!isSendByMe) ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [

            if(!isSendByMe)
             CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(100.0),
                child: (widget.selectedChatUser.userProfilePicture.isEmpty) ? Image.asset(
                  'assets/user.png',
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ) : CachedNetworkImage(
                  imageUrl: widget.selectedChatUser.userProfilePicture,
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ),
              ),
            ),
            
            if(!photoType)
            Flexible(
              child: Container(
                margin: EdgeInsets.only(top: 0, bottom: 10, left: (isSendByMe) ? 50 : 10, right: (isSendByMe) ? 10 : 50),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Constants.appThemeColor,
                  ),
                  color : (isSendByMe) ? Colors.transparent : Constants.appThemeColor,
                  borderRadius: (isSendByMe) ? BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                  ): BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)
                  )
                ),
                child: Column(
                  crossAxisAlignment: (isSendByMe) ? CrossAxisAlignment.end : CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        (widget.messageDetail['message'].toString().length <6) ? '${widget.messageDetail['message']}          ' : widget.messageDetail['message'],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: (isSendByMe) ? Colors.black : Colors.white,
                          fontSize: SizeConfig.fontSize * 1.8
                        ),
                      ),
                    ),  
                    Container(
                      margin: EdgeInsets.only(top: 2),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: (isSendByMe) ? Colors.black : Colors.white,
                          fontSize: SizeConfig.fontSize * 1.1
                        ),
                      ),
                    ),   
                  ],
                ),    
              ),          
            ),

            if(photoType)
            Flexible(
              child: Container(
                margin: EdgeInsets.only(top: 0, bottom: 10, left: (isSendByMe) ? 50 : 10, right: (isSendByMe) ? 10 : 50),
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Constants.appThemeColor,
                  ),
                  color : (isSendByMe) ? Colors.white : Colors.transparent,
                  borderRadius: (isSendByMe) ? BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20)
                  ): BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20)
                  )
                ),
                child: Column(
                  crossAxisAlignment: (isSendByMe) ? CrossAxisAlignment.end : CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: (){
                        //Get.to(PictureView(title: "${widget.selectedChatUser.firstName} ${widget.selectedChatUser.lastName}",pictureUrl: widget.messageDetail['message']));
                      },
                      child: Container(
                        height: SizeConfig.blockSizeHorizontal * 50,
                        width: SizeConfig.blockSizeHorizontal * 50,
                        decoration : BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(widget.messageDetail['message']),
                          )
                        )
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: SizeConfig.fontSize * 1.2
                        ),
                      ),
                    ),   
                  ],
                ),    
              ),          
            ),

            if(isSendByMe)
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey,
              child:  ClipRRect(
                borderRadius: new BorderRadius.circular(100.0),
                child: (Constants.appUser.userProfilePicture.isEmpty) ? Image.asset(
                  'assets/user.png',
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ) : CachedNetworkImage(
                  imageUrl: Constants.appUser.userProfilePicture,
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ),
              ),
            ),

          ],
        ),
      )
    );
  }
}
