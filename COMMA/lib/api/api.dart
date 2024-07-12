class API {
  static const baseUrl = 'http://10.240.71.45:3000';


  static const hostConnect = "http://10.240.71.45/api_new_members";
  static const hostConnect2 = "http://10.240.71.45/api_new_lectures";

  static const hostConnectUser = "$hostConnect/user";
  static const hostConnectLectureFile = "$hostConnect2/lecture_folder";

  static const signup = "$hostConnectUser/signup.php";
  static const validatePhone = "$hostConnectUser/validate_phone.php";
  static const login = "$hostConnectUser/login.php";

  static const getAllFolders = "$hostConnectLectureFile/getAllFolders.php";
  static const deleteFolder = "$hostConnectLectureFile/deleteFolder.php";
}
