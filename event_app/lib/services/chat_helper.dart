import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDatabaseModel{
  
  getConversationMessages(String chatRoomId) async{
    return FirebaseFirestore.instance.collection("ChatRoom").
      doc(chatRoomId).collection('chats')
      .orderBy('timestamp', descending: false)
      .snapshots();
  }

  sendConversationMessage(String chatRoomId, Map<String, dynamic> messageMap) async{
    FirebaseFirestore.instance.collection("ChatRoom").
    doc(chatRoomId).collection('chats').add(messageMap).then((_) async {
      print("success!");
    }).catchError((error) {
      print("Failed to update: $error");
    });

    //SET LAST MESSAGE
    FirebaseFirestore.instance.collection("ChatRoom").
    doc(chatRoomId).
      update({
        'last_msg' : messageMap['message'],
        'lastMessageTimeStamp' : FieldValue.serverTimestamp(),
      }).then((_) async {
        print("success!");
      }).catchError((error) {
        print("Failed to update: $error");
    });
  }

  getUserChatRooms(String userName) async {
    return FirebaseFirestore.instance.collection('ChatRoom').
    where('users', arrayContains: userName)
    .orderBy('lastMessageTimeStamp', descending: true)
    .snapshots();
  }

  getUserDetail(String userName) async {
    return FirebaseFirestore.instance.collection('users').
    where('userName', isEqualTo: userName).snapshots();
  }

  Future deleteChatRoom(String chatRoomId) async {
    try {
      dynamic result = await FirebaseFirestore.instance.collection("ChatRoom").
        doc(chatRoomId).delete().then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return null;
      });

      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Error'] = "Error";
      finalResponse['ErrorMessage'] = "Cannot connect to server. Try again later";
      return finalResponse;
    }
  }

}