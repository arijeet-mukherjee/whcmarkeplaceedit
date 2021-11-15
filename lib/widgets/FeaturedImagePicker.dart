import 'dart:io';

import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:answer_me/config/SizeConfig.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:provider/provider.dart';

class FeaturedImagePicker extends StatelessWidget {
  final bool askAuthor;
  final File featuredImage;
  final Function getImage;
  final bool hasPadding;
  final Function removeImageFile;
  final String networkedFeaturedImage;
  final Function removeFeaturedImage;

  const FeaturedImagePicker({
    Key key,
    this.askAuthor = false,
    this.featuredImage,
    this.getImage,
    this.hasPadding = true,
    this.removeImageFile,
    this.networkedFeaturedImage,
    this.removeFeaturedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!askAuthor)
      return Container(
        width: double.infinity,
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.only(
          top: hasPadding ? SizeConfig.blockSizeHorizontal * 1.8 : 0,
        ),
        padding: hasPadding
            ? EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 6,
              )
            : EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: getImage,
                  child: Icon(
                    EvaIcons.image,
                    size: SizeConfig.blockSizeHorizontal * 8,
                  ),
                ),
                featuredImage == null
                    ? Container()
                    : InkWell(
                        onTap: () => removeImageFile(),
                        child: Icon(
                          EvaIcons.close,
                          size: SizeConfig.blockSizeHorizontal * 8,
                        ),
                      ),
              ],
            ),
            SizedBox(height: SizeConfig.blockSizeVertical * 2),
            networkedFeaturedImage != null
                ? _imagePickerWithoutBody(
                    context,
                    body: Image.network(
                      '${ApiRepository.FEATURED_IMAGES_PATH}$networkedFeaturedImage',
                      width: double.infinity,
                      fit: BoxFit.fill,
                    ),
                  )
                : featuredImage == null
                    ? Container()
                    : _imagePickerWithoutBody(
                        context,
                        body: Image.file(
                          featuredImage,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                      ),
          ],
        ),
      );
    else
      return Container();
  }

  _imagePickerWithoutBody(BuildContext context, {Widget body}) {
    ThemeProvider _theme = Provider.of<ThemeProvider>(context, listen: false);
    return Stack(
      children: [
        DottedBorder(
          color: _theme.isDarkTheme() ? Colors.white70 : Colors.black54,
          strokeWidth: 1,
          child: Container(
            width: double.infinity,
            height: SizeConfig.blockSizeHorizontal * 55,
            child: body,
          ),
        ),
        networkedFeaturedImage != null
            ? Align(
                alignment: Alignment.bottomLeft,
                child: GestureDetector(
                  onTap: () => removeFeaturedImage(),
                  child: CircleAvatar(
                    maxRadius: SizeConfig.blockSizeHorizontal * 2.5,
                    child: Center(
                      child: Icon(
                        Icons.remove,
                        size: SizeConfig.blockSizeHorizontal * 4.2,
                      ),
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }
}
