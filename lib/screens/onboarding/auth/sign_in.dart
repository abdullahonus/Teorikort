import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi/custome_widgets/custom_button_widgets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController mailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          /*  appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            toolbarHeight: MediaQuery.of(context).size.height / 2.5,
            backgroundColor: Colors.orange,
            shape: const RoundedRectangleBorder(
              // AppBar'ın kenarlık şeklini ayarlar
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icons/direksiyon.png',
                  scale: 1.5,
                ),
                const Text(
                  "Driving Exam",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 80.0),
                const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50.0),
                const Divider(
                  color: Colors.white,
                  thickness: 5.0,
                  indent: 150.0,
                  endIndent: 150.0,
                ),
              ],
            ),
          ),
          */
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFE4EEF5),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: Image.asset(
                  alignment: Alignment.center,
                  'assets/png/onboarding_person_image.png',
                  width: double.infinity,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Do your Exam test and get the best score",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 23.0.h,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Text(
                "Studty with us and get the best score",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0.h,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: CustomElevatedButton(
                  text: "Get Started",
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/signIn', (route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
