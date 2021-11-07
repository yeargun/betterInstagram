import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dont_want/models/user.dart';
import 'package:dont_want/widgets/ProgressWidget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

import 'HomePage.dart';

class UploadPage extends StatefulWidget {
  final User gCurrentUser;

  UploadPage({this.gCurrentUser});
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin<UploadPage>  {
  File file;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController = TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  getUserCurrentLocation() async{
    Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks = await Geolocator().placemarkFromCoordinates(position.latitude, position.latitude);
    Placemark mPlaceMark = placeMarks[0];
    String completeAddressInfo = '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality},  ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea},i  ${mPlaceMark.postalCode} ${mPlaceMark.country}';
    String specificAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
    locationTextEditingController.text = specificAddress;
  }

  clearPostInfo(){
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file= null;
    });
  }

  Future<String> uploadPhoto(mImageFile) async{
    StorageUploadTask mStorageUploadTask = storageReference.child("post_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot = await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  compressingPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 90));
    setState(() {
      file = compressedImageFile;
    });

  }

  savePostInfoToFirestore({String url, String location, String description}){
    postReference.document(widget.gCurrentUser.id).collection("userPosts").document(postId).setData({
      "postId": postId,
      "owner": widget.gCurrentUser.id,
      "timestamp": timestamp,
      "likes": {},
      "username": widget.gCurrentUser.username,
      "description": description,
      "location": location,
      "url": url,
    });
  }

  controlUploadAndSave() async{
    setState(() {
      uploading = true;
    });
    await compressingPhoto();

    String downloadUrl = await uploadPhoto(file);

    savePostInfoToFirestore(url: downloadUrl, location: locationTextEditingController.text, description: descriptionTextEditingController.text);
    descriptionTextEditingController.clear();
    locationTextEditingController.clear();

    setState(() {
      file = null;
      uploading = false;
      postId = Uuid().v4();
    });

  }

  displayUploadFormScreen(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.grey), onPressed: ()=> Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()), (Route<dynamic> route) => false,),),
        title: Text("New post", style: TextStyle(fontSize: 24, color: Colors.grey, fontWeight: FontWeight.bold)),
        actions: <Widget>[
          FlatButton(
              onPressed: uploading ? null : () => controlUploadAndSave(),
              child: Text("Share", style: TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold, fontSize: 16))
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          uploading ? linearProgress() : Text(""),
          Container(
            height: 230,
            width: MediaQuery.of(context).size.width * 0.8,
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 12)),
          ListTile(
            leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(widget.gCurrentUser.url),),
            title: Container(
              width: 250,
              child: TextField(
                style: TextStyle(color: Colors.lightGreenAccent),
                controller: descriptionTextEditingController,
                decoration: InputDecoration(
                  hintText: "Description about image",
                  hintStyle: TextStyle(color: Colors.pink),
                  border: InputBorder.none,
                ),
              )
            )
          ),
          Divider(),
          ListTile(
              leading: Icon(Icons.person_pin_circle, color: Colors.pink, size: 36),
              title: Container(
                  width: 250,
                  child: TextField(
                    style: TextStyle(color: Colors.lightGreenAccent),
                    controller: locationTextEditingController,
                    decoration: InputDecoration(
                      hintText: "write the location here",
                      hintStyle: TextStyle(color: Colors.pink),
                      border: InputBorder.none,
                    ),
                  )
              )
          ),
          Container(
            width: 220,
            height: 110,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
              color: Colors.green,
              icon: Icon(Icons.location_on, color: Colors.pink),
              label: Text("Get my current location", style: TextStyle(color: Colors.purple)),
              onPressed: () =>getUserCurrentLocation(),
            )
          )
        ],
      )
    );
  }

  pickImageFromGallery() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 680,
        maxWidth: 970
    );
    setState(() {
      this.file = imageFile;
    });
  }

  captureImageWithCamera() async{
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970
    );
    setState(() {
      this.file = imageFile;
    });
  }


  takeImage(mContext){
    return showDialog(
        context: mContext,
        builder: (context){
          return SimpleDialog(
            title: Text("New Post", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            children: <Widget>[
              SimpleDialogOption(
                child: Text("Capture Image with Camera", style: TextStyle(color: Colors.black)),
                onPressed: captureImageWithCamera,
              ),
              SimpleDialogOption(
                child: Text("Select image from gallery", style: TextStyle(color: Colors.black)),
                onPressed: pickImageFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cancel AHAHAH", style: TextStyle(color: Colors.black)),
                onPressed: () =>Navigator.pop(context),
              )
            ],
          );
        }
    );
  }

  displayUploadScreen(){
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.add_photo_alternate, color: Colors.grey, size:200),
          Padding(
            padding: EdgeInsets.only(top:20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              child: Text("Upload Image", style: TextStyle(color: Colors.white, fontSize: 20),),
              color: Colors.green,
              onPressed: () => takeImage(context),
            )
          )
        ],
      ),
    );
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return file == null ? displayUploadScreen() : displayUploadFormScreen();
  }
}