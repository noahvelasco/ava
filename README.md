![image info](./assets/images/logo-no-background.png)

# A.V.A - Advanced Virtual Agent

*AVA* stands for ***advanced virtual agent*** and is meant to help anyone with quick/on-tap question handling. Created by Noah Velasco, AVA started as a personal project and will continue to be supported in hopes of one day conversing with it like another human. This repository can be used by anyone however requires API key's anyone can generate for free from OpenAI and ElevenLabs. The goal is to create a plug and play virtual agent that anyone can use with minor constraints such as the overall UI/UX experience.

***Note: This entire application was built with ChatGPT and built for ChatGPT utility and will continue being built with that principle in mind.***

## Features & Goals
1. Basic I/O - DONE
2. Text-To-Speech (using ElevenLabs API) - DONE
3. Speech-To-Text (using OpenAI Whisper) - TODO
4. Voice Assistant Selection (male/female & variations) - TODO
5. Conversational Abilities (like humans do) - TODO
6. Dynamic Visual Assistant  - TODO


## How to use
1. Go to OpenAI and get API Key (Free - only needs account creation)
2. Go to ElevenLabs and get API key (Free - only needs account creation)
3. Download this repository
4. Insert API keys where it tells you to in the code (lib/main.dart)
5. Run the Program :)

## Build Info
* Flutter 3.7.3
* Dart 2.19.2
* DevTools 2.20.1

## Possible Issues
### Android
* Enable Developer Mode on your phone

### iOS (tbh idc about this rn)
*  Enable internet connection so API can fetch the POST requests.  Look for the equivalent AndroidManifest.xml file. 
