import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env")
abstract class Env {
  @EnviedField(varName: 'OPENAI_API_KEY')
  static const String apiKey = _Env.apiKey; // 타입 명시적으로 선언
}
