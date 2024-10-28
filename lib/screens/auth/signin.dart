import 'package:blackgps/components/CustomButton.dart';
import 'package:blackgps/components/CustomTextField.dart';
import 'package:blackgps/constants/colors.dart';
import 'package:blackgps/providers/authProviders.dart';
import 'package:blackgps/providers/commonProviders.dart';
import 'package:blackgps/providers/homeProviders.dart';
import 'package:blackgps/providers/settingsProviders.dart';
import 'package:blackgps/utils/ApiService.dart';
import 'package:blackgps/utils/TokenManagement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:go_router/go_router.dart';

class Signin extends ConsumerStatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends ConsumerState<Signin> {
  final emailControllerProvider =
      Provider<TextEditingController>((ref) => TextEditingController());
  final passwordControllerProvider =
      Provider<TextEditingController>((ref) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final loading = ref.watch(loadingProvider);

    void signin() async {
      startLoading(ref);

      final apiService = ApiService();
      try {
        final response = await apiService.post('api/token/', data: {
          'email': emailController.text,
          'password': passwordController.text,
        }, headers: {
          'Content-Type': 'application/json'
        });

        if (response['access'] != null) {
          var tokenStorage = TokenStorage();
          await tokenStorage.saveTokens(
              accessToken: response['access'],
              refreshToken: response['refresh']);

          ref
              .read(loginStateProvider.notifier)
              .login(); // Update the login state
          final isLogged = ref.read(loginStateProvider);
          if (!isLogged) {
            ref.read(fetchCarsFutureProvider);
            ref.read(fetchUserProvider);
          }
          context.pushReplacement("/home");
        } else {
          print("error");
        }

        stopLoading(ref);
      } catch (e) {
        print('Error: $e');
        stopLoading(ref);
        showToast("Incorrect Email or Password",
            context: context,
            backgroundColor: Color.fromARGB(255, 237, 6, 6),
            duration: Duration(seconds: 3),
            position: StyledToastPosition.top);
      }
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SingleChildScrollView(
            child: Container(
          height: screenHeight,
          color: CustomColors.whiteColor,
          child: Center(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (loading)
                  Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight / 2,
                      ),
                      Container(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  )),
                if (!loading)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Image.asset('assets/logo.png'),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 40, 0, 5),
                              child: Text(
                                'Email Address',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: CustomColors.textColor),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 5, 0, 0),
                              child: CustomTextField(
                                  width: screenWidth - 60,
                                  height: 50,
                                  placeholder: "example@gmail.com",
                                  controller: emailController),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 40, 0, 5),
                              child: Text(
                                'Password',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: CustomColors.textColor),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(20, 5, 0, 60),
                              child: CustomTextField(
                                  width: screenWidth - 60,
                                  height: 50,
                                  isPassword: true,
                                  placeholder: "Enter password",
                                  controller: passwordController),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              label: "Sign In",
                              colorBackground: CustomColors.blueSecondaryColor,
                              textColor: CustomColors.whiteColor,
                              textSize: 16,
                              width: screenWidth - 80,
                              onPressedClick: signin,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
