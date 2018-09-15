import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_chat/ui/chat/chat_page.dart';

class ChatListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat List'),
      ),
      body: _ChatList(),
    );
  }
}

class _ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<_ChatList> {
  FirebaseUser _currentUser;
  List<Widget> _list = [];

  @override
  void initState() {
    _initData();
    super.initState();
  }

  void _initData() async {
    _currentUser = await FirebaseAuth.instance.currentUser();
    Firestore.instance
        .collection('chats')
        .where('peers', arrayContains: _currentUser.uid)
        .snapshots()
        .listen((data) {
      data.documents.forEach((d) async {
        String peerUserId =
        d['peers'][0] == _currentUser.uid ? d['peers'][1] : d['peers'][0];
        Widget tile = await _buildTile(peerUserId, d.documentID);
        setState(() {
          _list.add(tile);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = _currentUser != null
        ? (_list.isNotEmpty
            ? ListView(
                children: _list,
              )
            : Center(
                child: Text('No Data'),
              ))
        : Center(
            child: Text('No Current User'),
          );
    return resultWidget;
  }

  Future<Widget> _buildTile(String peerUserId, String documentId) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: peerUserId)
        .getDocuments();
    List documents = result.documents;
    return ListTile(
      title: Text(documents != null && documents.length > 0
          ? result.documents[0]['email']
          : 'N/A'),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(peerUserId, documentId)),);
      },
    );
  }

}
