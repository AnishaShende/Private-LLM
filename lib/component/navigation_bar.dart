// import 'package:flutter/material.dart';
// import 'package:private_llm/component/button.dart';
// import 'package:private_llm/component/icon.dart';
// import 'package:sidebarx/sidebarx.dart';

// // import 'main_chat_screen.dart';

// const primaryColor = Color(0xFF685BFF);
// const canvasColor = Color(0xFF2E2E48);
// const scaffoldBackgroundColor = Color(0xFF464667);
// const accentCanvasColor = Color(0xFF3E3E61);
// const white = Colors.white;
// final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
// final divider = Divider(color: white.withOpacity(0.3), height: 1);

// class SideNavigationBar extends StatefulWidget {
//   // final Function(String) onChatInit;
//   final ValueChanged<String> onTabChanged;

//   const SideNavigationBar({super.key, required this.onTabChanged});

//   @override
//   State<SideNavigationBar> createState() => _SideNavigationBarState();
// }

// class _SideNavigationBarState extends State<SideNavigationBar> {
//   late SidebarXController _controller;
//   int _selectedIndex = 0;

//   // final List<String> educationList = [
//   //   "Tell me about Anisha's education history.",
//   //   "Tell me about Anisha's education history.",
//   //   "Tell me about Anisha's education history.",
//   //   "Tell me about Anisha's education history.",
//   // ];

//   // final List<String> projectsList = [
//   //   "What projects has Anisha worked on?",
//   //   "What projects has Anisha worked on?",
//   //   "What projects has Anisha worked on?",
//   //   "What projects has Anisha worked on?",
//   // ];

//   // final List<String> experienceList = [
//   //   "What is Anisha's work history?",
//   //   "What is Anisha's work history?",
//   //   "What is Anisha's work history?",
//   //   "What is Anisha's work history?",
//   // ];

//   // final List<String> skillsList = [
//   //   "Tell me about Anisha's technical skills",
//   //   "Tell me about Anisha's technical skills",
//   //   "Tell me about Anisha's technical skills",
//   //   "Tell me about Anisha's technical skills",
//   // ];

//   // final Function(String) onChatInit;
//   // First question will be default then display questions from 2nd to last
//   // late final Map<String, List<String>> defaultMessages;
//   // final Map<String, List<String>> defaultMessages = {
//   //   'Education': [
//   //     "Tell me about Anisha's education history.",
//   //     "Tell me about Anisha's education history.",
//   //     "Tell me about Anisha's education history.",
//   //     "Tell me about Anisha's education history.",
//   //   ],
//   //   'Projects': [
//   //     "What projects has Anisha worked on?",
//   //     "What projects has Anisha worked on?",
//   //     "What projects has Anisha worked on?",
//   //     "What projects has Anisha worked on?",
//   //   ],
//   //   'Experience': [
//   //     "What is Anisha's work history?",
//   //     "What is Anisha's work history?",
//   //     "What is Anisha's work history?",
//   //     "What is Anisha's work history?",
//   //   ],
//   //   'Skills': [
//   //     "Tell me about Anisha's technical skills",
//   //     "Tell me about Anisha's technical skills",
//   //     "Tell me about Anisha's technical skills",
//   //     "Tell me about Anisha's technical skills",
//   //   ],
//   // };

//   @override
//   void initState() {
//     super.initState();
//     _controller = SidebarXController(selectedIndex: 0, extended: true);
//   }

//   // defaultMessages = {
//   //   'Education': educationList,
//   //   'Projects': projectsList,
//   //   'Experience': experienceList,
//   //   'Skills': skillsList,
//   // };
//   // void _handleNavigation(String type) {
//   //   // _controller.addListener(() => _handleNavigation(defaultMessages[type]));
//   //   if (type.isEmpty) return;

