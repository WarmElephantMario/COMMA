class API {
  static String get baseUrl {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    if (env == 'production') {
      return 'http://ec2-3-144-116-32.us-east-2.compute.amazonaws.com:3000'; // 서버 URL
    } else {
      return 'http://10.240.218.120:3000'; // 개발 환경 URL
    }
  }
}

