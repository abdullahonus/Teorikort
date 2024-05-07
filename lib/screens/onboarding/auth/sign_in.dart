/* import 'package:flutter/material.dart';
import 'package:taxi/utils/widgets/button_widget.dart';
import 'package:taxi/utils/widgets/textformfield_widget.dart';

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
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              elevation: 0,
              toolbarHeight: MediaQuery.of(context).size.height / 2,
              collapsedHeight: MediaQuery.of(context).size.height / 2,
              backgroundColor: const Color.fromRGBO(255, 152, 0, 1),
              flexibleSpace: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/direksiyon.png',
                      scale: 0.8,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Merhaba!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      width: 50.0,
                      height: 5.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              floating: true,
              snap: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 100.0, left: 40.0, right: 40.0),
                    child: Column(
                      children: [
                        TextFormFieldComponent(
                          prefixIcon: Icons.email,
                          controller: mailController,
                          labelText: 'Email',
                          suffixIcon: const Icon(
                            Icons.email,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormFieldComponent(
                          prefixIcon: Icons.lock,
                          controller: passwordController,
                          labelText: 'Password',
                          obsecureText: true,
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text("Forget Password"),
                        ),
                        const SizedBox(height: 20),
                        BasicButton(
                          onPressed: () {},
                          child: const Text(
                            'Sign In',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child:
                              const Text(" Don't have an account?  Sign up!"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        
      ),
    ));
  }
}
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:taxi/screens/main_screen/main_screen.dart';
import 'package:taxi/screens/onboarding/auth/sign_up.dart';
import 'package:taxi/widgets/button_widget.dart';
import 'package:taxi/widgets/textformfield_widget.dart';
import 'package:taxi/widgets/uniq_appbar.dart';

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
          appBar: AppBar(
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
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 100.0, left: 40.0, right: 40.0),
                  child: Column(
                    children: [
                      TextFormFieldWidget(
                        prefixIcon: Icons.email,
                        controller: mailController,
                        labelText: 'Email',
                        suffixIcon: const Icon(
                          Icons.email,
                          color: Colors.black,
                        ),
                        focusColor: Colors.orange,
                      ),
                      const SizedBox(height: 20),
                      TextFormFieldWidget(
                        prefixIcon: Icons.lock,
                        controller: passwordController,
                        labelText: 'Password',
                        obsecureText: true,
                        focusColor: Colors.orange,
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Forget Password"),
                      ),
                      const SizedBox(height: 100),
                      BasicButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text(" Don't have an account?  Sign up!"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
