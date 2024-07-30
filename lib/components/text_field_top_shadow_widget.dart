import 'package:agro_k/theme/colors.dart';
import 'package:flutter/material.dart';

class TextFieldTopShadowWidget extends StatefulWidget {
  final double width;
  final String titleText;
  final String hintText;
  final TextEditingController controller;

  const TextFieldTopShadowWidget({
    Key? key,
    required this.width,
    required this.titleText,
    required this.hintText,
    required this.controller
  }) : super(key: key);

  @override
  TextFieldTopShadowWidgetState createState() => TextFieldTopShadowWidgetState();
}

class TextFieldTopShadowWidgetState extends State<TextFieldTopShadowWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.titleText, style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w400)),
        const SizedBox(
          height: 5,
        ),
        Container(
          width: widget.width,
          decoration: const ShapeDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFe6dfd8), Color(0xFFf7f5ec)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4],
              tileMode: TileMode.clamp,
            ),
            shape: RoundedRectangleBorder(),
          ),
          child: TextFormField(
            controller: widget.controller,
            expands: false,
            style: const TextStyle(fontSize: 20.0, color: Colors.black54),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(12.0),
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: AppColors.hintTextColor),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
