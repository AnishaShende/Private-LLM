import 'dart:math';
import 'package:flutter/material.dart';
import 'package:private_llm/utils/border_gradient.dart';
import 'package:sidebarx/sidebarx.dart';

class NewButton extends StatefulWidget {
  final SidebarXController controller;
  final VoidCallback? onNewChat;

  const NewButton({Key? key, required this.controller, this.onNewChat})
      : super(key: key);

  @override
  _NewButtonState createState() => _NewButtonState();
}

class _NewButtonState extends State<NewButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 25, bottom: 25),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: BorderGradient(
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 20),
                const SizedBox(width: 8),
                TextButton(
                  child: const Text('New Chat'),
                  onPressed: () {
                    widget.controller.selectIndex(0);
                    widget.onNewChat?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
