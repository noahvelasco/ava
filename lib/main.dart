import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVA',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF737373),
      ),
      debugShowCheckedModeBanner: false,

      home: const ChatGPTPage(),
    );
  }
}

class ChatGPTPage extends StatefulWidget {
  const ChatGPTPage({super.key});

  @override
  _ChatGPTPageState createState() => _ChatGPTPageState();
}

class _ChatGPTPageState extends State<ChatGPTPage> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();

  void _submitRequest() async {
    String input = _inputController.text;
    String output = await getResponseFromChatGPT(input);

    setState(() {
      _outputController.text = output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AVA'),
        centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                hintText: 'Enter your request here',
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitRequest,
              child: const Text('Submit Request'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: TextField(
                  controller: _outputController,
                  decoration: const InputDecoration(
                    hintText: 'ChatGPT response will appear here',
                  ),
                  readOnly: true,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<String> getResponseFromChatGPT(String input) async {
  String apiUrl = 'https://api.openai.com/v1/completions';
  String apiKey = 'YOUR API KEY HERE';
  // String apiKey = ''; //CHANGE THIS KEY IF YOU ARE FORKING THIS

  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  Map<String, dynamic> requestBody = {
    "model": "text-davinci-003",
    "prompt": input,
    "temperature": 0,
    "max_tokens": 100,
  };

  try {
    http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: json.encode(requestBody),
    );

    print("<>>>>>>>>>>>>>>>>>>>>>>>>> ${response.body} <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");

    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      return responseJson['choices'][0]['text'];
    } else {
      return 'Request failed with status code: ${response.statusCode}';
    }
  } catch (e) {
    return 'Request failed with error: $e';
  }
}