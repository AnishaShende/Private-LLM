import 'package:flutter/material.dart';
import 'package:private_llm/component/button.dart';
import 'package:private_llm/component/my_icon.dart';
import 'package:sidebarx/sidebarx.dart';

const primaryColor = Color(0xFF685BFF);
const canvasColor = Color(0xFF2E2E48);
const scaffoldBackgroundColor = Color(0xFF464667);
const accentCanvasColor = Color(0xFF3E3E61);
const white = Colors.white;
final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
final divider = Divider(color: white.withOpacity(0.3), height: 1);

class SideNavbar extends StatelessWidget {
  SideNavbar(
      {super.key,
      required SidebarXController controller,
      this.onNewChat,
      this.isSmallScreen = false})
      : _controller = controller;
  final SidebarXController _controller;
  final VoidCallback? onNewChat;
  final bool isSmallScreen;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool isDesktop = MediaQuery.of(context).size.width > 1200;
    return SidebarX(
      showToggleButton: isSmallScreen ? false : true,
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
      extendedTheme: SidebarXTheme(
          width: isSmallScreen
              ? size.width * 0.5
              : isDesktop
                  ? size.width * 0.2
                  : size.width * 0.35),
      footerDivider: Divider(color: Colors.white.withOpacity(0.8), height: 1),
      headerBuilder: (context, extended) {
        isSmallScreen ? extended = false : true;
        if (extended) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            clipBehavior: Clip.none,
            curve: Curves.easeInOut,
            width: extended ? double.infinity : 0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: NewButton(
                controller: _controller,
                onNewChat: onNewChat,
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: GradientIcon(
            size: isSmallScreen ? 30.0 : 24.0,
            controller: _controller,
            onNewChat: onNewChat,
          ),
        );
      },
      items: [
        SidebarXItem(
          icon: Icons.chat,
          label: 'General',
          // onTap: () => debugPrint('size: $size'),
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
          // },
        ),
        SidebarXItem(
          icon: Icons.build,
          label: 'Skills',
          // onTap: () {
          //   debugPrint('Skills');
          // },
        ),
        SidebarXItem(
          icon: Icons.sentiment_very_satisfied,
          label: 'Fun',
        ),
        SidebarXItem(
          icon: Icons.favorite_outline,
          label: 'About',
        ),
      ],
    );
  }
}
/////////////////////////
