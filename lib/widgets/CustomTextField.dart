import 'package:answer_me/providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../config/SizeConfig.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final int maxLines;
  final Widget suffix;
  final double labelSize;
  final bool obscure;
  final TextEditingController controller;
  final Function onChanged;
  final FocusNode focusNode;
  final TextInputAction textInputAction;
  final Function onSubmitted;
  final String type;

  const CustomTextField({
    Key key,
    this.label = '',
    this.hint,
    this.suffix,
    this.controller,
    this.maxLines,
    this.labelSize,
    this.obscure = false,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.type,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showCursor = false;
  String type;
  @override
  void initState() {
    
    super.initState();
    if (widget.type != null) {
      type = widget.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider theme = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label != ''
              ? Text(
                  widget.label,
                  style: GoogleFonts.lato(
                    fontSize: SizeConfig.safeBlockHorizontal * 3.2,
                    color:
                        theme.isDarkTheme() ? Colors.white70 : Colors.black54,
                  ),
                )
              : Container(),
          SizedBox(height: SizeConfig.blockSizeVertical * 0.5),
          Focus(
            onFocusChange: (focus) => setState(() => _showCursor = focus),
            child: TextFormField(
              keyboardType:
                  type != null ? TextInputType.number : TextInputType.text,
              cursorColor: Theme.of(context).primaryColor,
              style: GoogleFonts.lato(),
              focusNode: widget.focusNode,
              obscureText: widget.obscure,
              showCursor: widget.focusNode != null
                  ? widget.focusNode.hasFocus
                  : _showCursor,
              controller: widget.controller,
              maxLines: widget.maxLines != null ? widget.maxLines : 1,
              onChanged: widget.onChanged != null
                  ? (value) => widget.onChanged(value)
                  : (value) => null,
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                // labelText: label,
                hintText: widget.hint,
                suffixIcon: widget.suffix != null ? widget.suffix : SizedBox(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                fillColor:
                    theme.isDarkTheme() ? Colors.black54 : Colors.grey.shade100,
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 2,
                  vertical: SizeConfig.blockSizeVertical * 1.8,
                ),
                alignLabelWithHint: false,
                isDense: true,
                labelStyle: GoogleFonts.lato(
                  fontSize: widget.labelSize != null
                      ? widget.labelSize
                      : SizeConfig.safeBlockHorizontal * 5.2,
                  color: Colors.black54,
                ),
                hintStyle: GoogleFonts.lato(
                  fontWeight: FontWeight.w400,
                  fontSize: SizeConfig.safeBlockHorizontal * 4,
                ),
                enabledBorder: theme.isDarkTheme()
                    ? UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      )
                    : UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(5),
                      ),
                focusedBorder: theme.isDarkTheme()
                    ? UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      )
                    : UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(5),
                      ),
                border: theme.isDarkTheme()
                    ? UnderlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      )
                    : UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(5),
                      ),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return '${widget.hint != null ? widget.hint : widget.label} must not be empty';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
