import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:provider/provider.dart';

import '../../config/env.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final bool _isDev = Env().config.env == 'DEV';

  late TextEditingController _otpController;
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      (_otpController as OTPTextEditController).stopListen();
    }
    _usernameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (defaultTargetPlatform == TargetPlatform.android) {
      _otpController =
          OTPTextEditController(
            codeLength: 5,
            onCodeReceive: (code) {
              FocusManager.instance.primaryFocus?.unfocus();
              context.read<AuthProvider>().login(
                context,
                _usernameController.text,
                code,
              );
            },
            otpInteractor: OTPInteractor(),
          )..startListenUserConsent((code) {
            final exp = RegExp(r'(\d{5})');
            return exp.stringMatch(code ?? '') ?? '';
          }, strategies: []);
    } else {
      _otpController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/login_bg.webp'),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const SizedBox(height: 40),
                    Image.asset('assets/logo.png', height: 60),
                    const SizedBox(height: 10),
                    Text(
                      'School Admin App',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Login',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a valid Mobile Number'
                          : null,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp('[^0-9]')),
                      ],
                      autofillHints: const <String>[
                        AutofillHints.telephoneNumber,
                      ],
                      maxLength: 10,
                      readOnly: provider.otpSent,
                      autofocus: true,
                      decoration: InputDecoration(
                        counterText: '',
                        prefixIcon: Icon(
                          Icons.call,
                          color: Theme.of(context).primaryColorDark,
                          size: 26,
                        ),
                        suffixIcon: !provider.otpSent
                            ? null
                            : IconButton(
                                onPressed: provider.resetOtpSent,
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                  size: 26,
                                ),
                              ),
                        hintText: 'Enter Mobile Number',
                        hintStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        if (!provider.otpSent && !_isDev)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                provider.sendLoginOtp(
                                  context,
                                  _usernameController.text,
                                );
                              },
                              child: const Text(
                                'Generate OTP',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        if (provider.otpSent || _isDev)
                          Expanded(
                            child: TextFormField(
                              autofocus: true,
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 5,
                              validator: (value) =>
                                  (provider.otpSent || _isDev) &&
                                      (value == null || value.isEmpty)
                                  ? 'Please enter OTP'
                                  : null,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                  RegExp('[^0-9]'),
                                ),
                              ],
                              autofillHints: const <String>[
                                AutofillHints.oneTimeCode,
                              ],
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: 'Enter OTP',
                                counterText: '',
                                hintStyle: TextStyle(fontSize: 18),
                                fillColor: Colors.white,
                                filled: true,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    if (provider.otpSent || _isDev)
                      ElevatedButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (_formKey.currentState!.validate()) {
                            provider.login(
                              context,
                              _usernameController.text,
                              _otpController.text,
                            );
                          }
                        },
                        child: const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
