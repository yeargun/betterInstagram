import 'package:flutter/material.dart';

import 'PostWidget.dart';

class PostTile extends StatelessWidget {

  final Post post;
  PostTile(this.post);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Image.network(post.url),
        onTap: () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              Post(
                postId: post.postId,
                ownerId: post.ownerId,
                //this.timestamp,
                likes: post.likes,
                username: post.username,
                description: post.description,
                location: post.location,
                url: post.url,
                likeCount: post.likeCount,),
          )
          ),
        }
    );
  }
}