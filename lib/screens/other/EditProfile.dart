import 'dart:io';

import 'package:answer_me/providers/AppProvider.dart';
import 'package:answer_me/widgets/AppBarLeadingButton.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:answer_me/models/User.dart';
import 'package:provider/provider.dart';
import 'package:answer_me/providers/AuthProvider.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/screens/other/UserProfile.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:answer_me/utils/utils.dart';
import 'package:answer_me/widgets/CustomTextField.dart';
import 'package:answer_me/widgets/DefaultButton.dart';
import 'package:flutter/material.dart';

enum ImageType { avatar, cover }

class EditProfileScreen extends StatefulWidget {
  static const routeName = "edit_profile_screen";

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfController = TextEditingController();
  AuthProvider _authProvider;
  User _user = User();
  File _avatar;
  File _cover;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _getUserInfo();
  }

  _getUserInfo() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _user = _authProvider.user;
    setState(() {
      _displayNameController.text = _user.displayname;
      _emailController.text = _user.email;
      _bioController.text = _user.description;
    });
  }

  _updateProfile() async {
    String password = _passwordController.text;
    String passwordConf = _passwordConfController.text;

    if (password.isNotEmpty && passwordConf.isNotEmpty) {
      if (password != passwordConf) {
        Toast.show(
          'Password and Confirm Password doesn\'t match',
          context,
          duration: 2,
        );
        return;
      }
    }

    showLoadingDialog(context, 'Updating Profile...');

    String _avatarName;
    String _coverName;

    if (_avatar != null) {
      _avatarName = _avatar.path.split('/').last;
    } else if (_cover != null) {
      _coverName = _cover.path.split('/').last;
    }

    await ApiRepository.updateProfile(
      context,
      userId: _user.id,
      cover: _cover,
      covername: _coverName,
      avatar: _avatar,
      avatarname: _avatarName,
      displayname: _displayNameController.text,
      email: _emailController.text,
      bio: _bioController.text,
      password: _passwordController.text,
    ).then((value) async {
      await _authProvider.getUserInfo(context, _user.id).then((user) {
        AppProvider _appProvider =
            Provider.of<AppProvider>(context, listen: false);
        _appProvider.clearAllQuestions();
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (ctx) => UserProfile(authorId: _user.id),
          ),
        );
      });
    });
  }

  Future getImage(ImageType type) async {
    final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        if (type == ImageType.avatar)
          _avatar = File(pickedFile.path);
        else
          _cover = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      body: _body(context),
    );
  }

  _body(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildCoverAndAvatarImages(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _buildCoverAndAvatarImages(BuildContext context) {
    return Stack(
      children: [
        _buildCoverImage(),
        Padding(
          padding: EdgeInsets.only(
            top: SizeConfig.blockSizeVertical * 6,
            left: SizeConfig.blockSizeHorizontal,
          ),
          child: Column(
            children: [
              _buildBackButton(context),
              _buildCoverImagePicker(),
              SizedBox(height: SizeConfig.blockSizeVertical * 6),
              _buildAvatarImagePicker(),
              _buildInputFields(context),
            ],
          ),
        ),
      ],
    );
  }

  _buildCoverImage() {
    return Stack(
      children: [
        _cover == null
            ? _user.cover == null
                ? Image.asset(
                    'assets/images/cover_image.png',
                    width: double.infinity,
                    height: SizeConfig.blockSizeVertical * 30,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    '${ApiRepository.COVER_IMAGES_PATH}${_user.cover}',
                    width: double.infinity,
                    height: SizeConfig.blockSizeVertical * 30,
                    fit: BoxFit.fill,
                  )
            : Image.file(
                _cover,
                width: double.infinity,
                height: SizeConfig.blockSizeVertical * 30,
                fit: BoxFit.fill,
              ),
        Container(
          height: SizeConfig.blockSizeVertical * 30,
          color: Colors.black.withOpacity(0.4),
        ),
      ],
    );
  }

  _buildCoverImagePicker() {
    return Center(
      child: CircleAvatar(
        maxRadius: SizeConfig.blockSizeHorizontal * 8,
        backgroundColor: Colors.black54,
        child: _buildCameraButton(onTap: () => getImage(ImageType.cover)),
      ),
    );
  }

  _buildAvatarImagePicker() {
    return Center(
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal),
          child: CircleAvatar(
            maxRadius: SizeConfig.blockSizeHorizontal * 11.5,
            backgroundColor: Colors.black54,
            child: Container(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Stack(
                children: [
                  _avatar == null
                      ? _user.avatar == null
                          ? Image.asset('assets/images/user_icon.png')
                          : Image.network(
                              _user.avatar,
                              width: double.infinity,
                              height: SizeConfig.blockSizeVertical * 30,
                              fit: BoxFit.cover,
                            )
                      : Image.file(
                          _avatar,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                  Container(color: Colors.black.withOpacity(0.6)),
                  Center(
                    child: _buildCameraButton(
                      onTap: () => getImage(ImageType.avatar),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildBackButton(BuildContext context) {
    return Row(
      children: [
        AppBarLeadingButton(color: Colors.white),
      ],
    );
  }

  _buildCameraButton({Function onTap}) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.camera_alt_outlined,
        color: Colors.white,
        size: SizeConfig.blockSizeHorizontal * 7.5,
      ),
    );
  }

  _buildInputFields(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.blockSizeVertical * 3,
        horizontal: SizeConfig.blockSizeHorizontal * 5,
      ),
      child: Column(
        children: [
          _buildDisplayNameField(),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildEmailField(),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildBioField(),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildInformationText(context),
          SizedBox(height: SizeConfig.blockSizeVertical * 2),
          _buildPasswordFields(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
          _buildUpdateButton(),
          SizedBox(height: SizeConfig.blockSizeVertical * 3),
        ],
      ),
    );
  }

  _buildDisplayNameField() {
    return CustomTextField(
      label: 'Display name',
      labelSize: SizeConfig.safeBlockHorizontal * 4.5,
      controller: _displayNameController,
    );
  }

  _buildEmailField() {
    return CustomTextField(
      label: 'Email',
      labelSize: SizeConfig.safeBlockHorizontal * 4.5,
      controller: _emailController,
    );
  }

  _buildBioField() {
    return CustomTextField(
      label: 'Bio',
      maxLines: 4,
      labelSize: SizeConfig.safeBlockHorizontal * 4.5,
      controller: _bioController,
    );
  }

  _buildInformationText(BuildContext context) {
    return Text(
      'If you want to change your password, type the next two passwords.',
      style: TextStyle(
        fontSize: SizeConfig.safeBlockHorizontal * 3.5,
      ),
    );
  }

  _buildPasswordFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          obscure: true,
          label: 'Password',
          labelSize: SizeConfig.safeBlockHorizontal * 4.5,
          controller: _passwordController,
        ),
        SizedBox(height: SizeConfig.blockSizeVertical * 3),
        CustomTextField(
          obscure: true,
          label: 'Confirm Password',
          labelSize: SizeConfig.safeBlockHorizontal * 4.5,
          controller: _passwordConfController,
        ),
      ],
    );
  }

  _buildUpdateButton() {
    return DefaultButton(
      onPressed: () => _updateProfile(),
      text: 'Update',
      hasPadding: false,
    );
  }
}
