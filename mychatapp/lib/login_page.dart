import 'package:flutter/material.dart';
import 'package:mychatapp/auth_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
class  LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProviderr>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            TextFormField( 
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please Enter Email";
                  }
                  return null;
                }),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
                controller: _passController,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please Enter Password";
                  }
                  return null;
                }),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await authProvider.signIn(
                        _emailController.text, _passController.text);
                          Fluttertoast.showToast(msg:"Login success");

                    Navigator.pushNamed(context, "/HomeScreen");
                  } catch (e) {
                    print(e);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white),
                child: const Text("Login"),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text("OR"),
            const SizedBox(
              height: 20,
            ),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/SignUpScreen");
                },
                child: const Text("Create Account" , style: TextStyle(color: Colors.blue),))
          ],
        ),
      ),
    );
  }
}
