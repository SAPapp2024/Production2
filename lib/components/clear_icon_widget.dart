
import 'package:flutter/material.dart';

class ClearIcon extends StatelessWidget {

  final TextEditingController controller;
  final VoidCallback clearPressed;
  
  const ClearIcon(this.controller, this.clearPressed, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
                                            padding: const EdgeInsets.all(0.0),
                                            child: IconButton(
                                              hoverColor: Colors.transparent,
                                              splashColor: Colors.transparent,                                         
                                              onPressed: () {
                                                if (controller.text.isNotEmpty) {
                                                  controller.text = "";
                                                  //Run search again
                                                  clearPressed();
                                                }
                                              },
                                              icon: const Icon(Icons.clear, color: Colors.red,)));
  }


  
}