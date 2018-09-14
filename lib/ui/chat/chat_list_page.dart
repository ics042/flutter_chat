import 'package:flutter/material.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat List'),),
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
    _getCurrentUser();
    super.initState();
  }

  void _getCurrentUser() async {
    _currentUser = await FirebaseAuth.instance.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    Widget resultWidget =
    _currentUser != null ?
    StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('chats').where('peers', arrayContains: _currentUser.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);
        _buildList(snapshot.data.documents).then((v) => setState(() {
          _list = v;
        }));
        return ListView(
          children: _list,
        );
      },
    ) : Center(child: Text('No Current User'),);
    return resultWidget;
  }
  Future<Widget> _buildTile(String peerUserId) async {
    final QuerySnapshot result = await Firestore.instance.collection('users').where('id', isEqualTo: peerUserId).getDocuments();
    List documents = result.documents;
    return  ListTile(
      title: Text(documents != null && documents.length > 0 ? result.documents[0]['email'] : 'N/A'),
    );
  }

  Future<List<Widget>> _buildList(List<DocumentSnapshot> documents) async {
    List<Widget> list = [];
    for (var d in documents) {
      String peerUserId = d['peers'][0] == _currentUser.uid ? d['peers'][1] : d['peers'][0];
      list.add(await _buildTile(peerUserId));
    }
    return list;
  }
}