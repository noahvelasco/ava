import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'elevenlabs_utils.dart';
import 'package:just_audio/just_audio.dart';
import 'palette.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVA',
      theme: ThemeData(
        primarySwatch: Palette.clrs,
        scaffoldBackgroundColor: Palette.clrs.shade50,
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
  var chatHistory = [
    {"role": "system", "content": "You are a helpful assistant named ava."}
  ]; //this array or chat history will grow as the conersation prolongs to remember the chat history for chatgpt to recall

  final player = AudioPlayer(); //for text to speech
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  bool _isLoadingResp = false; //progress indicator counter for gpt response
  bool _isLoadingVoice = false; //progress indicator counter for voice
  final FocusNode _focusNode = FocusNode();

  //submits request to the chatgpt api
  void _submitRequest() async {
    FocusManager.instance.primaryFocus
        ?.unfocus(); //dismiss keyboard immediately after request sent
    String input = _inputController.text;
    chatHistory.add({
      "role": "user",
      "content": _inputController.text
    }); //add the users input to the chat history

    String output = await getResponseFromChatGPT(input);
    setState(() {
      _isLoadingResp = false; //progress indicator
      _outputController.text = output;
    });
  }

  //
  void _playOutput() async {
    await playTextToSpeech(_outputController.text.isEmpty
        ? "My name is Ava. How can I assist you?" // This is the initial message before the user has sent any message
        : _outputController.text);

    setState(() {
      _isLoadingVoice = false;
    });
  }

  Future<String> getResponseFromChatGPT(String input) async {
    //display the loading icon while we wait for request
    setState(() {
      _isLoadingResp = true; //progress indicator
      _outputController.text = '';
    });

    // String apiKey = 'YOUR API KEY HERE';
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    Map<String, dynamic> requestBody = {
      "model": "gpt-3.5-turbo",
      "messages":
          chatHistory, //chatHistory contains the history of the entire chat
      "temperature": .7, //TODO
      "max_tokens": 200, //TODO
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(requestBody),
      );

      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = json.decode(response.body);
        String answer = responseJson['choices'][0]['message']
            ['content']; //extract the message from the response

        chatHistory.add({
          "role": "assistant",
          "content": answer
        }); //add the AI chat response to the history

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
    //display the loading icon while we wait for request
    setState(() {
      _isLoadingVoice = true; //progress indicator
    });

    // String apiKey = 'YOUR_API_KEY';
    String url =
        'https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'accept': 'audio/mpeg',
        'xi-api-key': apiKey,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "text": text,
        "voice_settings": {"stability": .3, "similarity_boost": .3}
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(
          bytes)); //send the bytes to be read from the JustAudio library
      player.play(); //play the audio
    } else {
      throw Exception('Failed to load audio');
    }
  } //getResponse from Eleven Labs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // AppBar(title: const Text('AVA'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 00, 0, 50),
              // child: SingleChildScrollView(
              // child:
              // TextFormField(
              //   controller: _outputController,
              //   decoration: InputDecoration(
              //     border: const OutlineInputBorder(),
              //     enabledBorder: const OutlineInputBorder(
              //       borderSide: BorderSide(color: Palette.clrs),
              //     ),
              //     focusedBorder: const OutlineInputBorder(
              //       borderSide: BorderSide(color: Palette.clrs),
              //     ),
              //     labelText: 'Your Answer Here',
              //     labelStyle: const TextStyle(color: Palette.clrs),
              //     suffixIcon: IconButton(
              //       onPressed: () async {
              //         await Clipboard.setData(
              //             ClipboardData(text: _outputController.text));

              //         // Show a snackbar when the button is pressed
              //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //           content: const Text('Copied to Clipboard!',
              //               style: TextStyle(color: Color(0xFF1a1a1a))),
              //           dismissDirection: DismissDirection.horizontal,
              //           shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(10.0)),
              //           backgroundColor: Palette.clrs,
              //           duration: const Duration(seconds: 1),
              //         ));
              //       },
              //       icon: const Icon(Icons.copy),
              //       color: Palette.clrs,
              //     ),
              //   ),
              //   readOnly: true,
              //   maxLines: null,
              //   style: const TextStyle(color: Palette.clrs),
              // ),
              //),

              child: Container(
                height: 150,
                // margin: const EdgeInsets.only(bottom: 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF424d55),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF424d55),
                      blurRadius: 10.0,
                      offset: Offset(0.0, 5.0),
                    )
                  ],
                ),

                //Scroll through the text thats in the box with the Single Child Scroll View
                child: SingleChildScrollView(
                  child: Text(
                    _outputController.text.isEmpty
                        ? "My name is Ava. How can I assist you?" //This is the initial message before any messages are sent by user
                        : _outputController.text,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _submitRequest,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(35.0),
                foregroundColor: Palette.clrs,
                backgroundColor: Palette.clrs.shade50,
                hoverColor: Palette.clrs.withOpacity(0.50),
                highlightColor: Palette.clrs.withOpacity(0.30),
                side: const BorderSide(width: 2, color: Palette.clrs),
              ),
              child: const Icon(Icons.send),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: _isLoadingResp
                  ? const CircularProgressIndicator(
                      backgroundColor: Color(0xFF424d55),
                      color: Palette.clrs,
                      // strokeWidth: 5,
                    )
                  : null,
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                child: TextFormField(
                  focusNode: _focusNode,
                  controller: _inputController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Palette.clrs),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Palette.clrs),
                    ),
                    labelText: 'Enter any question here...',
                    labelStyle: const TextStyle(color: Palette.clrs),
                    suffixIcon: IconButton(
                      onPressed: _inputController.clear,
                      icon: const Icon(Icons.clear),
                      color: Palette.clrs,
                    ),
                  ),
                  style: const TextStyle(color: Palette.clrs),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 3,
                ),
              ),
            ),
          ],
        ),
      ), //body
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          hoverColor: Colors.green.withOpacity(0.90),
          foregroundColor: Palette.clrs.shade50,
          backgroundColor: Palette.clrs,
          onPressed: _playOutput,
          child: _isLoadingVoice
              ? const CircularProgressIndicator(
                  backgroundColor: Color(0xFF1a1a1a),
                  color: Palette.clrs,
                  strokeWidth: 5,
                )
              : const Icon(Icons.volume_up),
        ),
      ),
    );
  }
} //class chatgptpage state
