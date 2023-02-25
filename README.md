![image info](./assets/images/logo-no-background.png)

# A.V.A - Advanced Virtual Agent

*AVA* stands for ***advanced virtual agent*** and is meant to help anyone with quick/on-tap question handling. Created by Noah Velasco, AVA started as a personal project and will continue to be supported in hopes of one day conversing with it like Amazon Alexa or Google Assistant (perhaps even AR). This repository can be used by anyone however requires an API key anyone can generate for free from OpenAI and Eleven Labs for free. The goal is to create a plug and play virtual agent that anyone can use with minor constraints such as the overall UI/UX experience.

***Note: This entire application was built with ChatGPT and built for ChatGPT utility and will continue being built with that principle in mind.***

## Features & Goals
1. Basic input and output - DONE
2. Text-To-Speech (using ElevenLabs API) - DONE
3. Microphone capabilities - TODO
4. Graphics showing human visual assistant  - TODO
5. The ability to converse with assistant like Amazon Alexa  - TODO
6. Selection of Voice Assistant - can choose male or female and their variations. - TODO

## How to use
1. Go to OpenAI and generate an API Key (Free - only needs account creation)
2. Go to ElevenLabs, create an account, and get your API key (Free - only needs account creation)
3. Download this repository
4. Insert API keys where it tells you to in the code (lib/main.dart)
5. Run the Program :)

## Build Info
* Built and tested with Android Studio
* Flutter 3.7.3
* Dart 2.19.2
* DevTools 2.20.1

## Possible Issues
### Android
* Enable Developer Mode on your phone

### iOS
*  Enable internet connection so API can fetch the POST requests. Since this was built with Android in mind, I don't care to much for iOS for now. Look for the equivalent AndroidManifest.xml file. 
