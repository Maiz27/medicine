import 'package:flutter/material.dart';
import 'package:medicine/helpers/appInfo.dart';
import 'package:medicine/helpers/deviceDimensions.dart';
import 'package:medicine/helpers/iconHelper.dart';
import 'package:medicine/services/authService.dart';
import 'package:medicine/widgets/IconFont.dart';
import 'package:provider/provider.dart';

class EmailRegistration extends StatefulWidget {
  @override
  State<EmailRegistration> createState() => _EmailRegistrationState();
}

class _EmailRegistrationState extends State<EmailRegistration> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  bool isNewUser = false;
  bool isHiddenPW = true;
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final deviceDimensions = Provider.of<Dimension>(context);

    double height = deviceDimensions.getDeviceHeight();
    double width = deviceDimensions.getDeviceWidth();
    String header1 = "Sign In To Your Account";
    String header2 = "Register your account information";

    return Scaffold(
        // To remove 'Bottom Overflowed by....' error
        resizeToAvoidBottomInset: true,
        body: Container(
          color: Colors.black,
          width: width,
          height: height,
          child: Stack(children: [
            Positioned.fill(
                // use opacity to dim image
                child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/imgs/bg.jpg',
                // fit image across its allowed space
                fit: BoxFit.cover,
              ),
            )),
            Center(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(children: [
                  Center(
                    child: ClipOval(
                      child: Container(
                        width: width * 0.2,
                        height: height * 0.2,
                        color: AppInfo.MAIN_COLOR,
                        alignment: Alignment.center,

                        // use self created 'IconFont class' to get icon from specified font
                        child: IconFont(
                          color: Colors.white,
                          iconName: IConFontHelper.LOGO,
                          size: 0.14,
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(height: 40),
                  Padding(
                    padding: EdgeInsets.only(
                      top: height * 0.03,
                    ),
                    child: Text(
                      isNewUser ? header2 : header1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: height * 0.02,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.035,
                      right: width * 0.035,
                      top: height * 0.035,
                      bottom: height * 0.03,
                    ),
                    child: Visibility(
                      child: TextField(
                        controller: fullnameController,
                        cursorColor: AppInfo.ACCENT,
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(
                            Icons.person,
                            color: AppInfo.ACCENT,
                          ),
                          labelStyle: TextStyle(
                            fontSize: height * 0.02,
                            color: AppInfo.ACCENT,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                      ),
                      visible: isNewUser,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.035,
                      right: width * 0.035,
                      bottom: height * 0.03,
                    ),
                    child: TextField(
                      controller: emailController,
                      cursorColor: AppInfo.ACCENT,
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppInfo.ACCENT,
                        ),
                        labelStyle: TextStyle(
                          fontSize: height * 0.02,
                          color: AppInfo.ACCENT,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.035,
                      right: width * 0.035,
                      bottom: height * 0.03,
                    ),
                    child: TextField(
                      controller: passwordController,
                      cursorColor: AppInfo.ACCENT,
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(
                          Icons.password,
                          color: AppInfo.ACCENT,
                        ),
                        suffixIcon: IconButton(
                          icon: isHiddenPW
                              ? Icon(Icons.visibility_off)
                              : Icon(Icons.visibility),
                          onPressed: () {
                            setState(() {
                              isHiddenPW = !isHiddenPW;
                            });
                          },
                        ),
                        labelStyle: TextStyle(
                          fontSize: height * 0.02,
                          color: AppInfo.ACCENT,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      obscureText: isHiddenPW,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "New User : ",
                        style: TextStyle(
                          fontSize: width * 0.02,
                          fontWeight: FontWeight.bold,
                          letterSpacing: width * 0.0005,
                          color: AppInfo.ACCENT,
                        ),
                      ),
                      Switch(
                          activeColor: AppInfo.ACCENT,
                          activeTrackColor: AppInfo.MAIN_COLOR,
                          value: isNewUser,
                          onChanged: (newValue) {
                            setState(() {
                              isNewUser = newValue;
                            });
                          }),
                    ],
                  ),

                  // Button section
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        isNewUser
                            ? await authService.creatUserWithEmailAndPAssword(
                                emailController.text,
                                passwordController.text,
                                fullnameController.text)
                            : await authService.signInWithEmailAndPassword(
                                emailController.text, passwordController.text);

                        Navigator.pushReplacementNamed(context, '/wrapper');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: AppInfo.MAIN_COLOR,
                        onPrimary: AppInfo.ACCENT,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(width * 0.5)),
                        ),
                      ),
                      //add padding to provide space between text
                      //and button borders
                      child: Padding(
                        padding: EdgeInsets.all(height * 0.025),
                        child: Text(
                          isNewUser ? 'SIGN UP' : 'SIGN IN',
                          style: TextStyle(
                            color: AppInfo.ACCENT,
                            fontFamily: 'Roboto',
                            fontSize: height * 0.02,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //     // this is new
                  //     padding: EdgeInsets.only(
                  //         bottom: MediaQuery.of(context).viewInsets.bottom)),
                ]),
              ),
            )
          ]),
        ));
  }
}
