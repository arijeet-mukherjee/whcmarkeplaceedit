import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/Conversation.dart';
import 'package:answer_me/models/Message.dart';
import 'package:answer_me/models/User.dart' as u;
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/providers/ConversationProvider.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/FriendMessageCard.dart';
import 'package:answer_me/widgets/MyMessageCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Conversation conversation;
  final u.User user;
  const ChatScreen({Key key, this.conversation, this.user}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageTextEditController = TextEditingController();
  Conversation conversation;

  Message message;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    AuthProvider _auth = Provider.of<AuthProvider>(context, listen: false);
    message = Message();

    if (widget.conversation != null) {
      conversation = widget.conversation;
      message.conversationId = conversation.id;
      message.userId = _auth.user.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } else {
      print(widget.user);
      setState(() {
        conversation = new Conversation();
        conversation.user = widget.user;
        conversation.messages = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarLeadingButton(),
        title: Text(
          '${conversation.user.displayname}',
          style: Theme.of(context).textTheme.headline6,
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.safeBlockHorizontal * 4,
              vertical: SizeConfig.safeBlockVertical * 3,
            ),
            itemCount: conversation.messages.length,
            itemBuilder: (context, index) =>
                conversation.messages[index].userId == conversation.user.id
                    ? FriendMessageCard(
                        message: conversation.messages[index],
                        imageUrl: conversation.user.avatar,
                      )
                    : MyMessageCard(
                        message: conversation.messages[index],
                      ),
          )),
          // FriendMessageCard(),
          // MyMessageCard(),
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(12),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(width: 10),
                Expanded(
                    child: Container(
                      child: new ConstrainedBox(constraints: BoxConstraints(
                        maxHeight: 300,
                      ),
                      child:TextField(
                      controller: messageTextEditController,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your message...',
                      hintStyle: TextStyle()),
                      ) ,
                      ),
                      
                    )
                    
                    /* TextField(
                      controller: messageTextEditController,
                      decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Type your message...',
                      hintStyle: TextStyle()),
                      ) */
                ),
                Provider.of<ConversationProvider>(context).busy
                    ? CircularProgressIndicator()
                    : InkWell(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());

                          if (messageTextEditController.text.isEmpty) return;
                          message.body = messageTextEditController.text.trim();
                          print("Message From Chat :" +
                              message.toJson().toString());
                          if (conversation.id == null) {
                            print('we are here');
                            await Provider.of<ConversationProvider>(context,
                                    listen: false)
                                .createConversation(
                              context,
                              widget.user.id,
                              message,
                            )
                                .then((conv) {
                              setState(() {
                                ConversationProvider _convProvider =
                                    Provider.of<ConversationProvider>(context,
                                        listen: false);
                                conversation.id = _convProvider.concersations
                                    .firstWhere((c) => c.id == conv.id)
                                    .id;
                                conversation.messages = _convProvider
                                    .concersations
                                    .firstWhere((c) => c.id == conv.id)
                                    .messages;
                                // conversation.id = conv.id;
                                // message.conversationId = conv.id;
                                // conversation.messages = conv.messages;
                              });
                            });
                            // await Provider.of<ConversationProvider>(context,
                            //         listen: false)
                            //     .resetConversations();
                          } else {
                            print(
                                'conversationId already set: ${conversation.id}');
                            print("Message From chat:"+message.toJson().toString());
                            message.conversationId = conversation.id;
                            await Provider.of<ConversationProvider>(context,
                                    listen: false)
                                .storeMessage(context, message);
                          }
                          messageTextEditController.clear();
                          _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent + 23);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Colors.black),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
