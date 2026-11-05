import 'package:flutter/material.dart';
import 'package:full_shopping_app_2/test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() {
    return LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  final _keyForm = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pref = SharedPreferencesAsync();
  @override
  void initState() {
    print("initState in LoginPage");
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    print("dispose in LoginPage");
    // TODO: implement dispose
    super.dispose();
  }

  void checkInput()  async{
    if (_keyForm.currentState!.validate()) {
      var username = _usernameController.text;
      var password = _passwordController.text;


      var realUsername = await _pref.getString("username");
      var realPassword = await _pref.getString("password");
      if (username == realUsername && password == realPassword) {
        Database.isLoggedIn = true;
        if(!mounted) return ;
        context.go("/home");
      } else {
        _usernameController.clear();
        _passwordController.clear();
        if(!mounted) return ;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("wrong info ")));
      }
    }
  }

  Future<void> _signup() async {
    var username = _usernameController.text ;
    var password = _passwordController.text ;
    await _pref.setString("username", username);
    await _pref.setString("password", password);
    if(!mounted) return ;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("signed up successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Form(
          key: _keyForm,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "please write correct username ";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "please write correct password";
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: checkInput,

                //     () {
                //   // context.go("/home");
                //   context.go("/home/products");
                // },
                child: Text(" login"),
              ),
              ElevatedButton(onPressed: _signup, child: Text("Sign up"))
            ],
          ),
        ),
      ),
    );
  }
}
