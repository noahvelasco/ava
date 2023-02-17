import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A.V.A',
      theme: ThemeData(
          primarySwatch: Colors.purple,
          scaffoldBackgroundColor: Colors.white // const Color(0xFF000000),
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
  bool _isLoading = false; //for progress indicator

  void _submitRequest() async {
    FocusManager.instance.primaryFocus
        ?.unfocus(); //dismiss keyboard immediately after request sent
    String input = _inputController.text;
    String output = await getResponseFromChatGPT(input);
    setState(() {
      _isLoading = false; //progress indicator
      _outputController.text = output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('AVA'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 80.0),
              child: TextFormField(
                controller: _inputController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Enter your question here',
                  suffixIcon: IconButton(
                    onPressed: _inputController.clear,
                    icon: const Icon(Icons.clear),
                  ),
                ),
                style: const TextStyle(color: Color(0xFF000000)),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 3,
              ),
            ),
            ElevatedButton(
              onPressed: _submitRequest,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(35.0),
                foregroundColor: Colors.green,
                //colors.onSecondaryContainer,
                backgroundColor: Colors.white,
                //colors.secondaryContainer,
                hoverColor: Colors.green.withOpacity(0.50),
                //colors.onSecondaryContainer.withOpacity(0.50),
                highlightColor: Colors.green.withOpacity(0.30),
                //colors.onSecondaryContainer.withOpacity(0.12),
                side: const BorderSide(width: 2, color: Colors.green),
              ),
              child: const Icon(Icons.send),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      backgroundColor: Colors.purple,
                      color: Colors.green,
                      strokeWidth: 5,
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 60, 0, 0),
              child: SingleChildScrollView(
                child: TextFormField(
                  controller: _outputController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'AVA\'s Answer',
                    suffixIcon: IconButton(
                      onPressed: _outputController.clear,
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                  readOnly: true,
                  maxLines: null,
                  style: const TextStyle(color: Color(0xFF000000)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> getResponseFromChatGPT(String input) async {
    //display the loading screen while we wait for request
    setState(() {
      _isLoading = true; //progress indicator
      _outputController.text = '';
    });

    String apiUrl = 'https://api.openai.com/v1/completions';
    String apiKey = 'YOUR API KEY HERE';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    //ChatGPT's params can be modified here
    Map<String, dynamic> requestBody = {
      "model": "text-davinci-003",
      "prompt": input,
      "temperature": .5,
      "max_tokens": 100,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(requestBody),
      );

      print(
          "<>>>>>>>>>>>>>>>>>>>>>>>>>\n "
              "${response.body}"
              "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");

      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = json.decode(response.body);
        String answer = responseJson['choices'][0]['text'];
        answer = answer.substring(
            2); // removed the newline characters from beginning of response
        return answer;
      } else {
        return 'Request failed with status code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Request failed with error: $e';
    }
  } //get response from chatgpt future function
} //class chatgptpage state
