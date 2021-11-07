import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dont_want/models/user.dart';
import 'package:dont_want/pages/HomePage.dart';
import 'package:dont_want/widgets/HeaderWidget.dart';
import 'package:dont_want/widgets/PostTileWidget.dart';
import 'package:dont_want/widgets/PostWidget.dart';
import 'package:dont_want/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int countPost = 0;
  List<Post> postList = [];
  String postOrientation = "grid";


  void initState(){
    getAllProfilePosts();
  }

  @override
  createProfileTopView(){
    return FutureBuilder(
      future: userReference.document(widget.userProfileId).get(),
        builder: (context, dataSnapshot){
          if(!dataSnapshot.hasData){
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          return Padding(
            padding: EdgeInsets.all(17),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(user.url),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              createColumns("posts", 0),
                              createColumns("followers", 0),
                              createColumns("following", 0),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              currentOnlineUserId == widget.userProfileId ?
                              createButton() : Text("sdf"),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 13),
                    child: Text(
                      user.username,
                      style: TextStyle(fontSize:14, color: Colors.lightGreenAccent),
                    )
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    user.profileName,
                    style: TextStyle(fontSize:18, color: Colors.lightGreenAccent),
                  )
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 3),
                    child: Text(
                      user.bio,
                      style: TextStyle(fontSize:18, color: Colors.greenAccent),
                    )
                )
              ],
            ),
          );
        }
    );

  }

  createButton(){
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if(ownProfile){
      return createButtonTitleAndFunction(title: "Edit Profile", performFunction: editUserProfile);
    }
  }

  createButtonTitleAndFunction({String title, Function performFunction}){
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: FlatButton(
        child: Container(
          width: 245,
          height: 26,
          child: Text(title, style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold)),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.amber, border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: performFunction,
      )
    );
  }

  editUserProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  Column createColumns(String title, int count){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  header(context, strTitle: "Profile"),
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
          Divider(),
          createListAndGridPostOrientation(),
          Divider(height: 0,),
          displayCreateProfilePost(),
        ],
      )
    );
  }

  displayCreateProfilePost(){
    if(loading)
      return circularProgress();
    if(postList.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30),
              child: Icon(Icons.photo_library, color: Colors.grey, size:200),
            ),
            Padding(
              padding: EdgeInsets.only(top:20),
              child: Text("no posts", style: TextStyle(color: Colors.white10, fontSize: 40, fontWeight: FontWeight.bold),),
            )
          ],
        ),
      );
    }
    else if(postOrientation == "grid"){
      List<GridTile> gridTiles = [];
      postList.forEach((eachPost) {gridTiles.add(GridTile(child: PostTile(eachPost),)); });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
    else if(postOrientation == "list"){
      List<ListTile> listTiles = [];
      postList.forEach((eachPost) {listTiles.add(ListTile(title: Post(postId: eachPost.postId,
        ownerId: eachPost.ownerId,
        //timestamp: documentSnapshot["timestamp"],
        likes: eachPost.likes,
        username: eachPost.username,
        description: eachPost.description,
        location: eachPost.location,
        url: eachPost.url,),)); });
      return ListView(

        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: listTiles,
      );
      return Column(
          children: postList,
      );
    }
    else{
      
    }
  }

  getAllProfilePosts() async{
    setState(() {
      loading = true;
    });
    
    QuerySnapshot querySnapshot = await postReference.document(widget.userProfileId).collection("userPosts").orderBy("timestamp",descending: true).getDocuments();
    setState(() {
      loading = false;
      countPost = querySnapshot.documents.length;
      postList = querySnapshot.documents.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });

  }

  createListAndGridPostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.grid_on),
            color: postOrientation == "grid" ? Theme.of(context).primaryColor: Colors.grey,
            onPressed: ()=> setOrientation("grid"),
        ),
        IconButton(
          icon: Icon(Icons.list),
          color: postOrientation == "list" ? Theme.of(context).primaryColor: Colors.grey,
          onPressed: ()=> setOrientation("list"),
        ),
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
  
}