import 'dart:io';

import 'package:chit_chat/API/auth.dart';
import 'package:chit_chat/Auth/login_screen.dart';
import 'package:chit_chat/Helper/dialog.dart';
import 'package:chit_chat/Model/user_Chat_Model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
class ProfileScreen extends StatefulWidget{
  final UserChat chat;

  const ProfileScreen({super.key, required this.chat});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey=GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    mq=MediaQuery.of(context).size;
    return GestureDetector(
      onTap: ()=>FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: mq.height*0.03,),
                Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: _image!=null ? CircleAvatar(
                        radius: mq.height*0.12,
                        backgroundImage: FileImage(File(_image!)),
                      ) : CircleAvatar(
                        radius: mq.height*0.12,
                        backgroundImage: NetworkImage(widget.chat.image),
                      )
                    ),
                    Positioned(
                      bottom: 0,
                      right: mq.width*0.2,
                      child: MaterialButton(onPressed: (){
                        _showBottomModel();
                      },shape: CircleBorder(),
                        child: Icon(Icons.edit,color: Colors.blue,),
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                SizedBox(height: mq.height*0.03,),
                Text(widget.chat.email,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.black54),),
                SizedBox(height: mq.height*0.03,),
                Container(
                  width: mq.width*0.9,
                  child: TextFormField(
                    onSaved: (val){
                      APIs.me.name=val ?? '';
                    },
                    validator: (val){
                      val!=null && val.isNotEmpty ? null : "Required Field";
                    },
                    initialValue: widget.chat.name,
                    decoration: InputDecoration(
                      prefixIcon: Icon(CupertinoIcons.person,color: Colors.blue,),
                      hintText: "eg.Nouman Sheikh",
                      label: Text('Name'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                ),
                SizedBox(height: mq.height*0.02,),
                Container(
                  width: mq.width*0.9,
                  child: TextFormField(
                    onSaved: (val){
                      APIs.me.about=val ?? '';
                    },
                    validator: (val){
                      val!=null && val.isNotEmpty ? null : "Required Field";
                    },
                    initialValue: widget.chat.about,
                    decoration: InputDecoration(
                        prefixIcon: Icon(CupertinoIcons.info,color: Colors.blue,),
                        hintText: "eg.Hi I'am Human...",
                        label: Text('About'),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                        )
                    ),
                  ),
                ),
                SizedBox(height: mq.height*0.04,),
                ElevatedButton.icon(onPressed: (){
                 if(_formKey.currentState!.validate()){
                   _formKey.currentState!.save();
                   APIs.updateMe().then((value) => DialogMsg.showSnackBar(context, 'Updated Successfully...'));
                 }
                }, icon: Icon(Icons.update,size: 28,color: Colors.white,),label: Text('UPDATE',style: TextStyle(fontSize: 19,fontWeight: FontWeight.bold,color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(mq.width*0.5,mq.height*0.06),
                    backgroundColor: Colors.blue
                  ),),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async{
            await APIs.updateActiveStatus(false);
            await APIs.auths.signOut();
            await GoogleSignIn().signOut().then((value) => {
              APIs.auths=FirebaseAuth.instance,
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()))
            });
          },
          icon: Icon(Icons.logout),
          label: Text('LogOut',style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }
  void _showBottomModel(){
    showModalBottomSheet(shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
    ),context: context, builder: (context){
      return ListView(
        padding: EdgeInsets.only(top: mq.height*0.02,bottom: mq.height*0.05),
       shrinkWrap: true,
        children: [
         Text('Pick Profile Picture',style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
          SizedBox(height: mq.height*0.02,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery,imageQuality: 70);
                if(image!=null){
                  _image=image.path;
                  setState(() {

                  });
                  APIs.updateProfilePicture(File(_image!)).then((value) {
                    DialogMsg.showSnackBar(context, "Profile Updated");
                  });
                  Navigator.pop(context);
                }
              }, child: Image.asset('assets/images/gallery.png'),style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: Size(mq.width*0.3,mq.height*0.15)
              ),),
              ElevatedButton(onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if(image!=null){
                  _image=image.path;
                  setState(() {

                  });
                  APIs.updateProfilePicture(File(_image!)).then((value) {
                    DialogMsg.showSnackBar(context, "Profile Updated");
                  });
                  Navigator.pop(context);
                }
              }, child: Image.asset('assets/images/camera.png'),style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  fixedSize: Size(mq.width*0.3,mq.height*0.15)
              ),)
            ],
          )
        ],
      );
    });
  }
}