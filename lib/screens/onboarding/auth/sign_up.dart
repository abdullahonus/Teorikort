import 'package:flutter/material.dart';
import 'package:taxi/product/widgets/button_widget.dart';
import 'package:taxi/product/widgets/textformfield_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

TextEditingController nameSurnameController = TextEditingController();
TextEditingController mailController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController rePasswordController = TextEditingController();
TextEditingController phoneController = TextEditingController();
TextEditingController locationController = TextEditingController();

class _SignUpScreenState extends State<SignUpScreen> {
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
            toolbarHeight: MediaQuery.of(context).size.height / 6,
            backgroundColor: Colors.orange,
            shape: const RoundedRectangleBorder(
              // AppBar'ın kenarlık şeklini ayarlar
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "DRIVING EXAM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 50.0),
                Text(
                  "REGISTER",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Divider(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 5.0),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 20.0,
                  ),
                ),
                const SizedBox(height: 5.0),
                TextFormFieldWidget(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  prefixIcon: Icons.person,
                  controller: nameSurnameController,
                  focusColor: Colors.orange,
                  labelText: "Name Surname",
                ),
                const SizedBox(height: 30.0),
                TextFormFieldWidget(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  prefixIcon: Icons.mail,
                  controller: mailController,
                  labelText: "Mail Address",
                  focusColor: Colors.orange,
                ),
                const SizedBox(height: 30.0),
                TextFormFieldWidget(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  prefixIcon: Icons.lock,
                  obsecureText: true,
                  controller: passwordController,
                  labelText: "Password",
                  focusColor: Colors.orange,
                ),
                const SizedBox(height: 30.0),
                TextFormFieldWidget(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  obsecureText: true,
                  prefixIcon: Icons.lock,
                  controller: rePasswordController,
                  focusColor: Colors.orange,
                  labelText: "Re-Password",
                ),
                const SizedBox(height: 30.0),
                TextFormFieldWidget(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  prefixIcon: Icons.phone,
                  controller: phoneController,
                  labelText: "Phone Number",
                  focusColor: Colors.orange,
                ),
                const SizedBox(height: 30.0),
                TextFormFieldWidget(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  prefixIcon: Icons.location_on,
                  controller: locationController,
                  labelText: "Location",
                  focusColor: Colors.orange,
                ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: BasicButton(
                    onPressed: () {},
                    child: const Text("Sign Up"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
