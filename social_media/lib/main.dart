import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const MyHomePage(title: 'Dio Example'));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? value;

  final _dio = Dio(
    BaseOptions(
      baseUrl: "https://dummyjson.com",
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  Future<void> _getAllData() async {
    try {
      var response = await _dio.get("/posts", queryParameters: {"skip": 10});
      setState(() {
        value =
            ((response.data as Map<String, dynamic>)["posts"]
                as List)[0]["title"];
      });
    } on DioException catch (e) {
      setState(() {
        value = _handleError(e);
      });
    }
  }

  Future<void> _postNewData() async {
    try {
      var response = await _dio.post(
        "/posts/add",
        data: {"userId": 4, "username": "x", "password": "y"},
      );
      setState(() {
        value = "${response.statusCode} , ${response.data}";
      });
    } on DioException catch (e) {
      setState(() {
        value = _handleError(e);
      });
    }
  }

  Future<void> _deleteData() async {
    try {
      var response = await _dio.delete("/posts/1");
      setState(() {
        value = "${response.statusCode} , ${response.data}";
      });
    } on DioException catch (e) {
      setState(() {
        value = _handleError(e);
      });
    }
  }

  Future<void> _putData() async {
    try {
      var response = await _dio.put(
        "/posts/1",
        data: {"title": "new title", "body": "new body", "userId": 4},
      );
      setState(() {
        value = "${response.statusCode} , ${response.data}";
      });
    } on DioException catch (e) {
      setState(() {
        value = _handleError(e);
      });
    }
  }

  Future<void> _patchData() async {
    try {
      var response = await _dio.patch("/posts/1", data: {"title": "new title"});
      setState(() {
        value = "${response.statusCode} , ${response.data}";
      });
    } on DioException catch (e) {
      setState(() {
        value = _handleError(e);
      });
    }
  }

  String _handleError(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return "Request timed out, try again";
        case DioExceptionType.connectionError:
          return "No internet connection";
        case DioExceptionType.badCertificate:
          return "Security error (bad certificate)";
        case DioExceptionType.cancel:
          return "Request cancelled";
        case DioExceptionType.badResponse:
          return "wrong info";
        case DioExceptionType.unknown:
          return "Unexpected network error";
      }
    }
    return "Something went wrong";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: _getAllData, child: Text("refresh")),
            ElevatedButton(
              onPressed: _postNewData,
              child: Text("Post new data"),
            ),
            ElevatedButton(onPressed: _putData, child: Text("Put data")),
            ElevatedButton(onPressed: _patchData, child: Text("Patch data")),
            ElevatedButton(onPressed: _deleteData, child: Text("Delete data")),
            Text(value ?? "info"),
          ],
        ),
      ),
    );
  }
}
