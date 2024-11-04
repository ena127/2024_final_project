import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';


class ApiService {
  static const String baseUrl = 'http://3.39.184.195:5000';
  final ImagePicker _picker = ImagePicker();
  Rx<File?> selectedImage = Rx<File?>(null);

  // 공통 API 요청 함수
  Future<dynamic> apiFetch(String endpoint, String method,
      {Map<String, dynamic>? data}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = {'Content-Type': 'application/json'};
    final body = data != null ? jsonEncode(data) : null;

    http.Response response;
    try {
      if (method == 'POST') {
        response = await http.post(url, headers: headers, body: body);
      } else {
        // GET의 경우
        response = await http.get(url, headers: headers);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        //성공
        return jsonDecode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      throw Exception('Failed to connect to API: $error');
    }
  }

  // Rentals API
  Future<dynamic> addRental(Map<String, dynamic> rentalData) {
    return apiFetch('/rentals', 'POST', data: rentalData);
  }

  Future<dynamic> getAllRentals() {
    return apiFetch('/rentals', 'GET');
  }

  Future<dynamic> getUserRentals(int userId) {
    return apiFetch('/rentals/$userId', 'GET');
  }

  // Returns API
  Future<dynamic> addReturn(Map<String, dynamic> returnData) {
    return apiFetch('/returns', 'POST', data: returnData);
  }

  Future<dynamic> getAllReturns() {
    return apiFetch('/returns', 'GET');
  }

  Future<dynamic> getUserReturns(int userId) {
    return apiFetch('/returns/$userId', 'GET');
  }

  // User API
  Future<dynamic> getUser(int userId) {
    return apiFetch('/users/$userId', 'GET');
  }

  // 유저 등록 API 호출 함수
  Future<bool> registerUser(Map<String, dynamic> userData)async {

    try {
      final response = await apiFetch('/auth/signup', 'POST', data: userData);
      print(userData);

      // 서버 응답이 성공 메시지를 포함할 때 true 반환
      if (response != null && response['message'] == 'User registered successfully') {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print("Error in registerUser: $error");
      return false;
    }
  }

  // Device API
  Future<dynamic> getDevice(int deviceId) {
    return apiFetch('/devices/$deviceId', 'GET');
  }

  Future<dynamic> registerDevice(Map<String, dynamic> deviceData) {
    return apiFetch('/devices', 'POST', data: deviceData);
  }

  // 로그인 API 호출 함수
  Future<bool> isLoginUser(String studentId, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'student_id': studentId, 'password': password}),
    );

    if (response.statusCode == 200) {
      // 로그인 성공 시 JWT 토큰 저장 (필요한 경우 SharedPreferences 사용)
      final token = jsonDecode(response.body)['token'];
      // 토큰을 저장하거나 사용해 권한을 부여할 수 있습니다.
      return true;
    } else {
      // 로그인 실패 처리
      print('Login failed: ${response.body}');
      return false;
    }
  }

  // 갤러리 이미지 받아오기
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  //서버에 이미지 업로드하고 url받아오기
  Future<String?> uploadImage(File image) async {
    final url = Uri.parse('$baseUrl/upload'); // 서버의 업로드 엔드포인트
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);
      final photoUrl = jsonResponse['photo_url'];

      print('Uploaded photo URL: $photoUrl'); // photo_url 출력
      return photoUrl;
    } else {
      print('Image upload failed: ${response.statusCode}');
      return null;
    }
  }

}

