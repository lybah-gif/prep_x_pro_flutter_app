// lib/app/services/audio_service.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService extends GetxService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final RxBool isListening = false.obs;
  final RxBool isSpeaking = false.obs;
  final RxBool speechAvailable = false.obs;
  final RxString transcript = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    speechAvailable.value = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.45); // Slightly slower for clarity
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() => isSpeaking.value = true);
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    _tts.setErrorHandler((_) => isSpeaking.value = false);
  }

  // Play a sound from android/app/src/main/res/raw/
  Future<void> playRawSound(String soundName) async {
    try {
      await _audioPlayer.play(AssetSource('raw/$soundName.mp3'));
    } catch (e) {
      debugPrint('Error playing raw sound: $e');
    }
  }

  // Start listening — updates transcript reactively
  Future<void> startListening() async {
    if (!speechAvailable.value) {
      Get.snackbar('Error', 'Speech recognition not available on this device');
      return;
    }

    // Play mic start sound
    await playRawSound('mic_start');

    isListening.value = true;
    transcript.value = '';

    await _speech.listen(
      onResult: (result) {
        transcript.value = result.recognizedWords;
        if (result.finalResult) {
          isListening.value = false;
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      localeId: 'en_US',
    );
  }

  Future<void> stopListening() async {
    isListening.value = false;
    await _speech.stop();
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    isSpeaking.value = false;
  }

  @override
  void onClose() {
    _speech.cancel();
    _tts.stop();
    _audioPlayer.dispose();
    super.onClose();
  }
}