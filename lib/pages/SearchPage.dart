import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dont_want/models/user.dart';
import 'package:dont_want/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'ProfilePage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}




class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  emptyTheTextFromField(){
    searchTextEditingController.clear();
  }

  controlSearching(String str){
    Future<QuerySnapshot> allUsers = userReference.where("profileName", isGreaterThanOrEqualTo: str).getDocuments();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  AppBar searchPageHeader(){
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(
        style: TextStyle(fontSize: 18, color: Colors.white),
        controller: searchTextEditingController,
        decoration: InputDecoration(
          hintText: "Search here...",
          hintStyle: TextStyle(color:Colors.grey),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)
          ),
          filled: true,
          prefixIcon: Icon(Icons.person_pin, color: Colors.white, size: 30,),
          suffixIcon: IconButton(icon: Icon(Icons.clear, color: Colors.white), onPressed: emptyTheTextFromField,)
        ),
        onFieldSubmitted: controlSearching,
      )
    );
  }

  Container displayNoSearchResultScreen(){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.group, color: Colors.grey, size:200),
            Text(
              "Search Users",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 65)
            )
          ],
        )
      )
    );
  }



  displayUsersFoundScreen(){
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData){
          return circularProgress();
        }
        List<UserResult> searchUsersResult = [];
        dataSnapshot.data.documents.forEach((document){
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUsersResult.add(userResult);
        });
        print(searchUsersResult.length);
        return ListView(
          children: searchUsersResult,
        );}
        /*return ListView.builder(
            itemCount: searchUsersResult.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text("${index + 1}"),
                  onTap: () {
                    SnackBar snackBar = SnackBar(
                        content: Text("Tapped : ${searchUsersResult[index].eachUser.username}")
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                ),
              );
            }
        );
      }*/
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchPageHeader(),
      body: futureSearchResults == null ? displayNoSearchResultScreen() : displayUsersFoundScreen(),
    );
  }

  @override
  bool get wantKeepAlive => true;
}





class UserResult extends StatelessWidget {
  @override
  final User eachUser;
  PageController pageController;
  UserResult(this.eachUser);

  onTapPageChange(int pageIndex){
    pageController.animateToPage(pageIndex, duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Container(
        color: Colors.pink,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: ()=> {
                print("sadgsg"),
                Navigator.push(context,MaterialPageRoute(builder: (context) => ProfilePage(userProfileId: eachUser.id)),),
      },
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.black, backgroundImage: CachedNetworkImageProvider(eachUser.url),),
                title: Text(eachUser.profileName, style: TextStyle(
                    color: Colors.black,
                    fontSize: 16, fontWeight: FontWeight.bold
                )),
                subtitle: Text(eachUser.username, style: TextStyle(
                  color: Colors.black, fontSize: 13,
                )),
              )
            )
          ]
        )
      )
    );
  }
}