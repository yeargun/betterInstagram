import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dont_want/models/user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'CreateAccountPage.dart';
import 'NotificationsPage.dart';
import 'ProfilePage.dart';
import 'SearchPage.dart';
import 'TimeLinePage.dart';
import 'UploadPage.dart';


final GoogleSignIn gSignIn = GoogleSignIn();
final userReference = Firestore.instance.collection("users");
final StorageReference storageReference = FirebaseStorage.instance.ref().child("Posts' Pictures");
final postReference = Firestore.instance.collection("posts");
final DateTime timestamp = DateTime.now();
User currentUser;

class HomePage extends StatefulWidget{
  @override
  _HomePageState createState()=> _HomePageState();

}

class _HomePageState extends State<HomePage>{

  bool isSignedIn = false;
  PageController pageController;
  int getPageIndex = 0;


  void initState(){
    super.initState();
    pageController = PageController();
    print("asdg");

    gSignIn.onCurrentUserChanged.listen((gSigninAccount){
      controlSignIn(gSigninAccount);
    }, onError: (gError){
    print("Error message" + gError);
    });

    gSignIn.signInSilently(suppressErrors: false).then((gSignInAccount){
      controlSignIn(gSignInAccount);
    }).catchError((gError){
      print("Error message"+ gError.toString());
    });
  }




  controlSignIn(GoogleSignInAccount signInAccount) async{
    if(signInAccount != null){
      await saveUserInfoToFireStore();
      setState(() {
        isSignedIn = true;
      });
    }
    else
      setState(() {
        isSignedIn = false;
      });
  }

  saveUserInfoToFireStore() async {
    final GoogleSignInAccount gCurrentUser = gSignIn.currentUser;
    print(gCurrentUser);
    DocumentSnapshot documentSnapshot =await userReference.document(gCurrentUser.id).get();
    if(!documentSnapshot.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountPage()));
      userReference.document(gCurrentUser.id).setData({
        "id": gCurrentUser.id,
        "profileName": gCurrentUser.displayName,
        "username": username,
        "url": gCurrentUser.photoUrl,
        "email": gCurrentUser.email,
        "bio": "",
        "timestamp": timestamp,
      });
      documentSnapshot = await userReference.document(gCurrentUser.id).get();
    }
    
    currentUser = User.fromDocument(documentSnapshot);
  }

  buildHomeScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
          TimeLinePage(),
          SearchPage(),
          UploadPage(gCurrentUser: currentUser,),
          NotificationsPage(),
          ProfilePage(userProfileId: currentUser.id),
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: getPageIndex,
        onTap: onTapPageChange,
        backgroundColor: Theme.of(context).accentColor,
        activeColor: Colors.white,
        inactiveColor: Colors.blueGrey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.photo_camera, size: 37)),
          BottomNavigationBarItem(icon: Icon(Icons.favorite)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
        ],
      ),
    );
  }

  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  loginUser(){
    gSignIn.signIn();
  }

  logoutUser(){
    gSignIn.signOut();
  }

  whenPageChanges(int pageIndex){
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapPageChange(int pageIndex){
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  buildSignInScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "betterTiktok",
              style: TextStyle(fontSize: 111, color: Colors.amber),
            ),
            GestureDetector(
              onTap: loginUser,
              child: Container(
                width: 270,
                height: 65,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/agresiz gözlük.jfif"),
                    fit: BoxFit.cover
                  )
                ),
              ),
            ),
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context){
    if(isSignedIn){
      return buildHomeScreen();
    }
    else{
      return buildSignInScreen();
    }
  }
}