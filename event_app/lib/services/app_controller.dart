// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import '../models/app_user.dart';
import '../utils/constants.dart';

class AppController {

  final firestoreInstance = FirebaseFirestore.instance;

  //SIGN UP
  Future signUpUser(String userName, String phone, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.user!.uid);
      AppUser newUser = AppUser(userId: userCredential.user!.uid, name: userName, email: email, phone: phone);
      AppUser resultUser = await newUser.signUpUser(newUser);
      if (resultUser.email.isNotEmpty) 
      {
        Constants.appUser = resultUser;
        await Constants.appUser.saveUserDetails();
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['User'] = resultUser;
        return finalResponse;
      } 
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "User cannot signup at this time. Try again later";
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      finalResponse['ErrorMessage'] = e.message;
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  //SIGN IN
  Future signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print(userCredential.user!.uid);
      AppUser signedInUser = AppUser(
        userId: userCredential.user!.uid, 
        name: '', 
        email: email, 
        oneSignalUserId: '', 
        userProfilePicture: '',
      );

      userCredential.user!.sendEmailVerification();
      AppUser resultUser = await AppUser.getLoggedInUserDetail(signedInUser);
      if (resultUser.email.isNotEmpty) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['User'] = resultUser;
        Constants.appUser = resultUser;
        await Constants.appUser.saveUserDetails();
        return finalResponse;
      }
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "User cannot login at this time. Try again later";
        return finalResponse;
      }
    }
     on FirebaseAuthException catch (e) 
    {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      finalResponse['ErrorMessage'] = e.message;
      return finalResponse;
    } 
    catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future signInGuestUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: 'guess@gmail.com', password: '12345678');
      print(userCredential.user!.uid);
      AppUser signedInUser = AppUser(
        userId: userCredential.user!.uid, 
        name: '', 
        email: 'guess@gmail.com', 
        oneSignalUserId: '', 
        userProfilePicture: '',
      );

      userCredential.user!.sendEmailVerification();
      AppUser resultUser = await AppUser.getLoggedInUserDetail(signedInUser);
      if (resultUser.email.isNotEmpty) 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        finalResponse['User'] = resultUser;
        Constants.appUser = resultUser;
        await Constants.appUser.saveUserDetails();
        return finalResponse;
      }
      else 
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "User cannot login at this time. Try again later";
        return finalResponse;
      }
    }
     on FirebaseAuthException catch (e) 
    {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      finalResponse['ErrorMessage'] = e.message;
      return finalResponse;
    } 
    catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }



  //FORGOT PASSWORD
  Future forgotPassword(String email) async {
    try {
      String result = "";
      await FirebaseAuth.instance
      .sendPasswordResetEmail(email: email).then((_) async {
        result = "Success";
      }).catchError((error) {
        result = error.toString();
        print("Failed emailed : $error");
      });

      if (result == "Success") {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = result;
        return finalResponse;
      }
    } on FirebaseAuthException catch (e) {
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Error";
      finalResponse['ErrorMessage'] = e.code;
      return finalResponse;
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }
  
  //EDIT USER NAME
  Future updateProfileInfo(String name, String phone, String userProfilePicture) async {
    try {
      final firestoreInstance = FirebaseFirestore.instance;
        return await firestoreInstance.collection("users").doc(Constants.appUser.userId)
        .update({
          'name': name,
          'phone': phone,
          'userProfilePicture' : userProfilePicture,
        }).then((_) async {
          print("success!");
          Map finalResponse = <dynamic, dynamic>{}; //empty map
          finalResponse['Status'] = "Success";
          return finalResponse;
        }).catchError((error) {
          print("Failed to update: $error");
          return setUpFailure();
        });
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

   Future getAllCategories() async {
    try {
      dynamic result = await firestoreInstance.collection("categories")
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['categoryId'] = result.id;
          Constants.categories.add(taskData);
        });
        return true;
      });

      if (result)
      {
        Constants.categories.sort((a, b) => a['categoryName'].compareTo(b['categoryName']));
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
      return setUpFailure();
    }
  }

  Future addEvent(String eventTitle, String eventDescription, String eventDate, Map selectedCategory, String eventAddress, String eventCity, String eventPrice, double latitude, double longitude, String eventImageUrl) async {
    try {   
      dynamic result = await firestoreInstance.collection("events").add({
        'eventTitle': eventTitle,
        'eventDescription': eventDescription,
        'eventDate': eventDate,
        'selectedCategory': selectedCategory,
        'eventAddress' : eventAddress,
        'eventCity' : eventCity,
        'eventPrice': eventPrice,
        'latitude': latitude,
        'longitude': longitude,
        'eventImageUrl': eventImageUrl,
        'userEmail': Constants.appUser.email,
        'userId': Constants.appUser.userId,
        'userImage': Constants.appUser.userProfilePicture,
        'userName': Constants.appUser.name,
        'proUser' : Constants.appUser.proUser,
        'eventAddedTime' : FieldValue.serverTimestamp()
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
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
      return setUpFailure();
    }
  }

  Future editEvent(Map eventDetails, String eventTitle, String eventDescription, String eventDate, Map selectedCategory, String eventAddress, String eventCity, String eventPrice, double latitude, double longitude) async {
    try {   
      dynamic result = await firestoreInstance.collection("events")
      .doc(eventDetails['eventId']).update({
        'eventTitle': eventTitle,
        'eventDescription': eventDescription,
        'eventDate': eventDate,
        'selectedCategory': selectedCategory,
        'eventAddress' : eventAddress,
        'eventCity' : eventCity,
        'eventPrice': eventPrice,
        'latitude': latitude,
        'longitude': longitude,
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
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
      return setUpFailure();
    }
  }


  Future getAllEvents(List allEvents, List featuredEvents) async {
    try {
      dynamic result = await firestoreInstance.collection("events")
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['eventId'] = result.id;
          allEvents.add(taskData);
          if(taskData['proUser'])
            featuredEvents.add(taskData);
        });
        return true;
      });

      if (result)
      {
        allEvents.sort((a, b) => a['eventAddedTime'].toDate().compareTo(b['eventAddedTime'].toDate()));
        featuredEvents.sort((a, b) => a['eventAddedTime'].toDate().compareTo(b['eventAddedTime'].toDate()));
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
      return setUpFailure();
    }
  }

  Future deleteEvent(Map event) async {
    try {
      dynamic result = await FirebaseFirestore.instance.collection("events").
        doc(event['eventId']).delete().then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
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

  Future editTask(Map taskDetail, String taskTitle, String taskDescription, String taskCategory, String taskDate, Map? member, String taskReminder) async {
    try {   
      dynamic result = await firestoreInstance.collection("tasks").doc(taskDetail['taskId'])
      .update({
        'taskTitle': taskTitle,
        'taskDescription': taskDescription,
        'taskCategory': taskCategory,
        'taskDate': taskDate,
        'taskReminder': taskReminder,
        'member' : (member == null) ? {} : member,
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
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
      return setUpFailure();
    }
  }

  //LIKED EVENTS RELATED
  Future getAllLikedUserForEvents(Map eventDetails, List allLikedUsersList) async {
    try {
      dynamic result = await firestoreInstance.collection("event_likes")
      .where('eventId', isEqualTo: eventDetails['eventId'])
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['userLikedId'] = result.id;
          allLikedUsersList.add(taskData);
        });
        return true;
      });

      if (result)
      {
        allLikedUsersList.sort((a, b) => a['eventLikedTime'].toDate().compareTo(b['eventLikedTime'].toDate()));
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
      return setUpFailure();
    }
  }

  Future addUserlikeEvent(Map eventDetails) async {
    try {   
      dynamic result = await firestoreInstance.collection("event_likes").add({
        'eventId' : eventDetails['eventId'],
        'eventTitle': eventDetails['eventTitle'],
        'eventLikedTime' : FieldValue.serverTimestamp(),
        'likingUserId': Constants.appUser.userId,
        'likingUserName': Constants.appUser.name,
        'likingUserPhoto': Constants.appUser.userProfilePicture,
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
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
      return setUpFailure();
    }
  }

  Future removeUserlikeEvent(Map likedDetails) async {
    try {   
      dynamic result = await FirebaseFirestore.instance.collection("event_likes").
        doc(likedDetails['userLikedId']).delete().then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
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
      return setUpFailure();
    }
  }

  //JOINED EVENTS RELATED
  Future addJoinedEvent(Map eventDetails) async {
    try {   
      dynamic result = await firestoreInstance.collection("joined_events").add({
        'eventId' : eventDetails['eventId'],
        'eventTitle': eventDetails['eventTitle'],
        'eventDescription': eventDetails['eventDescription'],
        'eventDate': eventDetails['eventDate'],
        'selectedCategory': eventDetails['selectedCategory'],
        'eventAddress' : eventDetails['eventAddress'],
        'eventPrice': eventDetails['eventPrice'],
        'latitude': eventDetails['latitude'],
        'longitude': eventDetails['longitude'],
        'eventImageUrl': eventDetails['eventImageUrl'],
        'userEmail': eventDetails['userEmail'],
        'userId': eventDetails['userId'],
        'userImage':eventDetails['userImage'],
        'userName': eventDetails['userName'],
        'eventAddedTime' : eventDetails['eventAddedTime'],
        'eventJoinAddedTime' : FieldValue.serverTimestamp(),
        'joiningUserId': Constants.appUser.userId,
        'joiningUserName': Constants.appUser.name,
        'joiningUserPhoto': Constants.appUser.userProfilePicture,
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
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
      return setUpFailure();
    }
  }

  Future getAllJoinedEvents(List allJoinedEvents) async {
    try {
      dynamic result = await firestoreInstance.collection("joined_events")
      .where('joiningUserId', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['joinedEventId'] = result.id;
          allJoinedEvents.add(taskData);
        });
        return true;
      });

      if (result)
      {
        allJoinedEvents.sort((a, b) => a['eventAddedTime'].toDate().compareTo(b['eventAddedTime'].toDate()));
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
      return setUpFailure();
    }
  }

  Future leaveEvent(Map eventDetail) async {
    try {
      dynamic result = await FirebaseFirestore.instance.collection("joined_events").
        doc(eventDetail['joinedEventId']).delete().then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
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

  Future getEventJoiningUser(List allEventJoiningUsers, Map event) async {
    try {
      dynamic result = await firestoreInstance.collection("joined_events")
      .where('eventId', isEqualTo: event['eventId'])
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['joinedEventId'] = result.id;
          allEventJoiningUsers.add(taskData);
        });
        return true;
      });

      if (result)
      {
        allEventJoiningUsers.sort((a, b) => a['eventJoinAddedTime'].toDate().compareTo(b['eventJoinAddedTime'].toDate()));
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
      return setUpFailure();
    }
  }

  //MY EVENTS
  Future getMyPostedEvents(List allEvents) async {
    try {
      dynamic result = await firestoreInstance.collection("events")
      .where('userId', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['eventId'] = result.id;
          allEvents.add(taskData);
        });
        return true;
      });

      if (result)
      {
        allEvents.sort((a, b) => a['eventAddedTime'].toDate().compareTo(b['eventAddedTime'].toDate()));
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
      return setUpFailure();
    }
  }

  //MY EVENTS
  Future getHostEvents(List allEvents, String hostUserId) async {
    try {
      dynamic result = await firestoreInstance.collection("events")
      .where('userId', isEqualTo: hostUserId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['eventId'] = result.id;
          allEvents.add(taskData);
        });
        return true;
      });

      if (result)
      {
        allEvents.sort((a, b) => a['eventAddedTime'].toDate().compareTo(b['eventAddedTime'].toDate()));
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
      return setUpFailure();
    }
  }

  ///COMMENTS EVENTS
  Future getAllEventComments(List allComments, Map eventDetail) async {
    try {
      dynamic result = await firestoreInstance.collection("event_comments")
      .where('eventId', isEqualTo: eventDetail['eventId'])
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          Map taskData = result.data();
          taskData['commentId'] = result.id;
          allComments.add(taskData);
        });
        return true;
      });

      if (result)
      {
        allComments.sort((a, b) => a['commentAddedTime'].toDate().compareTo(b['commentAddedTime'].toDate()));
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
      return setUpFailure();
    }
  }

  Future addEventComment(Map eventDetail, String eventComment) async {
    try {   
      dynamic result = await firestoreInstance.collection("event_comments").add({
        'eventId': eventDetail['eventId'],
        'eventTitle': eventDetail['eventTitle'],
        'userComment' : eventComment,
        'userEmail': Constants.appUser.email,
        'userId': Constants.appUser.userId,
        'userImage': Constants.appUser.userProfilePicture,
        'userName': Constants.appUser.name,
        'commentAddedTime' : FieldValue.serverTimestamp()
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
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
      return setUpFailure();
    }
  }

  Future reportComment(Map commentDetail, String reportReaon) async {
    try {   
      dynamic result = await firestoreInstance.collection("reported_comments").add({
        'commentId': commentDetail['commentId'],
        'userComment': commentDetail['userComment'],
        'userEmail' : commentDetail['userEmail'],
        'userId': commentDetail['userId'],
        'userName': commentDetail['userName'],
        'reportedById': Constants.appUser.userId,
        'reportedByEmail': Constants.appUser.email,
        'reportedReason': reportReaon,
        'reportedCommentTime' : FieldValue.serverTimestamp()
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
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
      return setUpFailure();
    }
  }

  //FOLLOWERS
  Future addFollowUser(AppUser followUser) async {
    try {   
      dynamic result = await firestoreInstance.collection("followers").add({
        'followerUserEmail' : followUser.email,
        'followerUserId': followUser.userId,
        'followerUserName': followUser.name,
        'followingUserId': Constants.appUser.userId,
        'followingUserEmail': Constants.appUser.email,
        'followingUserPhoto': Constants.appUser.userProfilePicture,
        'followingUserName': Constants.appUser.name,
        'followAddedTime' : FieldValue.serverTimestamp()
      }).then((doc) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to add user: $error");
        return false;
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
      return setUpFailure();
    }
  }

  Future getFollowers(AppUser profilUser) async {
    try {
      int myFollowers = 0;
      dynamic result = await firestoreInstance.collection("followers")
      .where('followerUserId', isEqualTo: profilUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          myFollowers = value.docs.length;
        });
        return true;
      });

      if (result)
      {
        return myFollowers;
      }
      else
      {
        return myFollowers;
      }
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }

  Future getUserFollowing(AppUser profilUser) async {
    try {
      int meFollowing = 0;
      dynamic result = await firestoreInstance.collection("followers")
      .where('followingUserId', isEqualTo: profilUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          meFollowing = value.docs.length;
        });
        return true;
      });

      if (result)
      {
        return meFollowing;
      }
      else
      {
        return meFollowing;
      }
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }

  Future isUserFollowingProfileUser(AppUser profileUser) async {
    try {
      bool isUserFollowingProfileUser = false;
      dynamic result = await firestoreInstance.collection("followers")
      .where('followerUserId', isEqualTo: profileUser.userId)
      .where('followingUserId', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          if(result.exists)
            isUserFollowingProfileUser = true;
          else
            isUserFollowingProfileUser = false;
        });
        return true;
      });

      if (result)
      {
        return isUserFollowingProfileUser;
      }
      else
      {
        return isUserFollowingProfileUser;
      }
    } catch (e) {
      print(e.toString());
      return isUserFollowingProfileUser;
    }
  }

  Future removeUserFollow(AppUser profileUser) async {
    try {
      Map documentData = {};
      dynamic result = await firestoreInstance.collection("followers")
      .where('followerUserId', isEqualTo: profileUser.userId)
      .where('followingUserId', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          documentData = result.data();
          documentData['followerRecordId'] = result.id;
        });
      });

      result = await FirebaseFirestore.instance.collection("followers").
        doc(documentData['followerRecordId']).delete().then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
      });

      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        return setUpFailure();
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Future getAllMyFollowers(List myFollowers) async {
    try {
      dynamic result = await firestoreInstance.collection("followers")
      .where('followerUserId', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          myFollowers.add(result.data());
        });
        return true;
      });

      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        return setUpFailure();
      }
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }

  Future getAllMyFollowings(List myFollowings) async {
    try {
      dynamic result = await firestoreInstance.collection("followers")
      .where('followingUserId', isEqualTo: Constants.appUser.userId)
      .get().then((value) {
      value.docs.forEach((result) 
        {
          print(result.data);
          myFollowings.add(result.data());
        });
        return true;
      });

      if (result)
      {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      }
      else
      {
        return setUpFailure();
      }
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }

  //UPDATE PROFILE PIC
  Future<dynamic> updateOneSignalUserID(String oneSignalUserID) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return await firestoreInstance.collection("users").doc(Constants.appUser.userId)
    .update({
      "oneSignalUserId": oneSignalUserID
     }).then((_) async {
      print("success!");
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    }).catchError((error) {
      print("Failed to update: $error");
      return setUpFailure();
    });
  }

  Future deleteUserAccount(String riderPassword) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: Constants.appUser.email, password: riderPassword);
      print(userCredential.user);
      AuthCredential credentials = EmailAuthProvider.credential(email: Constants.appUser.email, password: riderPassword);
      UserCredential result = await userCredential.user!.reauthenticateWithCredential(credentials);
      await deleteUserFromFirebase(Constants.appUser.userId);
      await result.user!.delete();
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Status'] = "Success";
      return finalResponse;
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Error'] = "Error";
      finalResponse['ErrorMessage'] = "The rider password is not correct";
      return finalResponse;
    }
    catch(e){
      Map finalResponse = <dynamic, dynamic>{}; //empty map
      finalResponse['Error'] = "Error";
      finalResponse['ErrorMessage'] = "The rider password is not correct";
      return finalResponse;
    }
  }

  Future deleteUserFromFirebase(String userId) async {
    try {
      dynamic result = await FirebaseFirestore.instance.collection("users").
        doc(userId).delete().then((_) async {
        print("success!");
        return true;
      }).catchError((error) {
        print("Failed to update: $error");
        return false;
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
  
  Future sendChatNotificationToUser(AppUser user) async {
    try {
      Map<String, String> requestHeaders = {
        "Content-type": "application/json", 
        "Authorization" : "Basic ${Constants.oneSignalRestKey}"
      };
      var url =  Uri.parse('https://onesignal.com/api/v1/notifications');
      String json = '{ "include_player_ids" : ["${user.oneSignalUserId}"] ,"app_id" : "${Constants.oneSignalId}", "small_icon" : "app_icon", "headings" : {"en" : "New Message"},"contents" : {"en" : "You have received a new message from ${Constants.appUser.name}"}}';
      Response response = await post(url, headers: requestHeaders, body: json);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
     
      if (response.statusCode == 200) {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Status'] = "Success";
        return finalResponse;
      } else {
        Map finalResponse = <dynamic, dynamic>{}; //empty map
        finalResponse['Error'] = "Error";
        finalResponse['ErrorMessage'] = "Cannot send notification at this time. Try again later";
        return finalResponse;
      }
    } catch (e) {
      print(e.toString());
      return setUpFailure();
    }
  }

  Map setUpFailure() {
    Map finalResponse = <dynamic, dynamic>{}; //empty map
    finalResponse['Status'] = "Error";
    finalResponse['ErrorMessage'] = "Please try again later. Server is busy.";
    return finalResponse;
  }
}
