import 'package:flutter/material.dart';
import 'package:private_llm/pages/chatscreen.dart';
import 'package:private_llm/utils/border_gradient.dart';
import 'package:private_llm/utils/gradient.dart';
import 'package:private_llm/utils/url_launch.dart';
import 'package:typewritertext/typewritertext.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/file_open.dart';

class AboutMePage extends StatefulWidget {
  const AboutMePage({super.key});

  @override
  _AboutMePageState createState() => _AboutMePageState();
}

class _AboutMePageState extends State<AboutMePage> {
  bool _isDropdownOpen = false;
  bool _isLoadingFile = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final meController = TypeWriterController(
      text: "I am Anisha.", duration: const Duration(milliseconds: 90));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: MediaQuery.of(context).size.width < 600
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              )
            : null,
        title: Text(''),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            GradientText("Hello",
                colors: const [
                  Color.fromARGB(233, 80, 172, 247),
                  Color.fromARGB(228, 249, 100, 100),
                ],
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? MediaQuery.of(context).size.width * 0.077
                      : MediaQuery.of(context).size.width * 0.027,
                  fontWeight: FontWeight.w400,
                )

                // style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
            TypeWriter(
              controller: meController,
              builder: (context, value) {
                return GradientText(value.text,
                    colors: const [
                      Color.fromARGB(233, 80, 172, 247),
                      Color.fromARGB(228, 249, 100, 100),
                    ],
                    style: TextStyle(
                      fontSize: isSmallScreen
                          ? MediaQuery.of(context).size.width * 0.077
                          : MediaQuery.of(context).size.width * 0.027,
                      fontWeight: FontWeight.w400,
                    ));
              },
            ),
            SizedBox(height: 16),
            TypeWriter.text(
              'Passionate developer with a keen interest in creating beautiful and functional applications. '
              'I love to explore new technologies and implement creative solutions to solve real-world problems.',
              duration: Duration(milliseconds: 30),
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: size.height * (isSmallScreen ? 0.2 : 0.15)),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isDropdownOpen = !_isDropdownOpen;
                });
              },
              child: BorderGradient(
                borderRadius: 12,
                child: Expanded(
                  child: AnimatedContainer(
                    clipBehavior: Clip.none,
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(16),
                    // decoration: BoxDecoration(
                    //   color: Colors.grey[200],
                    //   borderRadius: BorderRadius.circular(12),
                    // ),
                    height: _isDropdownOpen
                        ? size.height *
                            (isSmallScreen
                                ? 0.45
                                : isDesktop
                                    ? 0.55
                                    : 0.75)
                        : size.height * (isSmallScreen ? 0.15 : 0.15),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: const Text(
                              'Social Profiles',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            trailing: Icon(
                              color: Colors.black54,
                              _isDropdownOpen
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                            onTap: () {
                              setState(() {
                                _isDropdownOpen = !_isDropdownOpen;
                              });
                            },
                          ),
                          // if (_isDropdownOpen) SizedBox(height: 16),
                          if (_isDropdownOpen)
                            Column(
                              children: [
                                _socialCard(
                                  "GitHub",
                                  "https://github.com/AnishaShende",
                                  Colors.teal[300],
                                ),
                                _socialCard(
                                  "LinkedIn",
                                  "https://www.linkedin.com/in/anishashende",
                                  Colors.teal[400],
                                ),
                                _socialCard(
                                  "X",
                                  "https://x.com/Anisha_Shende",
                                  Colors.teal[500],
                                ),
                                _socialCard(
                                  "Portfolio",
                                  "https://anishashende.dev",
                                  Colors.teal[600],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 32),

            // Resume Card
            Card(
              color: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white70, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildResumeButton(),
              ),
            ),

            SizedBox(height: size.height * 0.25),

            // Footer Section
            Center(
              child: Text(
                "Made with ❤️ by Anisha Shende | ©️ All rights reserved",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black54,
    );
  }

  Widget _buildResumeButton() {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isLoadingFile = true;
        });

        try {
          await openOtherTypeFile();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to open file')),
          );
        } finally {
          if (mounted) {
            setState(() {
              _isLoadingFile = false;
            });
          }
        }
      },
      child: Row(
        children: [
          if (_isLoadingFile)
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Colors.teal,
                strokeWidth: 2,
              ),
            )
          else
            const Icon(
              Icons.insert_drive_file,
              color: Colors.teal,
              size: 32,
            ),
          const SizedBox(width: 16),
          Text(
            "Resume.docx",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create a social profile card
  Widget _socialCard(String title, String url, Color? color) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      color: color,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          url,
          style: TextStyle(color: Colors.white70),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(Icons.open_in_new, color: Colors.white),
        onTap: () async {
          try {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await UrlLaunch(uri.toString()).launchUrl();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not open $title link')),
              );
            }
          }
        },
      ),
    );
  }
}