//   //   Navigator.pushReplacement(
//   //     context,
//   //     MaterialPageRoute(
//   //       builder: (context) => MainChatScreen(
//   //         isMainChatScreen: false,
//   //         screenType: type,
//   //         // initialMessages: defaultMessages[type] ?? [],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // String? _getSelectedItem(int index) {
//   //   switch (index) {
//   //     case 0:
//   //       return 'Education';
//   //     case 1:
//   //       return 'Projects';
//   //     case 2:
//   //       return 'Experience';
//   //     case 3:
//   //       return 'Skills';
//   //     default:
//   //       return null;
//   //   }
//   // }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SidebarX(
//       controller: _controller,
//       // theme: SidebarXTheme(
//       //   margin: const EdgeInsets.all(10),
//       //   decoration: BoxDecoration(
//       //       color: Colors.black54,
//       //       borderRadius: const BorderRadius.only(
//       //           topRight: Radius.circular(20),
//       //           bottomRight: Radius.circular(20))),
//       //   iconTheme: const IconThemeData(
//       //     color: Colors.white,
//       //   ),
//       //   selectedTextStyle: const TextStyle(color: Colors.white),
//       // ),
//       theme: SidebarXTheme(
//         margin: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: canvasColor,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         hoverColor: scaffoldBackgroundColor,
//         textStyle:
//             TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.7)),
//         selectedTextStyle:
//             const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//         hoverTextStyle: const TextStyle(
//           color: Colors.white,
//           fontSize: 15,
//           fontWeight: FontWeight.w500,
//         ),
//         itemTextPadding: const EdgeInsets.only(left: 30),
//         selectedItemTextPadding: const EdgeInsets.only(left: 30),
//         itemDecoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: canvasColor),
//         ),
//         selectedItemDecoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: actionColor.withOpacity(0.37),
//           ),
//           gradient: const LinearGradient(
//             colors: [accentCanvasColor, canvasColor],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.28),
//               blurRadius: 30,
//             )
//           ],
//         ),
//         iconTheme: IconThemeData(
//           color: Colors.white.withOpacity(0.7),
//           size: 20,
//         ),
//         selectedIconTheme: const IconThemeData(
//           color: Colors.white,
//           size: 20,
//         ),
//       ),
//       extendedTheme: const SidebarXTheme(width: 250),
//       footerDivider: Divider(color: Colors.white.withOpacity(0.8), height: 1),
//       headerBuilder: (context, extended) {
//         if (extended) {
//           return Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: NewButton(controller: _controller),
//           );
//         }
//         return Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: const GradientIcon(size: 24.0),
//         );
//       },
//       items: [
//         SidebarXItem(
//           icon: Icons.school,
//           label: 'General',
//           onTap: () {
//             // setState(() => _selectedIndex = 0);
//             widget.onTabChanged('General');
//             debugPrint('General');
//             // _handleNavigation('Education');
//             // widget.onChatInit(defaultMessages['Education']!);
//           },
//         ),
//         SidebarXItem(
//           icon: Icons.school,
//           label: 'Education',
//           onTap: () {
//             // setState(() => _selectedIndex = 0);
//             widget.onTabChanged('Education');
//             debugPrint('Education');
//             // _handleNavigation('Education');
//             // widget.onChatInit(defaultMessages['Education']!);
//           },
//         ),
//         SidebarXItem(
//           icon: Icons.computer,
//           label: 'Projects',
//           onTap: () {
//             // setState(() => _selectedIndex = 1);
//             debugPrint('Projects');
//             // debugPrint('default messages: ${defaultMessages['Projects']}');
//             // debugPrint(
//             //     'Projects type: ${defaultMessages['Projects'].runtimeType}');
//             // debugPrint(
//             //     'Single message type: ${defaultMessages['Projects']![0].runtimeType}');
//             // debugPrint('Default messages type: ${defaultMessages.runtimeType}');
//             // _handleNavigation('Projects');
//             // widget.onChatInit(defaultMessages['Projects']!);
//           },
//         ),
//         SidebarXItem(
//           icon: Icons.work,
//           label: 'Experience',
//           onTap: () {
//             // setState(() => _selectedIndex = 2);
//             debugPrint('Experience');
//             // _handleNavigation('Experience');
//             // widget.onChatInit(defaultMessages['Experience']!);
//           },
//         ),
//         SidebarXItem(
//           icon: Icons.build,
//           label: 'Skills',
//           onTap: () {
//             // setState(() => _selectedIndex = 3);
//             debugPrint('Skills');
//             // _handleNavigation('Skills');
//             // widget.onChatInit(defaultMessages['Skills']!);
//           },
//         ),
//         SidebarXItem(
//           icon: Icons.school,
//           label: 'Fun',
//           onTap: () {
//             // setState(() => _selectedIndex = 0);
//             widget.onTabChanged('Fun');
//             debugPrint('Fun');
//             // _handleNavigation('Education');
//             // widget.onChatInit(defaultMessages['Education']!);
//           },
//         ),
//       ],

//       // Your app screen body
//     );
//   }
// }
