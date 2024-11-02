import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://3.39.184.195:5000';

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
  Future<dynamic> registerUser(Map<String, dynamic> userData) {
    return apiFetch('/users', 'POST', data: userData);
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
}
