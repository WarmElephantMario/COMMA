import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:avatar_glow/avatar_glow.dart';

class SpeechRecognitionExample extends StatefulWidget {
  @override
  _SpeechRecognitionExampleState createState() =>
      _SpeechRecognitionExampleState();
}

class _SpeechRecognitionExampleState extends State<SpeechRecognitionExample> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';

  final Map<String, String> mathFormulas = {
    'a의 n제곱근': r'\sqrt[n]{a}',
    'x의 4승은 16': r'x^4 = 16',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _recognizedText = _applyMathFormulas(val.recognizedWords);
          }),
        );
      } else {
        setState(() => _isListening = false);
        _speech.stop();
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  String _applyMathFormulas(String text) {
    mathFormulas.forEach((key, value) {
      text = text.replaceAll(key, ' $value ');
    });
    return text;
  }

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> textSpans = _recognizedText.split(' ').map((part) {
      if (mathFormulas.containsValue(part.trim())) {
        return WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Math.tex(
            part.trim(),
            textStyle: TextStyle(fontSize: 24),
          ),
        );
      } else {
        return TextSpan(
          text: part + ' ',
          style: TextStyle(fontSize: 24),
        );
      }
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Speech Recognition Example')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              constraints:
                  BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
              child: RichText(
                text: TextSpan(children: textSpans),
              ),
            ),
            SizedBox(height: 20),
            AvatarGlow(
              animate: _isListening,
              glowColor: Theme.of(context).primaryColor,
              duration: const Duration(milliseconds: 2000),
              repeat: true,
              child: FloatingActionButton(
                onPressed: _listen,
                child: Icon(_isListening ? Icons.mic : Icons.mic_none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      home: SpeechRecognitionExample(),
    ));
