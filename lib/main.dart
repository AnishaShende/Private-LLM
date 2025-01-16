import 'package:flutter/material.dart';
import 'package:private_llm/component/side_navbar.dart';
// import 'package:private_llm/component/navigation_bar.dart';
import 'package:private_llm/pages/new_chatscreen.dart';
import 'package:sidebarx/sidebarx.dart';
// import 'package:sidebarx/sidebarx.dart';
import 'services/feedback_service.dart';
// import 'services/gemma_service.dart';
// import 'component/main_chat_screen.dart';
import 'services/platform_service.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Only initialize window manager for desktop
  if (PlatformService.isDesktop) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal, // Change this from hidden to normal
      minimumSize: Size(400, 600),
      title: 'Anisha\'s AI',
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setPreventClose(true);
    });
  }

  // Initialize feedback service only if not running on web
  if (!PlatformService.isWeb) {
    await FeedbackService.init();
  }

  // runApp(const ChatApp());
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  // final GemmaService gemmaService;

  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat with Anisha\'s AI',
      // theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const NewChatscreen(),
      // home: ChatScreen(gemmaService: gemmaService),
    );
  }
}

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final _controller = SidebarXController(selectedIndex: 0, extended: true);
//   final _key = GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Builder(builder: (context) {
//         final isSmallScreen = MediaQuery.of(context).size.width < 600;
//         return Scaffold(
//             key: _key,
//             appBar: isSmallScreen
//                 ? AppBar(
//                     title: Text('SideBarX'),
//                     leading: IconButton(
//                       onPressed: () {
//                         _key.currentState?.openDrawer();
//                       },
//                       icon: Icon(Icons.menu),
//                     ),
//                   )
//                 : null,
//             drawer: SideNavbar(
//               controller: _controller,
//             ),
//             body: Row(
//               children: [
//                 if (!isSmallScreen) SideNavbar(controller: _controller),
//                 Expanded(
//                     child: Center(
//                   child: AnimatedBuilder(
//                     animation: _controller,
//                     builder: (context, child) {
//                       switch (_controller.selectedIndex) {
//                         case 0:
//                           _key.currentState?.closeDrawer();
//                           return Center(
//                             child: Text(
//                               'Home',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 40),
//                             ),
//                           );
//                         case 1:
//                           _key.currentState?.closeDrawer();
//                           return Center(
//                             child: Text(
//                               'Search',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 40),
//                             ),
//                           );
//                         case 2:
//                           _key.currentState?.closeDrawer();
//                           return Center(
//                             child: Text(
//                               'Settings',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 40),
//                             ),
//                           );
//                         case 3:
//                           _key.currentState?.closeDrawer();
//                           return Center(
//                             child: Text(
//                               'Theme',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 40),
//                             ),
//                           );
//                         default:
//                           return Center(
//                             child: Text(
//                               'Home',
//                               style:
//                                   TextStyle(color: Colors.white, fontSize: 40),
//                             ),
//                           );
//                       }
//                     },
//                   ),
//                 ))
//               ],
//             ));
//       }),
//     );
//   }
// }
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// void _handleChatInit(String initialMessage) {
//   // Create new chat instance with initial message
//   // You can use your existing chat service here
// }

// class _MainScreenState extends State<MainScreen> {
//   // bool _isNavExpanded = true;
//   // final _controller = SidebarXController(selectedIndex: 0, extended: true);
//   final _key = GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Builder(
//         builder: (context) {
//           final isSmallScreen = MediaQuery.of(context).size.width < 600;
//           return Scaffold(
//             key: _key,
//             appBar: isSmallScreen
//                 ? AppBar(
//                     title: Text('Sections'),
//                     leading: IconButton(
//                       onPressed: () {
//                         _key.currentState?.openDrawer();
//                       },
//                       icon: Icon(Icons.menu),
//                     ),
//                   )
//                 : null,
//             // drawer: SideNavigationBar(onTabChanged: (String value) {  },
//             //   // onChatInit: _handleChatInit,
//             // ),
//             body: Row(
//               children: [
//                 if (!isSmallScreen)
//                   // SideNavigationBar(
//                   //   // onChatInit: _handleChatInit,
//                   // ),
//                   Expanded(
//                     child: MainChatScreen(), // Your existing chat screen
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
