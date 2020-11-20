import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_realtime_chat_mobile/repository/SocketChatRepository.dart';

void main() {
  runApp(MyApp());
}

class Message {
  String message;
  String senderName;
  int sendAt;

  Message.fromJson(Map<String, dynamic> json){
    message = json["message"];
    senderName = json["sender_name"];
    sendAt = int.parse(json["send_at"]);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: double.infinity),
          Text("Input your name"),
          SizedBox(height: 8),
          Container(
            width: 250,
            child: TextField(
              onChanged: (value) => setState(() => _name = value),
              decoration: InputDecoration(
                hintText: "Name"
              ),
            ),
          ),
          SizedBox(height: 8),
          MaterialButton(
            color: Theme.of(context).primaryColor,
            disabledColor: Theme.of(context).primaryColor.withOpacity(0.5),
            onPressed: _name == "" ? null : () => Navigator
                .of(context)
                .push(MaterialPageRoute(builder: (_) => ChatPage(name: _name))),
            child: Text("Login",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String name;

  ChatPage({@required this.name});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<Message> _messages = [];
  SocketChatRepository _chatRepository = SocketChatRepository.instance;

  TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatRepository.addEventListener(SocketChatRepository.EVENT_CONNECT, (data){
        print("On Connected");
      });
      _chatRepository.addEventListener(SocketChatRepository.EVENT_SOMEONE_SEND_MESSAGE, (data){
        setState(() {
          _messages.add(Message.fromJson(data));
        });
      });
      _chatRepository.connect(header: { "username" : widget.name });
      getRecentChat().then((value) => setState(() => _messages.addAll(value)));
    });
  }

  Future<List<Message>> getRecentChat() async {
    try {
      Response response = await Dio().get("http://192.168.43.63:8888/simple-realtime-chat-rest/index.php/chat/recent");
      var listMessage = <Message>[];
      response.data["data"]?.forEach((it){
        listMessage.add(Message.fromJson(it));
      });
      return listMessage;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat Room"),
          leading: null,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (_, index) => ChatMessageItem(
                  message: _messages[index],
                  myName: widget.name,
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: <Widget>[
                SizedBox(width: 25),
                Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 50,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextFormField(
                      onChanged: (it){},
                      controller: _chatController,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                        hintText: "Write a message",
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Material(
                  color: Theme.of(context).primaryColor,
                  shape: CircleBorder(),
                  child: InkWell(
                    onTap: (){
                      _chatRepository.emit(SocketChatRepository.ACTION_SEND_MESSAGE, { "message" : _chatController.text});
                      _chatController.text = "";
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: Icon(Icons.send, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                SizedBox(width: 25),
              ],
            ),
            SizedBox(height: 25),
          ],
        ),
      ),
    );
  }
}

class ChatMessageItem extends StatelessWidget {
  final Message message;
  final String myName;

  ChatMessageItem({@required this.message, @required this.myName});

  @override
  Widget build(BuildContext context) {
    if(message.senderName == myName){
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(width: 25),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(message.message,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height:  5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(DateFormat("dd/MM/yyyy HH:mm:ss")
                              .format(DateTime.fromMillisecondsSinceEpoch(message.sendAt)),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height:  15),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(message.senderName),
        SizedBox(height: 5),
        Row(
          children: <Widget>[
            Flexible(
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xff7e7e7e),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.message,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(DateFormat("dd/MM/yyyy HH:mm:ss")
                            .format(DateTime.fromMillisecondsSinceEpoch(message.sendAt)),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
  }

}