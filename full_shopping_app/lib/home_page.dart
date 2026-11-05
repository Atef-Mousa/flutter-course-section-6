import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    print("initState in HomePage");
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    print("dispose in HomePage");
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text("welcome to Home"),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: Text("return back"),
            ),
            ElevatedButton(onPressed: (){
              context.go("/home/products");
            }, child: Text("go to products"))
          ],
        ),
      ),
    );
  }
}
