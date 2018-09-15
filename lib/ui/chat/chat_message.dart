import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_chat/common/constants.dart';

class ChatMessage extends StatefulWidget {
  ChatMessage({this.message, this.isSendMessage, this.messageType});

  final String message;
  final bool isSendMessage;
  final int messageType;

  @override
  _ChatMessageState createState() => _ChatMessageState();

}

class _ChatMessageState extends State<ChatMessage> with SingleTickerProviderStateMixin{

  AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    super.initState();
    animationController.forward();
  }

  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildMessage(context),
      ),
    );
  }

  List<Widget> _buildMessage(BuildContext context) {
    String _name = widget.isSendMessage ? 'Me' : 'Admin';
    return widget.isSendMessage
        ? <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(child: Text(_name[0])),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_name, style: Theme.of(context).textTheme.subhead),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: _buildContent(),
            ),
          ],
        ),
      ),
    ]
        : <Widget>[
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(_name, style: Theme.of(context).textTheme.subhead),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: _buildContent(),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(child: Text(_name[0]), backgroundColor: Colors.black,),
      ),
    ];
  }

  Widget _buildContent() {
    Widget content;
    switch (widget.messageType) {
      case typeMsg:
        content = Text(widget.message);
        break;
      case typeImage:
        content = CachedNetworkImage(
          placeholder: Container(
            child: CircularProgressIndicator(),
            width: 200.0,
            height: 200.0,
            padding: EdgeInsets.all(70.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
          ),
          imageUrl: widget.message,
          width: 200.0,
          height: 200.0,
          fit: BoxFit.cover,
        );
        break;
    }
    return content;
  }
}