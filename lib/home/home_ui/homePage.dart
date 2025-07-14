import 'dart:async';
import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:safer/FamilyTracker/FamilyTrackerPage.dart';
import 'package:safer/home/chatbot/chatbot_page.dart';
import 'package:safer/home/contacts_ui/contacts_call_page.dart';
import 'package:safer/home/contacts_ui/Contact_location_Page.dart';
import 'package:safer/home/home_ui/home_bloc/alert/alert.dart';
import 'package:safer/home/home_ui/home_bloc/call/call_bloc.dart';
import 'package:safer/home/home_ui/home_bloc/call/utils/call_utils.dart';
import 'package:safer/home/home_ui/home_bloc/contacts/contacts_bloc.dart';
import 'package:safer/home/home_ui/home_bloc/location/location_sharing_bloc.dart';
import 'package:safer/home/home_ui/home_bloc/location_contacts/location_contacts_bloc.dart';
import 'package:safer/home/home_ui/home_bloc/location_contacts/location_contacts_state.dart';
import 'package:safer/login/login_ui/loginPage.dart';
import '../../LegalAwareness/LegalAwarenessPage.dart';
import '../SOS.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin  {
  String displayName = "";
  bool isAlertPlaying = false;
  late AnimationController _typingController;
  late Animation<int> _charCount;
  String greeting = "";
  late final PageController _carouselController;
  Timer? _carouselTimer;
  final int _initialPage = 1000;

  final List<String> tips = [
    "Avoid isolated areas at night.",
    "Always share your live location when felt danger.",
    "Keep emergency contacts updated.",
    "Walk confidently and stay alert.",
    "Don’t share travel plans with strangers.",
    "Trust your instincts and seek help early.",
    "Check vehicle plates before boarding.",
    "Use only verified ride-sharing apps.",
  ];


  @override
  void initState() {
    super.initState();
    getDisplayName();
    context.read<ContactsBloc>().add(FetchSavedContactsEvent());

    _typingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    greeting = "Hello, ${FirebaseAuth.instance.currentUser?.displayName ?? "User"}!!";
    _charCount = StepTween(begin: 0, end: greeting.length).animate(
      CurvedAnimation(parent: _typingController, curve: Curves.easeIn),
    );
    _typingController.forward();

    _carouselController = PageController(initialPage: _initialPage, viewportFraction: 0.85);

    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_carouselController.hasClients) {
        _carouselController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }


  @override
  void dispose() {
    _typingController.dispose();
    _carouselTimer?.cancel();
    _carouselController.dispose();
    super.dispose();
  }

  void getDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      displayName = user?.displayName ?? 'User';
    });
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (_) => CallBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Animate(
            effects: [FadeEffect(duration: 600.ms), SlideEffect(begin: Offset(-0.5, 0))],
            child: Text(
              "SafeHer",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: width * 0.065,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          centerTitle: true,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
              splashRadius: 24,
              tooltip: 'Menu',
            ),
          ),
        ),
        drawer: _buildDrawer(),
        body: Column(
          children: [
            Container(
              height: height * 0.15,
              width: width,
              child: Image.asset(
                'assets/images/safe.png',
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: height * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _typingGreeting(width),
                    SizedBox(height: height * 0.01),
                    _subtitle(width),
                    SizedBox(height: height * 0.03),
                    _buildActionButtons(width, height),
                    SizedBox(height: height * 0.03),
                    _buildMoreButtons(width, height),
                    SizedBox(height: height * 0.04),
                    _buildSafetyTips(width, height),
                    SizedBox(height: height * 0.08),
                    _buildLegalAwarenessCard(width, height),
                    SizedBox(height: height * 0.03),
                    _buildFamilyRelationshipTrackerCard(width, height),
                    SizedBox(height: height * 0.095),
                  ],
                ),
              ),
            )
          ],
        ),
        floatingActionButton: Animate(
          effects: [
            SlideEffect(begin: Offset(0, 1), curve: Curves.easeOut, duration: 600.ms),
            FadeEffect(duration: 600.ms),
          ],
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatBotPage())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C9A7), Color(0xFF007F6C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.smart_toy_outlined, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    "Assistant",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _typingGreeting(double width) {
    final firstName = displayName.split(" ")[0];

    return DefaultTextStyle(
      style: GoogleFonts.poppins(
        fontSize: width * 0.065,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      child: AnimatedTextKit(
        isRepeatingAnimation: true,
        repeatForever: true,
        animatedTexts: [
          TypewriterAnimatedText(
            "Hello, $firstName!!",
            speed: const Duration(milliseconds: 100),
          ),
        ],
      ),
    );
  }


  Widget _subtitle(double width) {
    return Text(
      "What would you like to do today?",
      style: GoogleFonts.poppins(
        fontSize: width * 0.04,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildActionButtons(double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _glassButton(Icons.sos, "SOS", Colors.redAccent, () {
          SOSHandler.triggerSOS(context, (val) {
            setState(() => isAlertPlaying = val);
          });
        }, width, height),
        _glassButton(Icons.call, "Call", Colors.green, () => clickToCall(context), width, height),
      ],
    );
  }

  Widget _buildMoreButtons(double width, double height) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _glassButton(
          isAlertPlaying ? Icons.stop_circle : Icons.warning_amber,
          isAlertPlaying ? "Stop Alert" : "Alert",
          Colors.orange,
              () async {
            if (isAlertPlaying) {
              await stopAlertSound();
            } else {
              await playAlertSound();
            }
            setState(() => isAlertPlaying = !isAlertPlaying);
          },
          width,
          height,
        ),
        _glassButton(Icons.location_on, "Location", Colors.blue, () {
          final state = context.read<LocationContactsBloc>().state;
          if (state is LocationContactsLoaded) {
            context.read<LocationSharingBloc>().add(
              ShareLocationEvent(selectedContacts: state.selectedLocationContacts),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No contacts selected")),
            );
          }
        }, width, height),
      ],
    );
  }

  Widget _glassButton(
      IconData icon,
      String label,
      Color color,
      VoidCallback onTap,
      double width,
      double height,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * 0.356,
        height: height * 0.156,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.25),
              color.withOpacity(0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(40), // Pill-like shape
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: width * 0.1, color: color),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: width * 0.042,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyTips(double width, double height) {
    return SizedBox(
      height: height * 0.22,
      child: PageView.builder(
        controller: _carouselController,
        itemBuilder: (context, index) {
          final tip = tips[index % tips.length];

          return Animate(
            effects: [
              FadeEffect(duration: 600.ms),
              ScaleEffect(duration: 500.ms, curve: Curves.easeInOut),
            ],
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: width * 0.025, vertical: height * 0.01),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    Colors.tealAccent.withOpacity(0.07),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 4,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                      vertical: height * 0.025,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          color: Colors.tealAccent,
                          size: width * 0.1,
                          shadows: [
                            Shadow(
                              color: Colors.tealAccent.withOpacity(0.6),
                              blurRadius: 20,
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tip,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                            shadows: const [
                              Shadow(color: Colors.black26, blurRadius: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }





  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Background blur effect
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
              ),
            ),
          ),

          Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C9A7), Color(0xFF007F6C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          FirebaseAuth.instance.currentUser?.photoURL ??
                              'https://www.gravatar.com/avatar/placeholder',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              FirebaseAuth.instance.currentUser?.email ?? '',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              _drawerItem(Icons.call, "Contacts to Call", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactsPage()));
              }),
              _drawerItem(Icons.location_on, "Location Contacts", () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LocationContactsPage()));
              }),
              const Spacer(),
              _drawerItem(Icons.logout, "Logout", () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
              }),
              const SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.tealAccent,
        shadows: [
          Shadow(color: Colors.tealAccent.withOpacity(0.5), blurRadius: 10),
        ],
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      hoverColor: Colors.white10,
      splashColor: Colors.teal.withOpacity(0.2),
    );
  }

  Widget _buildLegalAwarenessCard(double width, double height) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LegalAwarenessPage()),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: width * 0.015),
        padding: EdgeInsets.all(width * 0.045),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF556B2F), Color(0xFF8FBC8F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.gavel_rounded, size: 32, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "Know Your Rights:\nLegal Help & Protection",
                style: GoogleFonts.poppins(
                  fontSize: width * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyRelationshipTrackerCard(double width, double height) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FamilyTrackerPage()),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: width * 0.015),
        padding: EdgeInsets.all(width * 0.045),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)], // Deep purple tones
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.family_restroom, size: 32, color: Colors.white),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "Track Family Behavior:\nHome Safety & Relationships",
                style: GoogleFonts.poppins(
                  fontSize: width * 0.038,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}
