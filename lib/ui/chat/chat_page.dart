import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_chat/ui/chat/chat_message.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isComposing = false;
  FirebaseUser currentUser;

  @override
  void initState() async{
    currentUser = await FirebaseAuth.instance.currentUser();
    super.initState();
  }


  void _handleSubmitted(String text) async {
    Firestore.instance.collection('chat').document()
        .setData({ 'sendUser': currentUser.email, 'message': _textController.text, 'created_at': DateTime.now().toString()});
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
                  onPressed: (){}
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
                onSubmitted: _handleSubmitted,
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
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )
                    : IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )),
          ]),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200])))
              : null),
    );
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
                stream: Firestore.instance.collection('chat').where("sendUser", isEqualTo: currentUser.email).snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child:Text('Loading...'));
                  final List<ChatMessage> _messages = <ChatMessage>[];
                  _messages.addAll(
                      snapshot.data.documents.map((DocumentSnapshot document) {
                        return ChatMessage(
                          text: document['message'],
                          isSendMessage: true,
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
}
