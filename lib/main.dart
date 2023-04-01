import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';

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
        "voice_settings": {"stability": .15, "similarity_boost": .75}
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

  /*
  ----------------- UI/UX constants/functions for output box
  */
  bool isPressedOut = false; //original state of the output button
  bool isPressedIn = false; //original state of the input button

  //Output Container State Handling
  void _changeStateOut() {
    setState(() {
      isPressedOut = true;
    });

    //set the output container back to its original state => unpressed look
    Timer(const Duration(milliseconds: 250), () {
      setState(() {
        isPressedOut = false;
      });
    });

    /*
      After clicking on the output - the output will be stored to the clipboard
    */
    Clipboard.setData(ClipboardData(
        text: _outputController.text.isEmpty
            ? "My name is Ava. How can I assist you?" //This is the initial message before any messages are sent by user
            : _outputController.text));

    // Show a snackbar when the button is pressed
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Copied to Clipboard!',
          style: TextStyle(color: Color(0xFFFFFFFF))),
      dismissDirection: DismissDirection.horizontal,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20.0),
      )),
      backgroundColor: Palette.clrs,
      duration: Duration(seconds: 3),
      elevation: 10,
    ));
  }

  //Input Container State Handling
  void _changeStateIn() {
    setState(() {
      isPressedIn = true;
    });

    //set the input container back to its original state => unpressed look
    Timer(const Duration(milliseconds: 250), () {
      setState(() {
        isPressedIn = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
  ----------------- UI/UX Constants for widgets below:
  */

    //for the outputbox
    Offset distOut = isPressedOut ? const Offset(10, 10) : const Offset(28, 28);
    double blurOut = isPressedOut ? 5.0 : 30.0;

    //for the input box
    Offset distIn = isPressedIn ? const Offset(10, 10) : const Offset(28, 28);
    double blurIn = isPressedIn ? 5.0 : 30.0;

    return Scaffold(
      appBar: null, // AppBar(title: const Text('AVA'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
              child: GestureDetector(
                onTap: _changeStateOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 150,
                  width: 350,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 50),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: blurOut,
                          offset: -distOut,
                          color: Colors.white,
                          inset: isPressedOut),
                      BoxShadow(
                          blurRadius: blurOut,
                          offset: distOut,
                          color: const Color(0xFFA7A9AF),
                          inset: isPressedOut),
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
                          color: Colors.black,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
              ),
            ),
            // ElevatedButton(
            //   onPressed: _submitRequest,
            //   style: IconButton.styleFrom(
            //     padding: const EdgeInsets.all(35.0),
            //     foregroundColor: Palette.clrs,
            //     backgroundColor: Palette.clrs.shade50,
            //     hoverColor: Palette.clrs.withOpacity(0.50),
            //     highlightColor: Palette.clrs.withOpacity(0.30),
            //     side: const BorderSide(width: 2, color: Palette.clrs),
            //   ),
            //   child: const Icon(Icons.send),
            // ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 50.0),
              height: 1.0,
              color: Palette.clrs,
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: _isLoadingResp
                  ? const CircularProgressIndicator(
                      backgroundColor: Color(0xFF424d55),
                      color: Color(0xFFe8dbce),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: GestureDetector(
                onTap: _submitRequest, // add 'changestatein'
                onLongPress: _inputController.clear,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 150,
                  width: 350,
                  padding: const EdgeInsets.only(
                      left: 20, top: 20, bottom: 50, right: 50),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: blurIn,
                          offset: -distIn,
                          color: Colors.white,
                          inset: isPressedIn),
                      BoxShadow(
                          blurRadius: blurIn,
                          offset: distIn,
                          color: const Color(0xFFA7A9AF),
                          inset: isPressedIn),
                    ],
                  ),

                  // padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _inputController,
                    decoration: const InputDecoration.collapsed(
                      // border: const OutlineInputBorder(),
                      // enabledBorder: const OutlineInputBorder(
                      //   borderSide: BorderSide(color: Palette.clrs),
                      // ),
                      // focusedBorder: const OutlineInputBorder(
                      //   borderSide: BorderSide(color: Palette.clrs),
                      // ),
                      hintText: ' Enter any question here...',
                      // labelStyle: const TextStyle(color: Palette.clrs),
                      // suffixIcon: IconButton(
                      //   onPressed: _inputController.clear,
                      //   icon: const Icon(Icons.clear),
                      //   color: Palette.clrs,
                      // ),
                    ),
                    style: const TextStyle(color: Palette.clrs),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 3,
                  ),
                ),
              ),
            )
          ],
        ),
      ), //body
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          hoverColor:
              const Color.fromARGB(255, 255, 255, 255).withOpacity(0.90),
          foregroundColor: Palette.clrs.shade50,
          backgroundColor: Palette.clrs,
          onPressed: _playOutput,
          child: _isLoadingVoice
              ? const CircularProgressIndicator(
                  backgroundColor: Color(0xFFFFFFFF),
                  color: Palette.clrs,
                  strokeWidth: 5,
                )
              : const Icon(Icons.volume_up),
        ),
      ),
    );
  }
} //class chatgptpage state
