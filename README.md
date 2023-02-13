# A.V.A - Advanced Virtual Agent

*AVA* stands for ***advanced virtual agent*** and is meant to help anyone with quick/on-tap knowledge handling. Created by Noah Velasco, AVA started as a personal project and will continue to be supported in hopes of one day including it in headphone support like Amazon Alexa or Google Assistant (perhaps even AR). This repository can be used by anyone however requires an API anyone can generate from OpenAI for free. The goal is to create a plug and play virtual agent that anyone can use with minor constraints such including a female voice and the overall UI/UX experience.

***Note: This entire application was built with ChatGPT aswell as built for Chat GPT Utility and will continue being built with that principle in mind.***

## How to use
1. Go to OpenAI and generate a API Key
2. Download this repository
3. Insert API key where it tells you to in the code (lib/main.dart)
4. Run the Program :)

## Features & Goals
1. Basic input and output
2. Text-To-Speech (using ElevenLabs API)
3. Graphics showing human visual assistant
4. The ability to converse with assistant like Amazon Alexa
5. Selection of Voice Assistant - can choose male or female and their variations.


## Build Info
* Built and tested with Android Studio
* Flutter 3.7.3
*  Dart 2.19.2
* DevTools 2.20.1


## Possible Issues
### Android
* Enable Developer Mode on your phone

### iOS
*  Enable internet connection so API can fetch the POST requests. Since this was built with Android in mind, I don't care to much for iOS for now. Look for the equivalent AndroidManifest.xml file. 