/*
       Color palette

-------- lighter nude
Hex: E9A495
RGB:(233,164,149)

-------- grey/blue
Hex: 424d55
rgb(66, 77, 85)

-------- lighter nude
HEX: e8dbce
rgb(232, 219, 206)

 */
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

// import 'package:audioplayers/audio_cache.dart';
import 'palette.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVA',
      theme: ThemeData(
          primarySwatch: Palette.maincolors, //Palette.nude,
          scaffoldBackgroundColor:
              Palette.maincolors.shade50 // const Color(0xFF000000),
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

  void _playOutput() async {
    await playTextToSpeech(_outputController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: null, // AppBar(title: const Text('AVA'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Image.asset(
                'assets/images/logo-no-background.png',
                fit: BoxFit.fitHeight,
                // set the fit property according to your needs
                height: 70,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50.0),
              child: TextFormField(
                controller: _inputController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF424d55)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF424d55)),
                  ),
                  labelText: 'Enter any question here...',
                  labelStyle: const TextStyle(color: Color(0xFF424d55)),
                  suffixIcon: IconButton(
                    onPressed: _inputController.clear,
                    icon: const Icon(Icons.clear),
                    color: Palette.maincolors.shade100,
                  ),
                ),
                style: const TextStyle(color: Color(0xFF424d55)),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 3,
              ),
            ),
            ElevatedButton(
              onPressed: _submitRequest,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(35.0),
                foregroundColor: Palette.maincolors.shade100,
                backgroundColor: Palette.maincolors,
                hoverColor: Colors.green.withOpacity(0.50),
                highlightColor: Colors.green.withOpacity(0.30),
                side: const BorderSide(width: 2, color: Color(0xFF424d55)),
              ),
              child: const Icon(Icons.send),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      backgroundColor: Color(0xFF424d55),
                      color: Color(0xFFE9A495),
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
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF424d55)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF424d55)),
                    ),
                    labelText: 'The answer is 42...jk',
                    labelStyle: const TextStyle(color: Color(0xFF424d55)),
                    suffixIcon: IconButton(
                      onPressed: _outputController.clear,
                      icon: const Icon(Icons.clear),
                      color: Palette.maincolors.shade100,
                    ),
                  ),
                  readOnly: true,
                  maxLines: null,
                  style: const TextStyle(color: Color(0xFF000000)),
                ),
              ),
            ),

            // FloatingActionButton(

            //     onPressed: playTextToSpeech(_outputController.text),
            //     child: Icon(Icons.volume_up),
            // )
          ],
        ),
      ), //body
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          foregroundColor: const Color(0xFF000000),
          backgroundColor: const Color(0xFFE9A495),
          onPressed: _playOutput ,
          child: const Icon(Icons.volume_up),
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

    String apiKey = 'YOUR API KEY HERE';
    String apiUrl = 'https://api.openai.com/v1/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    //ChatGPT's params can be modified here
    Map<String, dynamic> requestBody = {
      "model": "text-davinci-003",
      "prompt": input,
      "temperature": .5,
      "max_tokens": 200,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(requestBody),
      );

      print("<>>>>>>>>>>>>>>>>>>>>>>>>>\n "
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

  //For the Text To Speech
  Future<void> playTextToSpeech(String text) async {
    String apiKey = 'YOUR_API_KEY';
    String url =
        'https://api.eleven-labs.com/api/tts/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        'text': text,
        "voice_settings": {
          "stability": 20,
          "similarity_boost": 80
        }
        // 'voice': 'en-US',
        // 'audio_format': 'mp3',
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/audio.mp3');
      await tempFile.writeAsBytes(bytes);

      final audioPlayer = AudioPlayer();
      await audioPlayer.play(tempFile.path as Source);
    } else {
      throw Exception('Failed to load audio');
    }
  } //getResponse from Eleven Labs
} //class chatgptpage state
