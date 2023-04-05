import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:animate_gradient/animate_gradient.dart';
import 'package:google_fonts/google_fonts.dart';

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
        useMaterial3: true,
        primaryColor:
            Colors.white, // scaffoldBackgroundColor: Colors.transparent,
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

  double _gptTemperature =
      0.7; //the higher the more creative - the lower the more boring and precise
  double voiceStability = 0.15; //the lower the more emotional/less monotone
  double voiceClarity = 0.75; //the higher the more clear

  //submits request to the chatgpt api
  void _submitRequest() async {
    //set the output container back to its original state => unpressed look
    Timer(const Duration(milliseconds: 250), () {
      setState(() {
        isPressedIn = false;
      });
    });

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

    String apiKey = 'YOUR_API_KEY';
    String apiUrl = 'https://api.openai.com/v1/chat/completions';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    Map<String, dynamic> requestBody = {
      "model": "gpt-3.5-turbo",
      "messages":
          chatHistory, //chatHistory contains the history of the entire chat
      "temperature": _gptTemperature, //TODO
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

    String apiKey = "YOUR_API_KEY";
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
        "voice_settings": {
          "stability": voiceStability,
          "similarity_boost": voiceClarity
        }
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(
          bytes)); //send the bytes to be read from the JustAudio library
      player.play(); //play the audio
    } else {
      // throw Exception('Failed to load audio');
      return;
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
      showCloseIcon: true,
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
    Timer(const Duration(milliseconds: 300), () {
      setState(() {
        isPressedIn = false;
      });
    });

    _submitRequest();
  }

  @override
  Widget build(BuildContext context) {
    //Lock the app into portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
      body: Stack(children: [
        AnimateGradient(
          primaryBegin: Alignment.topLeft,
          primaryEnd: Alignment.topRight,
          secondaryBegin: Alignment.bottomCenter,
          secondaryEnd: Alignment.bottomLeft,
          duration: const Duration(seconds: 4),
          primaryColors: const [
            Color(0xFFE9A495),
            Colors.white,
          ],
          secondaryColors: const [
            Colors.white,
            Color(0xFFE9A495),
          ],
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: GestureDetector(
                  onTap: _changeStateOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 150,
                    width: 350,
                    padding: const EdgeInsets.only(
                        left: 20, top: 5, bottom: 5, right: 0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: blurOut,
                            offset: distOut,
                            color: const Color.fromARGB(255, 100, 100, 100),
                            inset: isPressedOut),
                      ],
                    ),

                    //Scroll through the text thats in the box with the Single Child Scroll View
                    child: Scrollbar(
                      thumbVisibility: true,
                      thickness: 5.0,
                      child: SingleChildScrollView(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            _outputController.text.isEmpty
                                ? "My name is Ava. How can I assist you?" //This is the initial message before any messages are sent by user
                                : _outputController.text,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          )),
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'TAP TO COPY',
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
                child: _isLoadingResp
                    ? const LinearProgressIndicator(
                        backgroundColor: Colors.white,
                        color: Color(0xFFE9A495),
                      )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: GestureDetector(
                  onTap: _changeStateIn,
                  onLongPress: _inputController.clear,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: 150,
                    width: 350,
                    padding: const EdgeInsets.only(
                        left: 20, top: 20, bottom: 50, right: 50),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: blurIn,
                            offset: distIn,
                            color: const Color.fromARGB(255, 100, 100, 100),
                            inset: isPressedIn),
                      ],
                    ),
                    child: TextField(
                      cursorColor: Colors.black,
                      cursorWidth: 1,
                      cursorRadius: const Radius.circular(5),
                      focusNode: _focusNode,
                      controller: _inputController,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Enter any question here...',
                      ),
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                      ),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 20.0),
                  child: Text(
                    'TAP TO ASK\n\nHOLD TO CLEAR\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                          color: Color(0xFFE9A495), strokeAlign: 5, width: 2.5),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(50)),
                    ),
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.only(top: 20.0),
                        height: 500.0,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 15),
                              child: Image(
                                image: AssetImage(
                                    'assets/images/logo-no-background.png'), // Replace this with the path to your image file
                                width: 400.0, // Set the width of the image
                              ),
                            ),
                            const Text(
                                "GPT Temperature (Higher = More Creative)"),
                            StatefulBuilder(builder: (context, setState) {
                              return Slider(
                                activeColor: const Color(
                                    0xFFE9A495), // set the active color
                                inactiveColor:
                                    Colors.grey, // set the inactive color
                                divisions: 20,
                                value: _gptTemperature,
                                label: _gptTemperature.toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    _gptTemperature = value;
                                  });
                                },
                                min: 0.0,
                                max: 1.0,
                              );
                            }),
                            const Text(
                                "Voice Stability (Lower = More Expressive)"),
                            StatefulBuilder(builder: (context, setState) {
                              return Slider(
                                activeColor: const Color(
                                    0xFFE9A495), // set the active color
                                inactiveColor:
                                    Colors.grey, // set the inactive color
                                divisions: 20,
                                value: voiceStability,
                                label: voiceStability.toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    voiceStability = value;
                                  });
                                },
                                min: 0.0,
                                max: 1.0,
                              );
                            }),
                            const Text("Voice Clarity (Higher = More Clear)"),
                            StatefulBuilder(builder: (context, setState) {
                              return Slider(
                                activeColor: const Color(
                                    0xFFE9A495), // set the active color
                                inactiveColor:
                                    Colors.grey, // set the inactive color
                                divisions: 20,
                                value: voiceClarity,
                                label: voiceClarity.toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    voiceClarity = value;
                                  });
                                },
                                min: 0.0,
                                max: 1.0,
                              );
                            }),
                            const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Created by Noah Velasco & ChatGPT, 2023",
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                          fontStyle: FontStyle.italic),
                                    )))
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ]),

      //body
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          elevation: 30.0,
          hoverColor:
              const Color.fromARGB(255, 255, 255, 255).withOpacity(0.90),
          foregroundColor: Palette.clrs,
          backgroundColor: Palette.clrs.shade50,
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
