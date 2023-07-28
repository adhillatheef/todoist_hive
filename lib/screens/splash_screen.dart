import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:todoist_hive/screens/task_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(milliseconds: 3000),
        () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const TaskScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Row(
          children: [
            Hero(
              tag: 'logo',
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                child: ClipRRect(
                  child: Image.asset('assets/image/todo.png'),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: DefaultTextStyle(
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 60.0,
                    fontFamily: 'Quicksand',
                    color: Colors.white),
                child: AnimatedTextKit(animatedTexts: [
                  TypewriterAnimatedText('ToDoIst',
                      speed: const Duration(milliseconds: 200))
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
