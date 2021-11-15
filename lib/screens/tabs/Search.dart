import 'package:answer_me/config/AppConfig.dart';
import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:answer_me/widgets/CategoriesWrap.dart';
import 'package:answer_me/widgets/LoadingShimmerLayout.dart';
import 'package:answer_me/widgets/TagsWrap.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/models/question.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/QuestionListItem.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = 'search_screen';

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  AuthProvider _authProvider;
  TextEditingController _searchController = TextEditingController();
  List<Question> _questions = [];
  bool _doneSearching = false;
  bool _startedSearching = false;

  _searchQuestions(String value) async {
    if (value.isEmpty) return;
    setState(() {
      _startedSearching = true;
    });
    await ApiRepository.searchQuestions(
      context,
      userId: _authProvider.user != null ? _authProvider.user.id : 0,
      title: value,
    ).then((questions) {
      setState(() {
        _questions = questions;
      });
    });
    setState(() {
      _startedSearching = false;
      _doneSearching = true;
    });
  }

  _searchByCategory(String value) async {
    setState(() {
      _searchController.text = value;
      _startedSearching = true;
    });
    await ApiRepository.searchQuestionsByCategory(
      context,
      userId: _authProvider.user != null ? _authProvider.user.id : 0,
      title: value,
    ).then((questions) {
      setState(() {
        _questions = questions;
      });
    });
    setState(() {
      _startedSearching = false;
      _doneSearching = true;
    });
  }

  _searchByTag(String value) async {
    setState(() {
      _searchController.text = value;
      _startedSearching = true;
    });
    await ApiRepository.searchQuestionsByTag(
      context,
      userId: _authProvider.user != null ? _authProvider.user.id : 0,
      title: value,
    ).then((questions) {
      setState(() {
        _questions = questions;
      });
    });
    setState(() {
      _startedSearching = false;
      _doneSearching = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _searchController.addListener(() => _checkIfEmpty());
  }

  _checkIfEmpty() {
    if (_searchController.text.isEmpty) {
      _startedSearching = false;
      _doneSearching = false;
      setState(() {
        _questions = [];
      });
    }
  }

  _clearTextField() {
    _startedSearching = false;
    _doneSearching = false;
    _searchController.text = '';
    setState(() {
      _questions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(context),
    );
  }

  _appBar() {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text('Search', style: theme.isDarkTheme()?Theme.of(context).textTheme.headline6:TextStyle(
              fontFamily: 'Equinox',
              fontSize: SizeConfig.safeBlockHorizontal * 4.8,
              color: Colors.white,
            )),
      backgroundColor: theme.isDarkTheme()?ThemeData.dark().scaffoldBackgroundColor:kPrimaryColor,
    );
  }

  _body(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: SizeConfig.blockSizeHorizontal * 6,
            right: SizeConfig.blockSizeHorizontal * 6,
            top: SizeConfig.blockSizeVertical * 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: CustomTextField(
                  hint: 'Type to search',
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) =>
                      _searchQuestions(_searchController.text),
                ),
              ),
              SizedBox(width: SizeConfig.blockSizeHorizontal * 2),
              InkWell(
                onTap: () => !_doneSearching
                    ? _searchQuestions(_searchController.text)
                    : _clearTextField(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal * 2,
                    vertical: SizeConfig.blockSizeVertical * 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: theme.isDarkTheme()
                        ? Colors.black54
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(
                      SizeConfig.blockSizeHorizontal * 2,
                    ),
                  ),
                  child: Center(
                      child: Icon(
                    !_doneSearching
                        ? FluentIcons.search_16_regular
                        : FluentIcons.dismiss_16_regular,
                    size: SizeConfig.blockSizeHorizontal * 6.5,
                  )),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: SizeConfig.blockSizeVertical),
        Divider(thickness: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: Container(
            color: Theme.of(context).cardColor,
            child: !_startedSearching
                ? _questions.isNotEmpty
                    ? ListView.builder(
                        itemCount: _questions.length,
                        shrinkWrap: true,
                        itemBuilder: (context, i) => QuestionListItem(
                          question: _questions[i],
                        ),
                      )
                    : _suggestionScreen()
                : LoadingShimmerLayout(),
          ),
        ),
      ],
    );
  }

  _suggestionScreen() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 6,
          vertical: SizeConfig.blockSizeVertical,
        ),
        color: Theme.of(context).cardColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            !_doneSearching && _questions.isEmpty
                ? Container()
                : Center(
                    child: Column(
                      children: [
                        SizedBox(height: SizeConfig.blockSizeVertical * 2),
                        Text('No Questions Found'),
                        SizedBox(height: SizeConfig.blockSizeVertical * 2),
                      ],
                    ),
                  ),
            _buildWrapTitle('Tags'),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            Consumer<AppProvider>(
              builder: (context, app, _) => TagsWrap(
                questionTags: app.tags,
                onTap: _searchByTag,
              ),
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            _buildWrapTitle('Interests'),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            Consumer<AppProvider>(
              builder: (context, app, _) => CategoriesWrap(
                categories: app.categories,
                onTap: _searchByCategory,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildWrapTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lato(
        fontSize: SizeConfig.safeBlockHorizontal * 5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
