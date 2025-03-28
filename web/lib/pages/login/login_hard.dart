import 'package:flutter/material.dart';
import 'login_form.dart';

class LoginHard extends StatefulWidget {
  const LoginHard({
    super.key,
  });
  @override
  State<LoginHard> createState() => _LoginHardState();
}

class _LoginHardState extends State<LoginHard> {
  final buttonEnabled = ValueNotifier<bool>(false);
  final allEnabled = ValueNotifier<bool>(true);
  String login = '';
  String pass = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    buttonEnabled.dispose();
    allEnabled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoginForm(
      child1: SizedBox(
        width: 350,
        child: ValueListenableBuilder<bool>(
          valueListenable: allEnabled,
          builder: (context, isEnabled, child) => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 150),
              TextField(
                onChanged: (t) {
                  login = t;
                  buttonEnabled.value = login.isNotEmpty && pass.isNotEmpty;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    //borderRadius: BorderRadius.circular(radius)
                  ),
                  labelText: 'Логин',
                ),
                enabled: isEnabled,
              ),
              const SizedBox(height: 15),
              TextField(
                onChanged: (t) {
                  pass = t;
                  buttonEnabled.value = login.isNotEmpty && pass.isNotEmpty;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    //borderRadius: BorderRadius.circular(radius)
                  ),
                  labelText: 'Пароль',
                ),
                enabled: isEnabled,
              ),
              const SizedBox(height: 15),
              ValueListenableBuilder<bool>(
                valueListenable: buttonEnabled,
                builder: (context, isButtonEnabled, child) => ElevatedButton(
                  onPressed: isEnabled && isButtonEnabled
                      ? () async {
                          loading = true;
                          allEnabled.value = false;
                          await Future.delayed(const Duration(seconds: 5));
                          loading = false;
                          allEnabled.value = true;
                        }
                      : null,
                  child: loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.grey),
                        )
                      : const Text('Войти'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 40),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    //elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      //side: BorderSide(color: Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
