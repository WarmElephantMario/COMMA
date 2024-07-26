class API {
  static String get baseUrl {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    if (env == 'production') {
      return 'https://your-production-url.com'; // 서버 URL
    } else {
      return 'http://10.240.222.239:3000'; // 개발 환경 URL
    }
  }
}
