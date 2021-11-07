import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dont_want/models/user.dart';
import 'package:dont_want/pages/HomePage.dart';
import 'package:flutter/material.dart';

import 'ProgressWidget.dart';

class Post extends StatefulWidget {

  final String postId;
  final String ownerId;
  //final String timestamp;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;


  Post({
    this.postId,
    this.ownerId,
    //this.timestamp,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      //timestamp: documentSnapshot["timestamp"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
    );
  }

  int getTotalNumberOfLikes(likes){
    if(likes == null)
      return 0;
    int counter = 0;
    likes.values.forEach((eachValue){
      if(eachValue == true)
        counter++;
    });
    return counter;
  }


  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    likes: this.likes,
    username: this.username,
    description: this.description,
    location: this.location,
    url: this.url,
    likeCount: getTotalNumberOfLikes(this.likes),
  );
}

class _PostState extends State<Post> {

  final String postId;
  final String ownerId;
  //final String timestamp;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.id;


  _PostState({
    this.postId,
    this.ownerId,
    //this.timestamp,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom:12),
        child: ListView(
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            createPostHead(),
            createPostPicture(),
            createPostFooter(),
          ],
        )
    );
  }



  createPostHead() {
    return FutureBuilder(
        future: userReference.document(ownerId).get(),
        builder: (context, dataSnapshot){
          if(dataSnapshot.connectionState != ConnectionState.waiting || !dataSnapshot.hasData)
            return circularProgress();
          //Post posts = Post.fromDocument(dataSnapshot.data);
          print(dataSnapshot );
          bool isPostOwner = currentOnlineUserId == ownerId;


          return ListTile(
            //leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(posts.url),backgroundColor: Colors.grey,),
            title: GestureDetector(
              onTap: ()=> print("show profile"),
              child: Text(
                //posts.username,
                "sdf",
                style: TextStyle(color: Colors.white24,),
              ),
            ),
            subtitle: Text(location, style:TextStyle(color: Colors.white24)),
            trailing: isPostOwner ? IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white24),
              onPressed: ()=> print("deleted"),
            ) : Text(""),
          );
        }
    );
  }

  createPostPicture() {
    return GestureDetector(
        onDoubleTap: ()=>print("you liked the post congrats amk"),
        onTap: ()=> print("attached human display no cap"),
        child: Container(
            height: 415.429,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.network(url),
              ],
            )
        ),
      /*child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.network(url),
          ],
        )*/
    );
  }

  createPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top:40, left:20),),
            GestureDetector(
              onTap: ()=> print("liked post"),
              child: Icon(
                Icons.favorite,
                size: 28,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(top:20),),
            GestureDetector(
              onTap: ()=> print("show comments"),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 28,
                color: Colors.lightGreen,
              ),
            ),
            Padding(padding: EdgeInsets.only(top:20),),
            GestureDetector(
              onTap: ()=> print("share post"),
              child: Icon(
                Icons.share_outlined ,
                size: 28,
                color: Colors.lightBlue,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(left: 20),
                child: Text(
                  "$likeCount likes",
                  style: TextStyle(color:Colors.pink, fontWeight: FontWeight.bold),
                )
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left:20),
              child: Text("$username ", style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text(description, style: TextStyle(color: Colors.lightBlue)),
            )
          ],
        )
      ],
    );
  }

}