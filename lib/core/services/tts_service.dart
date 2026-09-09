// lib/core/services/tts_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsSpeed {
  slow(0.38, '0.8x Slow & Clear'),
  normal(0.48, '1.0x Normal (Standard)'),
  fast(0.58, '1.2x Faster');

  final double rate;
  final String label;
  const TtsSpeed(this.rate, this.label);
}

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  List<dynamic> _availableVoices = [];
  double _speechRate = 0.48; // 0.48 translates to 0.96x - 1.0x normal speech on Android (FlutterTTS Android multiplies rate by 2.0)

  double get currentSpeechRate => _speechRate;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      // 0.48 produces standard 1.0x natural human talking speed on Android
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      try {
        final voices = await _flutterTts.getVoices;
        if (voices is List) {
          _availableVoices = voices;
        }
      } catch (_) {}

      _isInitialized = true;
    } catch (_) {}
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    try {
      await _flutterTts.setSpeechRate(rate);
    } catch (_) {}
  }

  Future<void> setSpeed(TtsSpeed speed) async {
    await setSpeechRate(speed.rate);
  }

  bool _hasVoiceFor(String langPrefix) {
    if (_availableVoices.isEmpty) return false;
    for (final v in _availableVoices) {
      final name = v.toString().toLowerCase();
      if (name.contains(langPrefix.toLowerCase())) return true;
    }
    return false;
  }

  Future<void> speak(String text, {String? languageCode}) async {
    await init();
    try {
      String targetLang = languageCode ?? 'en-IN';
      String targetText = text;

      // Check if browser/system has native voice for South Indian languages
      if (targetLang.startsWith('ta')) {
        if (!_hasVoiceFor('ta') && !_hasVoiceFor('tamil')) {
          targetLang = 'en-IN';
          targetText = _toTamilPhonetic(text);
        }
      } else if (targetLang.startsWith('te')) {
        if (!_hasVoiceFor('te') && !_hasVoiceFor('telugu')) {
          targetLang = 'en-IN';
          targetText = _toTeluguPhonetic(text);
        }
      } else if (targetLang.startsWith('kn')) {
        if (!_hasVoiceFor('kn') && !_hasVoiceFor('kannada')) {
          targetLang = 'en-IN';
          targetText = _toKannadaPhonetic(text);
        }
      }

      await _flutterTts.setLanguage(targetLang);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.stop();
      await _flutterTts.speak(targetText);
    } catch (e) {
      // Fallback to en-IN in case of synthesizer exception
      try {
        await _flutterTts.setLanguage('en-IN');
        await _flutterTts.setSpeechRate(_speechRate);
        await _flutterTts.speak(text);
      } catch (_) {}
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  String _toTamilPhonetic(String text) {
    if (text.contains('வணக்கம்')) {
      return 'Vanakkam! KrishiSetu Rider seyalikku ungalai varaverkirom.';
    }
    if (text.contains('பிக்கப்')) {
      return 'Next pickup point ahead. Produce loading verification required.';
    }
    return 'Vanakkam. KrishiSetu Logistics Partner audio instruction active.';
  }

  String _toTeluguPhonetic(String text) {
    if (text.contains('నమస్కారం')) {
      return 'Namaskaram! KrishiSetu Rider app-ku swagatham.';
    }
    if (text.contains('పికప్')) {
      return 'Next farmer pickup stop ahead. Produce loading verification required.';
    }
    return 'Namaskaram. KrishiSetu Logistics Partner audio instruction active.';
  }

  String _toKannadaPhonetic(String text) {
    if (text.contains('ನಮಸ್ಕಾರ')) {
      return 'Namaskara! KrishiSetu Rider app-ge suswagatha.';
    }
    if (text.contains('ಪಿಕಪ್')) {
      return 'Next farmer pickup stop ahead. Produce loading verification required.';
    }
    return 'Namaskara. KrishiSetu Logistics Partner audio instruction active.';
  }

  Future<void> speakLanguageGreeting(String code) async {
    String msg;
    String locale;
    switch (code) {
      case 'hi':
        msg = 'नमस्ते! कृषिसेतु राइडर ऐप में आपका स्वागत है।';
        locale = 'hi-IN';
        break;
      case 'mr':
        msg = 'नमस्कार! कृषीसेतू रायडर ॲपमध्ये आपले स्वागत आहे.';
        locale = 'mr-IN';
        break;
      case 'ta':
        // If native voice is absent, speak clear Romanized Tamil using en-IN
        if (_hasVoiceFor('ta') || _hasVoiceFor('tamil')) {
          msg = 'வணக்கம்! கிரிஷிசேது ரைடர் செயலியில் உங்களை வரவேற்கிறோம்.';
          locale = 'ta-IN';
        } else {
          msg = 'Vanakkam! KrishiSetu Rider seyalikku ungalai varaverkirom.';
          locale = 'en-IN';
        }
        break;
      case 'te':
        if (_hasVoiceFor('te') || _hasVoiceFor('telugu')) {
          msg = 'నమస్కారం! కృషిసేతు రైడర్ యాప్‌కు స్వాగతం.';
          locale = 'te-IN';
        } else {
          msg = 'Namaskaram! KrishiSetu Rider app-ku swagatham.';
          locale = 'en-IN';
        }
        break;
      case 'kn':
        if (_hasVoiceFor('kn') || _hasVoiceFor('kannada')) {
          msg = 'ನಮಸ್ಕಾರ! ಕೃಷಿಸೇತು ರೈಡರ್ ಆ್ಯಪ್‌ಗೆ ಸುಸ್ವಾಗತ.';
          locale = 'kn-IN';
        } else {
          msg = 'Namaskara! KrishiSetu Rider app-ge suswagatha.';
          locale = 'en-IN';
        }
        break;
      default:
        msg = 'Welcome to KrishiSetu Rider application.';
        locale = 'en-IN';
        break;
    }
    await speak(msg, languageCode: locale);
  }

  Future<void> speakStopInstruction({
    required String farmerName,
    required String cropName,
    required double weightKg,
    required String ttsLocale,
  }) async {
    String msg;
    String lang = ttsLocale;
    if (ttsLocale.startsWith('hi')) {
      msg = 'अगला पिकअप किसान $farmerName के पास है। ${weightKg.toStringAsFixed(0)} किलो $cropName प्राप्त करें।';
    } else if (ttsLocale.startsWith('mr')) {
      msg = 'पुढील पिकअप शेतकरी $farmerName यांच्याकडे आहे. ${weightKg.toStringAsFixed(0)} किलो $cropName घ्या.';
    } else if (ttsLocale.startsWith('ta')) {
      if (_hasVoiceFor('ta') || _hasVoiceFor('tamil')) {
        msg = 'அடுத்த பிக்கப் விவசாயி $farmerName. ${weightKg.toStringAsFixed(0)} கிலோ $cropName எடுக்கவும்.';
      } else {
        lang = 'en-IN';
        msg = 'Next pickup at farmer $farmerName. Collect ${weightKg.toStringAsFixed(0)} kg of $cropName.';
      }
    } else if (ttsLocale.startsWith('te')) {
      if (_hasVoiceFor('te') || _hasVoiceFor('telugu')) {
        msg = 'తదుపరి పికప్ రైతు $farmerName వద్ద ఉంది. ${weightKg.toStringAsFixed(0)} కిలోల $cropName స్వీకరించండి.';
      } else {
        lang = 'en-IN';
        msg = 'Next pickup at farmer $farmerName. Collect ${weightKg.toStringAsFixed(0)} kg of $cropName.';
      }
    } else if (ttsLocale.startsWith('kn')) {
      if (_hasVoiceFor('kn') || _hasVoiceFor('kannada')) {
        msg = 'ಮುಂದಿನ ಪಿಕಪ್ ರೈತ $farmerName ಬಳಿ ಇದೆ. ${weightKg.toStringAsFixed(0)} ಕೆಜಿ $cropName ಪಡೆಯಿರಿ.';
      } else {
        lang = 'en-IN';
        msg = 'Next pickup at farmer $farmerName. Collect ${weightKg.toStringAsFixed(0)} kg of $cropName.';
      }
    } else {
      msg = 'Next pickup at farmer $farmerName. Collect ${weightKg.toStringAsFixed(0)} kg of $cropName.';
    }
    await speak(msg, languageCode: lang);
  }

  Future<void> speakGeofencePassed({required String ttsLocale}) async {
    String msg;
    if (ttsLocale.startsWith('hi')) {
      msg = 'आप गंतव्य स्थल के 100 मीटर के दायरे में पहुंच गए हैं। कृपया उत्पाद की फोटो खींचें और ओटीपी दर्ज करें।';
    } else if (ttsLocale.startsWith('mr')) {
      msg = 'तुम्ही गंतव्य स्थानाच्या 100 मीटरच्या कक्षेत पोहोचला आहात. कृपया मालाचा फोटो काढा आणि ओटीपी प्रविष्ट करा.';
    } else {
      msg = 'Geofence check passed. You are within 100 meters of the buyer. Please capture produce photo and enter OTP.';
    }
    await speak(msg, languageCode: ttsLocale.startsWith('hi') || ttsLocale.startsWith('mr') ? ttsLocale : 'en-IN');
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  service.init();
  return service;
});

class TtsSpeedNotifier extends StateNotifier<TtsSpeed> {
  final TtsService _service;
  TtsSpeedNotifier(this._service) : super(TtsSpeed.normal);

  Future<void> changeSpeed(TtsSpeed speed) async {
    state = speed;
    await _service.setSpeed(speed);
  }
}

final ttsSpeedProvider =
    StateNotifierProvider<TtsSpeedNotifier, TtsSpeed>((ref) {
  return TtsSpeedNotifier(ref.watch(ttsServiceProvider));
});

