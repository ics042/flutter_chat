import 'package:flutter/material.dart';

class ChatMessage extends StatefulWidget {
  ChatMessage({this.text, this.isSendMessage});

  final String text;
  final bool isSendMessage;

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
              child: Text(widget.text),
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
              child: Text(widget.text),
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
}