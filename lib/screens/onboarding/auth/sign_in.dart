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
        /* Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.drive_eta_rounded,
                            color: Colors.white, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Başlık',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
            Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text(" Don't have an account?  Sign up!"),
            ),
          ],
        ),
       */
      ),
    ));
  }
}
