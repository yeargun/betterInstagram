import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dont_want/models/user.dart';
import 'package:dont_want/pages/HomePage.dart';
import 'package:dont_want/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;
  EditProfilePage({this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User user;
  bool _profileNameValid = true;
  bool _bioValid = true;

  @override
  void initState() {
    super.initState();
    getAndDisplayUserInformation();
  }
  getAndDisplayUserInformation() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await userReference.document(widget.currentOnlineUserId).get() ;
    user = User.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user.profileName;
    bioTextEditingController.text = user.bio;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      key: _scaffoldGlobalKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.pink),
        title: Text("Edit Profile", style: TextStyle(color: Colors.pink)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.done, color: Colors.grey, size:30), onPressed:()=> Navigator.pop(context),),
        ],
      ),
      body: loading ? circularProgress() : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom:7),
                  child: CircleAvatar(
                    radius: 52,
                    backgroundImage: CachedNetworkImageProvider(user?.url),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: <Widget>[
                      createProfileNameTextField(),
                      createBioTextFormField(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 29, left: 50, right: 50),
                  child: RaisedButton(
                    onPressed: updateUserData,
                    child: Text(
                        "Update",
                      style: TextStyle(color: Colors.pink, fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, left: 50, right: 50),
                  child: RaisedButton(
                    color: Colors.red,
                    onPressed: logoutUser,
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.pink, fontSize: 14),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
    )
    );
  }

  logoutUser() async{
    gSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context)=> HomePage()));
  }

  updateUserData(){
    setState(() {
      profileNameTextEditingController.text.trim().length <3 || profileNameTextEditingController.text.isEmpty ?
          _profileNameValid = false : _profileNameValid=true;

      bioTextEditingController.text.trim().length > 110 ? _bioValid = false : _bioValid= true;
    });
    if(_bioValid && _profileNameValid)
      userReference.document(widget.currentOnlineUserId).updateData({
        "profileName": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text
      });

    SnackBar successSnackBar = SnackBar(content: Text("Text has been updated successfuly"));
    _scaffoldGlobalKey.currentState.showSnackBar(successSnackBar);

  }

  Column createProfileNameTextField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top:13),
          child: Text(
            "Profile Name", style: TextStyle(color: Colors.grey)
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.grey),

          controller: profileNameTextEditingController,
          decoration: InputDecoration(
            hintText: "Write profile name",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            hintStyle: TextStyle(color: Colors.purple),
            errorText: _profileNameValid ? null : "Profile name is very short",
          ),
        )
      ],
    );
  }

  Column createBioTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top:13),
          child: Text(
              "Bio", style: TextStyle(color: Colors.grey)
          ),
        ),
        TextField(
          style: TextStyle(color: Colors.grey),

          controller: bioTextEditingController,
          decoration: InputDecoration(
            hintText: "Write bio name",
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            hintStyle: TextStyle(color: Colors.purple),
            errorText: _bioValid ? null : "Biois very short",
          ),
        )
      ],
    );
  }
}