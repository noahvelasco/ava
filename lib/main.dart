import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
          scaffoldBackgroundColor:
          Palette.clrs.shade50,
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
  final player = AudioPlayer(); //for text to speech
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  bool _isLoadingResp = false; //progress indicator counter for gpt response
  bool _isLoadingVoice = false; //progress indicator counter for voice

  void _submitRequest() async {
    FocusManager.instance.primaryFocus
        ?.unfocus(); //dismiss keyboard immediately after request sent
    String input = _inputController.text;
    String output = await getResponseFromChatGPT(input);
    setState(() {
      _isLoadingResp = false; //progress indicator
      _outputController.text = output;
    });
  }

  void _playOutput() async {
    await playTextToSpeech(_outputController.text);

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

    //display the loading icon while we wait for request
    setState(() {
      _isLoadingVoice = true; //progress indicator
    });

    String apiKey = 'YOUR_API_KEY';
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
          "stability": .2,
          "similarity_boost": .8
        }

      }),
    );

    if (response.statusCode == 200) {

      final bytes = response.bodyBytes; //get the bytes ElevenLabs sent back
      await player.setAudioSource(MyCustomSource(bytes)); //send the bytes to be read from the JustAudio library
      player.play(); //play the audio
    } else {
      throw Exception('Failed to load audio');
    }
  } //getResponse from Eleven Labs

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
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 50),
            //   child: Image.asset(
            //     'assets/images/logo-no-background.png',
            //     fit: BoxFit.fitHeight,
            //     // set the fit property according to your needs
            //     height: 70,
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 50.0),
              child: TextFormField(
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
                      backgroundColor: Color(0xFF1a1a1a),
                      color: Palette.clrs,
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
                      borderSide: BorderSide(color: Palette.clrs),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Palette.clrs),
                    ),
                    labelText: 'Your Answer Here',
                    labelStyle: const TextStyle(color: Palette.clrs),
                    suffixIcon: IconButton(
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: _outputController.text));
                      },
                      icon: const Icon(Icons.copy),
                      color: Palette.clrs,
                    ),
                  ),
                  readOnly: true,
                  maxLines: null,
                  style: const TextStyle(color: Palette.clrs),
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
          onPressed: _playOutput ,
          child:    _isLoadingVoice
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

// Feed your own stream of bytes into the player - Taken from JustAudio package
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
