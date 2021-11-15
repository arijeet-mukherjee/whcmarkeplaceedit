import 'dart:io';
import 'dart:math';

import 'package:answer_me/models/Comment.dart';
import 'package:answer_me/models/Conversation.dart';
import 'package:answer_me/models/Message.dart';
import 'package:answer_me/models/User.dart';
import 'package:answer_me/providers/ConversationProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/screens/Tabs.dart';
import 'package:answer_me/screens/other/QuestionDetail.dart';
import 'package:answer_me/screens/tabs/HomeScreen.dart';
import 'package:answer_me/widgets/ExpandableText.dart';
import 'package:answer_me/widgets/TagsTextField.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:answer_me/models/Option.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/screens/other/QuestionPosted.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/DynamicQuestionImageField.dart';
import 'package:answer_me/widgets/DynamicQuestionField.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:http/http.dart' as http;

import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/FeaturedImagePicker.dart';

import 'ChatScreen.dart';
import 'ConversationScreen.dart';

class AskQuestionScreen extends StatefulWidget {
  final bool askAuthor;
  final bool answer;
  final bool reply;
  final bool edit;
  final int authorId;
  final int questionId;
  final int answerId;
  final Function getQuestion;

  const AskQuestionScreen(
      {Key key,
      this.askAuthor = false,
      this.answer = false,
      this.reply = false,
      this.edit = false,
      this.getQuestion,
      this.authorId,
      this.answerId,
      this.questionId})
      : super(key: key);

  @override
  _AskQuestionScreenState createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _detailsController = TextEditingController();
  TextEditingController _videoURLController = TextEditingController();
  TextEditingController _answerController = TextEditingController();

  ThemeProvider _themeProvider;
  AuthProvider _authProvider;
  AppProvider _appProvider;

  List<DynamicQuestionField> _listOfQuestions = [];
  List<DynamicImageQuestionField> _listOfImageQuestions = [];
  List<String> _selectedTags = [];
  // List<String> _options = [];
  List<AskOption> _options = [];
  List<AskOption> _imageOptions = [];
  int _selectedCategoryId;

  bool _isLoading = false;
  bool isPoll = false;
  bool isImagePoll = false;
  bool showVideoUrl = false;
  bool isAnonymous = false;
  bool isPrivate = false;
  bool getNotification = false;
  bool agreeOnTerms = false;

  Question _question;
  List<ChoiceCategory> categories = [];
  File _featuredImage;
  String _networkFeaturedImage;
  User _author;

  final picker = ImagePicker();
  ScrollController _scrollController = new ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();
    if (widget.answer) {
      setState(() {
        _isLoading = false;
      });
    }

    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appProvider = Provider.of<AppProvider>(context, listen: false);

    _populateCategories().then((value) async {
      if (widget.questionId != null && widget.edit) await _getQuestion();
      setState(() {
        _isLoading = false;
      });
    });

