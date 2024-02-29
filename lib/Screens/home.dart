import 'package:chit_chat/Auth/login_screen.dart';
import 'package:chit_chat/Helper/dialog.dart';
import 'package:chit_chat/Model/user_Chat_Model.dart';
import 'package:chit_chat/Screens/profile.dart';
import 'package:chit_chat/Widget/user_interface.dart';
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../API/auth.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<UserChat> _list=[];
  final List<UserChat> _searching=[];
  bool _searchFind=false;
  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    SystemChannels.lifecycle.setMessageHandler((message){
      if(APIs.auths.currentUser!=null) {
        if (message.toString().contains('pause')) APIs.updateActiveStatus(
            false);
        if (message.toString().contains('resume')) APIs.updateActiveStatus(
            true);
      }
      return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      // ignore: deprecated_member_use
      child: WillPopScope(
        onWillPop: (){
          if(_searchFind){
            setState(() {
              _searchFind=false;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: Icon(CupertinoIcons.home),
            onPressed: (){},),
            actions: [
              IconButton(onPressed: (){
                _searchFind=!_searchFind;
                setState(() {

                });
              }, icon: _searchFind? Icon(CupertinoIcons.clear_circled_solid) : Icon(CupertinoIcons.search)),
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen(chat:APIs.me)));
              }, icon: Icon(CupertinoIcons.ellipsis_vertical))
            ],
            title: _searchFind? TextField(
              onChanged: (val){
                _searching.clear();
                for(var i in _list){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){
                    _searching.add(i);
                  }
                  setState(() {
                    _searching;
                  });
                }
              },
              autofocus: true,
              style: TextStyle(fontSize: 17,letterSpacing: 0.5),
              decoration: InputDecoration(
                hintText: "Name,Email...",
                border: InputBorder.none,
              ),
            ):Text('Chit Chat'),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context,snapshot){
              switch(snapshot.connectionState){
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                return StreamBuilder(
                  stream: APIs.getAllUser(snapshot.data?.docs.map((e) => e.id).toList()??[]),
                  builder: (context,snapshot){
                    switch(snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                       // return Center(child: CircularProgressIndicator());
                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data=snapshot.data?.docs;
                        _list= data?.map((e) => UserChat.fromJson(e.data())).toList()??[];
                        if(_list.isNotEmpty){
                          return ListView.builder(
                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.015),
                              physics: BouncingScrollPhysics(),
                              itemCount: _searchFind?_searching.length : _list.length,
                              itemBuilder: (context,index){
                                return UserInterface(userChat:_searchFind? _searching[index]:_list[index]);
                              });
                        }else{
                          return Center(child: Text('No Connections found!',style: TextStyle(fontSize: 24,fontWeight: FontWeight.w900,color: Colors.black),));
                        }
                    }
                  },
                );
              }
            },
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.blueAccent,
            shape: CircleBorder(),
            onPressed: (){
              _AddChatUserDialog();
            },
            child: Icon(Icons.add_comment,color: Colors.white,)
          ),
        ),
      ),
    );
  }
  void _AddChatUserDialog(){
    String email="";
    showDialog(context: context, builder: (_)=>AlertDialog(
      contentPadding: EdgeInsets.only(right: 24,left: 24,top: 20,bottom: 10),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
      ),
      title: Row(
        children: [
          Icon(Icons.person,color: Colors.blueAccent,size: 28,),
          Text(' Add User')
        ],
      ),
      content: TextFormField(
        autofocus: true,
        maxLines: null,
        onChanged: (value){
          email=value;
        },
        decoration: InputDecoration(
          hintText: "Enter Email",
            prefixIcon: Icon(Icons.email,color: Colors.blue,),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15)
            )
        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },child: Text('Cancel',style: TextStyle(color: Colors.blueAccent,fontSize: 16),),),
        MaterialButton(onPressed: () async {
          Navigator.pop(context);
          if(email.isNotEmpty) {
            await APIs.addChatUser(email).then((value) {
              if (!value) {
                DialogMsg.showSnackBar(context, 'User Does not exist!');
              }
            });
          }
        },child: Text('Add',style: TextStyle(color: Colors.blueAccent,fontSize: 16),),),
      ],
    ));
  }
}
