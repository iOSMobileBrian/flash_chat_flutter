
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {

  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  User loggedInUser;
  String message;

  void getCurrentUser() async {

    try{

      final user =  _auth.currentUser;

      if (user != null){
        loggedInUser = user;
        print(loggedInUser);
      }

    }

    catch (e){

    }
  }

  void getMessages() async{

    final chat = await _fireStore.collection('Messages').get();

    for (var messages in chat.docs){
      print(messages.data());
    }

  }

  void messagesStream() async {

    await for(var snapshot in _fireStore.collection('Messages').snapshots()){

      for (var message in snapshot.docs){
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                messagesStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _fireStore.collection('Messages').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {

                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.blueAccent,
                      ),
                    );
                  }
                    final messages = snapshot.data.docs.reversed;

                    List<MessageBubble> messageBubbles = [];
                    for (var msg in messages) {
                      final messageText = msg.get('text');
                      final messageSender = msg.get('sender');
                      final currentUser = loggedInUser.email;
                      final messageBubble = MessageBubble(sender: messageSender, text: messageText,isMe: currentUser == messageSender,);
                      messageBubbles.add(messageBubble);
                    }
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                        children: messageBubbles,
                      ),
                    );

                }

            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      controller.clear();
                      _fireStore.collection('Messages').add({
                        'sender': loggedInUser.email,
                        "text": message,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MessageBubble extends StatelessWidget {

  MessageBubble({this.sender, this.text, this.isMe});

  final String sender;
  final String text;
  bool isMe = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(sender, style: TextStyle(color: Colors.black45, fontSize: 12.0),),
          Material(
            borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(30.0), bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)): 
            BorderRadius.only(bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0), topRight: Radius.circular(30.0)),
            elevation: 5.0,
            color: isMe ? Colors.lightBlueAccent : Colors.green,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
              child: Text(
                '$text',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