    _addDynamicQuestion();
    _addDynamicQuestion();
    _addDynamicImageQuestion();
    _addDynamicImageQuestion();
    _getUserInfo();
  }

  _getUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    await ApiRepository.getUserInfo(context, userId: widget.authorId)
        .then((author) {
      setState(() {
        _author = author;
      });
    });
  }

  Future _getQuestion() async {
    await ApiRepository.getQuestion(
      context,
      widget.questionId,
      _authProvider.user != null ? _authProvider.user.id : 0,
    ).then((question) {
      setState(() {
        _question = question;
      });
      if (mounted) _titleController.text = question.title;
      if (categories.isNotEmpty)
        categories.where((c) => c.id == question.categoryId).first.selected =
            true;
      _detailsController.text = question.content;
      if (question.polled == 1) isPoll = true;
      if (question.imagePolled == 1) isImagePoll = true;
      if (question.videoURL != null) {
        showVideoUrl = true;
        _videoURLController.text = question.videoURL;
      }
      _selectedCategoryId = question.categoryId;
      isAnonymous = question.anonymous == 1 ? true : false;
      if (question.featuredImage != null)
        _networkFeaturedImage = question.featuredImage;
      _question.tags.forEach((tag) {
        _selectedTags.add(tag.tag);
      });
      if (question.options.isNotEmpty) {
        _listOfQuestions = [];
        _listOfImageQuestions = [];
        question.options.forEach((o) {
          _addDynamicQuestion(o: o);
          _addDynamicImageQuestion(o: o);
        });
      }
    });
  }

  _addDynamicQuestion({Option o}) {
    _listOfQuestions.add(new DynamicQuestionField(
      index: _listOfQuestions.length,
      label: 'Add Answer #${_listOfQuestions.length + 1}',
      remove: _removeDynamicQuestion,
      option: o,
    ));
    setState(() {});
  }

  _removeDynamicQuestion(index) {
    setState(() {
      _listOfQuestions.removeWhere((q) => q.index == index);
    });
  }

  _getDynamicQuestions() {
    _options.clear();
    _listOfQuestions.forEach((question) {
      _options.add(
        AskOption(
          option: question.inputController.text,
          id: question.option != null ? question.option.id.toString() : null,
        ),
      );
    });
  }

  _addDynamicImageQuestion({Option o}) {
    _listOfImageQuestions.add(new DynamicImageQuestionField(
      index: _listOfImageQuestions.length,
      label: 'Add Answer #${_listOfImageQuestions.length + 1}',
      remove: _removeDynamicImageQuestion,
      image: _imageOptions.isNotEmpty
          ? _imageOptions[_listOfImageQuestions.length].image
          : null,
      option: o,
    ));
    setState(() {});
  }

  _removeDynamicImageQuestion(index) {
    setState(() {
      _listOfImageQuestions.removeAt(index);
    });
  }

  Future _getDynamicImageQuestions() async {
    _options.clear();
    File image;
    _listOfImageQuestions.forEach((question) async {
      if (question.controller.text.isNotEmpty &&
          question.controller.text != null &&
          question.controller.text != '') {
        if (question.optionImageString != null) {
          image = await urlToFile(
              '${ApiRepository.OPTION_IMAGES_PATH}${question.optionImageString}');
          setState(() {
            _options.add(
              AskOption(
                option: question.controller.text,
                id: question.idController.text.isNotEmpty
                    ? question.idController.text.toString()
                    : null,
                image: image,
              ),
            );
          });
        } else {
          setState(() {
            _options.add(
              AskOption(
                option: question.controller.text,
                id: question.idController.text.isNotEmpty
                    ? question.idController.text.toString()
                    : null,
                image:
                    question.optionimage != null ? question.optionimage : null,
              ),
            );
          });
        }
      }
    });
  }

  Future<File> urlToFile(String imageUrl) async {
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future _populateCategories() async {
    setState(() {
      _isLoading = true;
    });
    if (_appProvider.categories != null) await _appProvider.getCategories();
    _appProvider.categories.forEach((category) {
      setState(() {
        categories.add(ChoiceCategory(id: category.id, name: category.name));
      });
    });
  }

  //Add String caps

  _addQuestion() async {
    if (_formKey.currentState.validate()) {
      showLoadingDialog(context, 'Asking Question...');

      String title1 = _titleController.text;
      String title = title1[0].toUpperCase() + title1.substring(1);
      String details1 = _detailsController.text;
      String details = details1[0].toUpperCase() + details1.substring(1);
      String videoURL = _videoURLController.text;

      if (widget.askAuthor) {
        Question _question = new Question();
        _question.authorId = _authProvider.user.id;
        _question.anonymous = isAnonymous ? 1 : 0;
        _question.title = title;
        _question.content = details;
        _question.createdAt = DateTime.now().toString();
        _question.videoURL = '';
        _question.asking = widget.authorId;

        await ApiRepository.addQuestion(
          context,
          question: _question,
          options: [],
        ).then((value) {
          Navigator.pop(context);
          Navigator.pop(context);
          Toast.show('Question sent successfully!', context);
        });
      } else {
        if (_selectedCategoryId == null) {
          Toast.show('Please check one category', context);
          Navigator.pop(context);
          return;
        }

        if (isPoll) {
          if (isImagePoll)
            await _getDynamicImageQuestions();
          else
            _getDynamicQuestions();
        }

        String _imageName;
        if (_featuredImage != null)
          _imageName = _featuredImage.path.split('/').last;

        Question _question = new Question();
        _question.authorId = _authProvider.user.id;
        _question.anonymous = isAnonymous ? 1 : 0;
        _question.title = title;
        _question.content = details;
        _question.categoryId = _selectedCategoryId;
        _question.polled = isPoll ? 1 : 0;
        _question.pollTitle = title;
        _question.imagePolled = isImagePoll ? 1 : 0;
        _question.createdAt = DateTime.now().toString();
        _question.videoURL = videoURL;

        if (_usernameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty) {
          _question.username = _usernameController.text;
          _question.email = _usernameController.text;
        }
        await ApiRepository.addQuestion(
          context,
          question: _question,
          tags: _selectedTags,
          options: _options,
          featuredImage: _featuredImage,
          featuredImageName: _imageName,
        ).then((value) {
          _appProvider.clearAllQuestions();
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => QuestionPostedScreen(type: SubmitType.store),
            ),
          );
        });
      }
    }
  }

  _updateQuestion() async {
    if (_formKey.currentState.validate()) {
      showLoadingDialog(context, 'Updating Question...');

      String title = _titleController.text;
      String details = _detailsController.text;
      String videoURL = _videoURLController.text;

      if (widget.askAuthor) {
        Question _question = new Question();
        _question.id = widget.questionId;
        _question.authorId = _authProvider.user.id;
        _question.anonymous = isAnonymous ? 1 : 0;
        _question.title = title;
        _question.content = details;
        // _question.createdAt = DateTime.now().toString();
        _question.updatedAt = DateTime.now().toString();
        _question.videoURL = '';
        _question.asking = widget.authorId;

        await ApiRepository.updateQuestion(
          context,
          question: _question,
          options: [],
        ).then((value) => Navigator.pop(context));
      } else {
        if (_selectedCategoryId == null) {
          Toast.show('Please check one category', context);
          Navigator.pop(context);
          return;
        }

        if (isPoll) {
          if (isImagePoll)
            await _getDynamicImageQuestions();
          else
            _getDynamicQuestions();
        }

        String _imageName;
        if (_featuredImage != null)
          _imageName = _featuredImage.path.split('/').last;

        Question _question = new Question();
        _question.id = widget.questionId;
        _question.authorId = _authProvider.user.id;
        _question.anonymous = isAnonymous ? 1 : 0;
        _question.title = title;
        _question.content = details;
        _question.categoryId = _selectedCategoryId;
        _question.polled = isPoll ? 1 : 0;
        _question.pollTitle = title;
        _question.imagePolled = isImagePoll ? 1 : 0;
        _question.updatedAt = DateTime.now().toString();
        _question.videoURL = videoURL;

        if (_usernameController.text.isNotEmpty &&
            _emailController.text.isNotEmpty) {
          _question.username = _usernameController.text;
          _question.email = _usernameController.text;
        }

        await ApiRepository.updateQuestion(
          context,
          question: _question,
          tags: _selectedTags,
          options: _options,
          featuredImage: _featuredImage,
          featuredImageName: _imageName,
        ).then((value) {
          _appProvider.clearAllQuestions();
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (ctx) => QuestionPostedScreen(
                type: SubmitType.update,
                questionId: _question.id,
              ),
            ),
          );
        });
      }
    }
  }

  Future getImage() async {
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _featuredImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  _removeFeaturedImageFile() {
    setState(() {
      _featuredImage = null;
    });
  }

  _removeFeaturedImage() async {
    await ApiRepository.removeFeaturedImage(
      context,
      questionId: widget.questionId,
    ).then((value) {
      setState(() {
        _networkFeaturedImage = null;
      });
    });
  }

  _sendReply() async {
    if (_formKey.currentState.validate()) {
      //AuthProvider _auth = Provider.of<AuthProvider>(context, listen: false);
      if (_authProvider.user.id == widget.authorId) {
        //_openChatScreen(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("You cant reply your question!"),
        ));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => TabsScreen()),
        );
      } else {
        _openChatScreen(context);
        showLoadingDialog(context, 'Posting reply...');

        String answer = _answerController.text;

        Comment _comment = new Comment();
        _comment.authorId = _authProvider.user.id;
        _comment.anonymous = isAnonymous ? 1 : 0;
        _comment.answerId = widget.answerId;
        _comment.questionId = widget.questionId;
        _comment.content = answer;
        _comment.type = widget.reply ? 'Reply' : 'Answer';

        await ApiRepository.addComment(
          context,
          _comment,
        ).then((value) => Navigator.pop(context));
        await widget.getQuestion();

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (ctx) => ConversationsScreen()),
        );
      }
    }
  }

  _sendMessage() {
    Message message = Message();
  }

  _openChatScreen(BuildContext context) async {
    AuthProvider _auth = Provider.of<AuthProvider>(context, listen: false);
    _getQuestion();
    ConversationProvider _convProvider =
        Provider.of<ConversationProvider>(context, listen: false);
    if (_convProvider.concersations.isNotEmpty) {
      _convProvider.concersations.forEach((conv) {
        print(conv.toJson());
      });

      print("Author Id :" + widget.authorId.toString());
      if (_convProvider.concersations.any((conv) =>
          conv.secondUserId == widget.authorId ||
          (conv.secondUserId == _authProvider.user.id &&
              conv.user.id == widget.authorId))) {
        //print("Hello we are connected!");
        Conversation exist = _convProvider.concersations.firstWhere((conv) =>
            conv.secondUserId == widget.authorId ||
            (conv.secondUserId == _authProvider.user.id &&
                conv.user.id == widget.authorId));
        if (exist.id != null) {
          Conversation conversation = new Conversation(
            user: _author,
            secondUserId: _author.id,
            createdAt: exist.createdAt,
            messages: exist.messages,
            id: exist.id,
          );

          Message message = new Message();
          message.conversationId = conversation.id;
          message.userId = _auth.user.id;
          String c = ':';

          String body = 'Q. ' +
              ' ' +
              _question.content +
              '\n' +
              '\n' +
              'Ans. ' +
              ' ' +
              _answerController.text;
          message.body = body;
          print("Time of conv : " + conversation.createdAt.toString());
          print("Message From Ask :" + message.toJson().toString());
          await Provider.of<ConversationProvider>(context, listen: false)
              .storeMessage(context, message);
        }
      } else {
        Message message = new Message();
        Conversation conversation = new Conversation();
        String body = 'Q. ' +
            ' ' +
            _question.content +
            '\n' +
            '\n' +
            'Ans. ' +
            ' ' +
            _answerController.text;
        //message.conversationId = conversation.id;
        message.userId = _auth.user.id;
        message.body = body;
        if (conversation.id == null) {
          await Provider.of<ConversationProvider>(context, listen: false)
              .createConversation(
            context,
            widget.authorId,
            message,
          )
              .then((conv) {
            setState(() {
              ConversationProvider _convProvider =
                  Provider.of<ConversationProvider>(context, listen: false);
              conversation.id = _convProvider.concersations
                  .firstWhere((c) => c.id == conv.id)
                  .id;
              conversation.messages = _convProvider.concersations
                  .firstWhere((c) => c.id == conv.id)
                  .messages;
              // conversation.id = conv.id;
              // message.conversationId = conv.id;
              // conversation.messages = conv.messages;
            });
          });
          Conversation exist = _convProvider.concersations.firstWhere((conv) =>
              conv.secondUserId == widget.authorId ||
              (conv.secondUserId == _authProvider.user.id &&
                  conv.user.id == widget.authorId));
          if (exist.id != null) {
            Conversation conversation = new Conversation(
              user: _author,
              secondUserId: _author.id,
              createdAt: exist.createdAt,
              messages: exist.messages,
              id: exist.id,
            );
            Message message = new Message();
            message.conversationId = conversation.id;
            message.userId = _auth.user.id;
            message.body = _answerController.text;
            print("Time of conv : " + conversation.createdAt.toString());
            print("Message From Ask :" + message.toJson().toString());
            await Provider.of<ConversationProvider>(context, listen: false)
                .storeMessage(context, message);
          }
        }
      }
    } else {
      Message message = new Message();
      Conversation conversation = new Conversation();
      //message.conversationId = conversation.id;
      message.userId = _auth.user.id;
      message.body = _answerController.text;
      if (conversation.id == null) {
        await Provider.of<ConversationProvider>(context, listen: false)
            .createConversation(
          context,
          widget.authorId,
          message,
        )
            .then((conv) {
          setState(() {
            ConversationProvider _convProvider =
                Provider.of<ConversationProvider>(context, listen: false);
            conversation.id = _convProvider.concersations
                .firstWhere((c) => c.id == conv.id)
                .id;
            conversation.messages = _convProvider.concersations
                .firstWhere((c) => c.id == conv.id)
                .messages;
            // conversation.id = conv.id;
            // message.conversationId = conv.id;
            // conversation.messages = conv.messages;
          });
        });
        Conversation exist = _convProvider.concersations.firstWhere((conv) =>
            conv.secondUserId == widget.authorId ||
            (conv.secondUserId == _authProvider.user.id &&
                conv.user.id == widget.authorId));
        if (exist.id != null) {
          Conversation conversation = new Conversation(
            user: _author,
            secondUserId: _author.id,
            createdAt: exist.createdAt,
            messages: exist.messages,
            id: exist.id,
          );
          Message message = new Message();
          message.conversationId = conversation.id;
          message.userId = _auth.user.id;
          message.body = _answerController.text;
          print("Time of conv : " + conversation.createdAt.toString());
          print("Message From Ask :" + message.toJson().toString());
          await Provider.of<ConversationProvider>(context, listen: false)
              .storeMessage(context, message);
        }
      }
    }
  }

  _buildQuestionTitle(BuildContext context) {
    _getQuestion();
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockSizeHorizontal * 6,
      ),
      child: GestureDetector(
        // onTap: () => _navigateToQuestionDetail(context),
        child: Text(
          _question.title,
          style: TextStyle(
            fontSize: SizeConfig.safeBlockHorizontal * 4.8,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  _buildDescription(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    _getQuestion();
    if (_question.content.isNotEmpty)
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.blockSizeVertical,
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: GestureDetector(
          child: ExpandableText(
            _question.content,
            trimLines: 5,
            style: TextStyle(
              fontSize: SizeConfig.safeBlockHorizontal * 4.1,
              fontWeight: FontWeight.w600,
              color: theme.isDarkTheme()
                  ? Colors.white.withOpacity(0.8)
                  : Colors.black87,
              height: 1.2,
            ),
          ),
        ),
      );
    else
      return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  _appBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: AppBarLeadingButton(),
      title: Text(
        widget.questionId != null
            ? widget.edit
                ? 'Edit Question'
                : 'Reply'
            : 'Ask Question',
        style: Theme.of(context).textTheme.headline6,
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          onPressed: () => widget.questionId != null
              ? widget.edit
                  ? _updateQuestion()
                  : _sendReply()
              : _addQuestion(),
          child: Text(
            widget.questionId != null
                ? widget.edit
                    ? 'Update'
                    : 'Send'
                : widget.askAuthor
                    ? 'Send'
                    : 'Post',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  _body(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            controller: _scrollController,
            child: Builder(
              builder: (context) {
                if (widget.answer) {
                  return Column(
                    children: [
                      // _buildQuestionTitle(context),

                      Container(
                        width: double.infinity,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(height: SizeConfig.blockSizeVertical),
                              _buildDescription(context),
                              _buildInformationContainer(
                                title: '',
                                body: Column(
                                  children: [
                                    CustomTextField(
                                      hint: 'What do you think?',
                                      maxLines: 8,
                                      controller: _answerController,
                                    ),
                                  ],
                                ),
                              ),
                              /* CheckboxListTile(
                                autofocus: false,
                                checkColor: Colors.white,
                                activeColor: Theme.of(context).primaryColor,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                  'Anonymously',
                                  style: TextStyle(
                                    fontSize:
                                        SizeConfig.safeBlockHorizontal * 3.5,
                                  ),
                                ),
                                value: isAnonymous,
                                onChanged: (value) {
                                  setState(() {
                                    isAnonymous = value;
                                  });
                                },
                              ), */
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  height: SizeConfig.blockSizeVertical * 3),
                              _buildInformationContainer(
                                title: 'Categories',
                                askAuthor: widget.askAuthor,
                                body: Column(
                                  children: [
                                    SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical * 1.5),
                                    _buildCategoryList(),
                                  ],
                                ),
                              ),
                              _buildInformationContainer(
                                title: 'Title',
                                body: Column(
                                  children: [
                                    CustomTextField(
                                      hint:
                                          'Start your question with "What", "How", "Why", etc.',
                                      controller: _titleController,
                                    ),
                                    SizedBox(
                                        height:
                                            SizeConfig.blockSizeVertical * 1.5),
                                  ],
                                ),
                              ),
                              _buildInformationContainer(
                                title: 'Details',
                                body: Column(
                                  children: [
                                    CustomTextField(
                                      hint:
                                          'Describe briefly your question ...',
                                      maxLines: 6,
                                      controller: _detailsController,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: SizeConfig.blockSizeVertical),
                            ],
                          ),
                        ),
                      ),
                      /* _buildInformationContainer(
                        title: 'Video URL (optional)',
                        body: Column(
                          children: [
                            CustomTextField(
                              controller: _videoURLController,
                              hint: 'Video URL',
                            ),
                          ],
                        ),
                      ), */
                      SizedBox(height: SizeConfig.blockSizeVertical),
                      /* _buildInformationContainer(
                        title: 'Tags (optional)',
                        askAuthor: widget.askAuthor,
                        body: Column(
                          children: [
                            SizedBox(
                                height: SizeConfig.blockSizeVertical * 1.5),
                            _buildTagsTextField(context),
                          ],
                        ),
                      ), */
                      _buildPollContainer(askAuthor: widget.askAuthor),
                      /* FeaturedImagePicker(
                        askAuthor: widget.askAuthor,
                        getImage: getImage,
                        removeImageFile: _removeFeaturedImageFile,
                        featuredImage: _featuredImage,
                        networkedFeaturedImage: _networkFeaturedImage,
                        removeFeaturedImage: _removeFeaturedImage,
                      ), */
                      SizedBox(height: SizeConfig.blockSizeVertical * 3),
                    ],
                  );
                }
              },
            ),
          );
  }

  _buildInformationContainer({
    String title,
    bool askAuthor = false,
    Widget body,
    String description,
  }) {
    if (!askAuthor)
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: SizeConfig.safeBlockHorizontal * 4.2,
                fontWeight: FontWeight.w400,
                color: _themeProvider.isDarkTheme()
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            body,
            description != null
                ? Text(
                    description,
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                      color: Colors.black54,
                    ),
                  )
                : Container(),
            SizedBox(height: SizeConfig.blockSizeVertical),
          ],
        ),
      );
    else
      return Container();
  }

  _buildCategoryList() {
    ThemeProvider _theme = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      height: SizeConfig.blockSizeVertical * 4.5,
      child: ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, i) => Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 2,
          ),
          child: InkWell(
            onTap: () {
              categories.forEach((c) {
                c.selected = false;
              });
              setState(() {
                categories[i].selected = true;
                _selectedCategoryId = categories[i].id;
              });
            },
            child: Text(
              categories[i].name,
              style: TextStyle(
                color: categories[i].selected
                    ? Theme.of(context).primaryColor
                    : _theme.isDarkTheme()
                        ? Colors.white60
                        : Colors.black54,
                fontSize: SizeConfig.safeBlockHorizontal * 3.6,
                fontWeight: categories[i].selected
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildTagsTextField(BuildContext context) {
    return TagsTextField(
      initialTags: _selectedTags.isNotEmpty ? _selectedTags : [],
      tagsStyler: TagsStyler(
        tagTextPadding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal,
        ),
        tagTextStyle: TextStyle(
          color: Colors.white,
          fontSize: SizeConfig.safeBlockHorizontal * 3.5,
        ),
        tagDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(3.0),
        ),
        tagCancelIcon: Icon(
          Icons.cancel_outlined,
          size: SizeConfig.blockSizeHorizontal * 4,
          color: Colors.white,
        ),
        tagPadding: EdgeInsets.all(6.0),
      ),
      textFieldStyler: TextFieldStyler(
        cursorColor: Theme.of(context).primaryColor,
        contentPadding: EdgeInsets.symmetric(
          vertical: SizeConfig.blockSizeVertical * 1.5,
          horizontal: SizeConfig.blockSizeHorizontal * 2,
        ),
        hintText: 'Tags',
        textFieldBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            style: BorderStyle.solid,
          ),
        ),
        textFieldEnabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            style: BorderStyle.solid,
          ),
        ),
        textFieldFocusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            style: BorderStyle.solid,
          ),
        ),
        isDense: true,
      ),
      onTag: (tag) {
        if (tag.length <= 15) {
          _selectedTags.add(tag);
        }
      },
      onDelete: (tag) {
        setState(() {
          _selectedTags.remove(tag);
        });
      },
    );
  }

  _buildPollContainer({bool askAuthor}) {
    if (!askAuthor)
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* CheckboxListTile(
              autofocus: false,
              checkColor: Colors.white,
              activeColor: Theme.of(context).primaryColor,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'Ask Anonymously',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                ),
              ),
              value: isAnonymous,
              onChanged: (value) {
                setState(() {
                  isAnonymous = value;
                });
              },
            ), */
            /* CheckboxListTile(
              value: isPoll,
              autofocus: false,
              checkColor: Colors.white,
              activeColor: Theme.of(context).primaryColor,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                'This Question is a poll?',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                ),
              ),
              subtitle: Text(
                'If you want to be doing a poll click here.',
                style: TextStyle(
                  fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  isPoll = !isPoll;
                });
              },
            ),
            isPoll
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: SizeConfig.blockSizeVertical),
                      CheckboxListTile(
                        value: isImagePoll,
                        autofocus: false,
                        checkColor: Colors.white,
                        activeColor: Theme.of(context).primaryColor,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Image Poll?',
                          style: TextStyle(
                            fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            isImagePoll = !isImagePoll;
                          });
                        },
                      ),
                      isPoll
                          ? !isImagePoll
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _listOfQuestions.length,
                                  itemBuilder: (ctx, i) => _listOfQuestions[i],
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: _listOfImageQuestions.length,
                                  itemBuilder: (ctx, i) =>
                                      _listOfImageQuestions[i],
                                )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockSizeHorizontal * 6,
                          vertical: SizeConfig.blockSizeVertical * 2,
                        ),
                        child: GestureDetector(
                          onTap: () => !isImagePoll
                              ? _addDynamicQuestion()
                              : _addDynamicImageQuestion(),
                          child: Container(
                            padding: EdgeInsets.all(
                              SizeConfig.blockSizeHorizontal * 2,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey.shade200,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              'Add +',
                              style: TextStyle(
                                color: _themeProvider.isDarkTheme()
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(),
           */
          ],
        ),
      );
    else
      return Container();
  }
}

class ChoiceCategory {
  int id;
  String name;
  bool selected;

  ChoiceCategory({
    this.id,
    this.name,
    this.selected = false,
  });
}

class AskOption {
  String id;
  String option;
  File image;

  AskOption({this.id, this.option, this.image});

  Map<String, dynamic> toJson() => {
        'id': id,
        'option': option,
      };
}
