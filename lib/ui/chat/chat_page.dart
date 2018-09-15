import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_chat/ui/chat/chat_message.dart';
import 'package:flutter_chat/common/constants.dart';

class ChatPage extends StatefulWidget {
  ChatPage(this.peerUserId, this.documentId);

  final String peerUserId;
  final String documentId;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  FirebaseUser _currentUser;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  void _initData() async {
    _currentUser = await FirebaseAuth.instance.currentUser();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Chat"),
          elevation:
          Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0),
      body: _buildBody(), //new
    );
  }

  Widget _buildBody() {
    return Container(
        child: Column(children: <Widget>[
          Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('chats').document(widget.documentId).collection(widget.documentId).orderBy('created_at', descending: true).snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child:Text('Loading...'));
                  final List<ChatMessage> _messages = <ChatMessage>[];
                  _messages.addAll(
                      snapshot.data.documents.map((DocumentSnapshot document) {
                        return ChatMessage(
                          message: document['message'],
                          isSendMessage: document['sendUserId'] == _currentUser.uid,
                          messageType: document['type']
                        );
                      }).toList());
                  return ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => _messages[index],
                    itemCount: _messages.length,
                  );
                },
              )),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ]),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey[200])))
            : null);
  }
  void _handleSubmitted(String message, int type) async {
    Firestore.instance.collection('chats').document(widget.documentId).collection(widget.documentId).document()
        .setData({ 'sendUserId': _currentUser.uid, 'message': message, 'type': type, 'created_at': DateTime.now().toString()});
    _textController.clear();
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                  icon: Icon(Icons.photo_camera),
                  onPressed: (){
                    _sendImage();
                  }
              ),
            ),
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.length > 0;
                  });
                },
                decoration:
                InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? CupertinoButton(
                  child: Text("Send"),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text, typeMsg)
                      : null,
                )
                    : IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text, typeMsg)
                      : null,
                )),
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200])))
              : null),
    );
  }

  void _sendImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      String fileName = DateTime.now().toString();
      StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = reference.putFile(image);

      Uri downloadUrl = (await uploadTask.future).downloadUrl;
      String imageUrl = downloadUrl.toString();
      _handleSubmitted(imageUrl, typeImage);
    }
  }
}
