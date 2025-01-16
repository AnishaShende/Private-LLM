import 'package:flutter/material.dart';
import 'package:private_llm/component/button.dart';
import 'package:private_llm/component/icon.dart';
import 'package:sidebarx/sidebarx.dart';

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);

class SideNavbar extends StatelessWidget {
  // const SideNavbar({super.key});

  const SideNavbar(
      {super.key, required SidebarXController controller, this.onNewChat})
      : _controller = controller;
  final SidebarXController _controller;
  final VoidCallback? onNewChat;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: scaffoldBackgroundColor,
        textStyle:
            TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.7)),
        selectedTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [accentCanvasColor, canvasColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(width: 300),
      footerDivider: Divider(color: Colors.white.withOpacity(0.8), height: 1),
      headerBuilder: (context, extended) {
        if (extended) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: NewButton(
              controller: _controller,
              onNewChat: onNewChat,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: const GradientIcon(size: 24.0),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.chat,
          label: 'General',
        ),
        SidebarXItem(
          icon: Icons.school,
          label: 'Education',
          // onTap: () {
          //   debugPrint('Education');
          // },
        ),
        SidebarXItem(
          icon: Icons.computer,
          label: 'Projects',
          // onTap: () {
          //   debugPrint('Projects');
          // },
        ),
        SidebarXItem(
          icon: Icons.work,
          label: 'Experience',
          // onTap: () {
          //   debugPrint('Experience');
          //   // _handleNavigation('Experience');
          //   // widget.onChatInit(defaultMessages['Experience']!);
          // },
        ),
        SidebarXItem(
          icon: Icons.build,
          label: 'Skills',
          // onTap: () {
          //   debugPrint('Skills');
          //   // _handleNavigation('Skills');
          //   // widget.onChatInit(defaultMessages['Skills']!);
          // },
        ),
        SidebarXItem(
          icon: Icons.sentiment_very_satisfied,
          label: 'Fun',
        ),
      ],

      // Your app screen body
    );
  }
}
