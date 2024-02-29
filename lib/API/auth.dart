
import 'dart:convert';
import 'dart:io';
import 'package:chit_chat/Model/message.dart';
import 'package:chit_chat/Model/user_Chat_Model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;


class APIs{
  static FirebaseAuth auths=FirebaseAuth.instance;
  static User get userDetails=>auths.currentUser!;
  static FirebaseFirestore fire=FirebaseFirestore.instance;
  static FirebaseStorage storage=FirebaseStorage.instance;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  static late UserChat me;
  static Future<bool> userExists()async{
    return (await fire.collection('Users').doc(userDetails.uid).get()).exists;
  }
  static Future<bool> addChatUser(String email)async{
    final result=await fire.collection('Users').where('email', isEqualTo: email).get();
    if(result.docs.isNotEmpty && result.docs.first.id!=userDetails.uid){
      fire.collection('Users').doc(userDetails.uid).collection('my_users').doc(result.docs.first.id).set({});
      return true;
    }else{
      return false;
    }
  }
  static Future<void> getFirebaseMessagingToken()async{
    await fMessaging.requestPermission();
    await fMessaging.getAPNSToken().then((t){
      if(t!=null){
        me.pushToken=t;
      }
    });
  }
  static Future<void> sendPushNotification(UserChat userChat,String msg) async {
    try{
      final body = {
        "to": userChat.pushToken,
        "notification": {
          "title": userChat.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "click_action" : "User ID: ${me.id}",
        },
      };
      var res = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'), body: jsonEncode(body),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: 'key=AAAAznIlLi0:APA91bEwe20buBbCHzhhnmq3Vl6bOoiK6bt-K_0VgYQXFG329SGAfDufHy6wIXfr8aQCfpjMIyepRfNiWexGaU-27sPhmtBYl0nGTJvL_AAW2506R-t2KvfNVBHpVB34fvD_UREyGUbp'
          });
    }catch(e){
    }
  }
  static Future<void> getSelfInfo()async{
    await fire.collection('Users').doc(userDetails.uid).get().then((userDetails) async {
      if(userDetails.exists){
        me=UserChat.fromJson(userDetails.data()!);
        await getFirebaseMessagingToken();
        APIs.updateActiveStatus(true);
      }else{
        await createUser().then((value) => getSelfInfo());
      }
    });
  }
  static Future<void> createUser()async{
    final time=DateTime.now().millisecondsSinceEpoch.toString();
    final userChat=UserChat(
        about: 'Hey I\'am using chit chat!',
        createdAt: time,
        email: userDetails.email.toString(),
        id: userDetails.uid,
        image: userDetails.photoURL.toString(),
        isOnline: false,
        lastActive: time,
        name: userDetails.displayName.toString(),
        pushToken: ""
    );
    return fire.collection('Users').doc(userDetails.uid).set(userChat.toJson());
  }
  static Future<void> updateMe() async {
    await fire.collection('Users').doc(userDetails.uid).update({
      'name':me.name,
      'about':me.about
    });
  }
  static Future<void> updateProfilePicture(File file)async{
     final ext=file.path.split('.').last;
     final ref=storage.ref().child('Profile_Pictures/${userDetails.uid}.${ext}');
     await ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((p0){

     });
     me.image=await ref.getDownloadURL();
     await fire.collection('Users').doc(userDetails.uid).update({
       'image':me.image
     });
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(List<String> userIds){
      return fire.collection('Users').where('id', whereIn: userIds.isEmpty?['']:userIds).snapshots();
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId(){
     return fire.collection('Users').doc(userDetails.uid).collection('my_users').snapshots();
  }
  static Future<void> sendFirstMessage(UserChat userChat,String msg)async{
    await fire.collection('Users').doc(userChat.id).collection('my_users').doc(userDetails.uid).set({}).then((value) => sendMessage(userChat, msg));
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(UserChat userChat){
    return fire.collection('Users').where('id',isEqualTo: userChat.id).snapshots();
  }
  static Future<void> updateActiveStatus(bool isOnline) async {
    fire.collection('Users').doc(userDetails.uid).update({
      'is Online':isOnline,
      'last Active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push Token':me.pushToken
    });
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(UserChat userChat){
    return fire.collection('chats/${getConversationId(userChat.id)}/messages/').orderBy('sent',descending: true).snapshots();
  }
  ///-----------------------------------------------------------------///
  static String getConversationId(String id){
    return userDetails.uid.hashCode<=id.hashCode?'${userDetails.uid}_${id}':'${id}_${userDetails.uid}';
  }

  static Future<void> sendMessage(UserChat userChat,String msg) async{
    final time=DateTime.now().millisecondsSinceEpoch.toString();
    final Message message=Message(
        fromId: userDetails.uid,
        msg: msg,
        read: '',
        sent: time,
        toId: userChat.id,
        type: 'Text'
    );
    final ref=fire.collection('chats/${getConversationId(userChat.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value){
      sendPushNotification(userChat, msg.startsWith('http')?'image':msg);
    });
  }
  static Future<void> updateMessageReadStatus(Message message) async {
    fire.collection('chats/${getConversationId(message.fromId)}/messages/').doc(message.sent).update({
      'read':DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(UserChat userChat){
    return fire.collection('chats/${getConversationId(userChat.id)}/messages/').orderBy('sent',descending: true).limit(1).snapshots();
  }
  static Future<void> sendChatImage(UserChat chat,File file)async{
    final ext=file.path.split('.').last;
    final ref=storage.ref().child('Images/${getConversationId(chat.id)}/${DateTime.now().millisecondsSinceEpoch}.${ext}');
    await ref.putFile(file,SettableMetadata(contentType: 'image/$ext')).then((p0){

    });
    final imageUrl=await ref.getDownloadURL();
    await sendMessage(chat, imageUrl);
  }
  static Future<void> deleteMessage(Message message) async {
    await fire.collection('chats/${getConversationId(message.toId)}/messages/').doc(message.sent).delete();
    if(message.msg.startsWith('http')) {
      await storage.refFromURL(message.msg).delete();
    }
  }
  static Future<void> updateMessage(Message message,String updateMessage)async{
    await fire.collection('chats/${getConversationId(message.toId)}/messages/').doc(message.sent).update({
      'msg':updateMessage
    });
  }
}