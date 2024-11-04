import 'dart:io';
import '../../service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_prefs_keys.dart';
import '../../constants/app_router.dart';
import '../../service/preference_service.dart';

class AcademicRecordScreen extends StatelessWidget {
  const AcademicRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(AcademicRecordController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("MULOS"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Text("학적 인증", style: TextStyle(fontSize: 20),),
              const SizedBox(height: 20,),
              const Divider(height: 1, thickness: 1, color: AppColors.grey600,),
              const SizedBox(height: 40,),
              Align(alignment: Alignment.centerLeft,child: Text("이미지 예시")),
              const SizedBox(height: 4,),
              Obx(() {
                if(controller.selectedImage.value == null){
                  return Image.asset("assets/image/sample_image.png");
                }else {
                  return Image.file(File(controller.selectedImage.value!.path));
                }
              },),
              const SizedBox(height: 10,),
              Text("클래스넷 > 개인정보 > 기본정보 이미지 캡쳐"),
              const SizedBox(height: 40,),
              Obx(() {
                return ElevatedButton(onPressed: () async {
                  if(controller.selectedImage.value == null) {
                    controller.pickImage();
                    return;
                  }
                  // 이미지를 선택한 후 회원가입을 완료하도록 수정
                  await controller.completeSignUp(); // 회원가입 완료 함수 호출

                  // 회원가입이 완료된 후 홈 화면으로 이동
                  await AppPreferences().prefs?.setBool(AppPrefsKeys.isLoginUser, true);
                  Get.offNamedUntil(AppRouter.home, (route) => false);

                  // await AppPreferences().prefs?.setBool(AppPrefsKeys.isLoginUser, true) ?? false;
                  // Get.offNamedUntil(AppRouter.home, (route) => false);

                }, child: Text("${controller.selectedImage.value == null ? "갤러리에서 탐색하기" : "가입 완료"}"));
              },)
            ],
          ),
        ),
      ),
    );
  }

}


class AcademicRecordController extends GetxController{
  final ApiService apiService = ApiService();
  Rx<File?> selectedImage = Rx<File?>(null);

  String? studentId;
  String? password;

  void setUserInfo(String id, String pw) {
    studentId = id;
    password = pw;
  }


  Future<void> pickImage() async {
    await apiService.pickImage();
    selectedImage.value = apiService.selectedImage.value;
  }

/*
  Future<void> completeSignUp() async {
    print("completeSignUp 호출"); // 확인용 로그 추가
    if (studentId != null && password != null) {
      print("회원가입 요청 중..."); // 요청 전 로그 추가
      String? photoUrl = await apiService.uploadImage(selectedImage.value!);
      if (photoUrl != null) {
        await apiService.registerUserWithPhoto(studentId!, password!, photoUrl);
        Fluttertoast.showToast(msg: "회원가입이 완료되었습니다.");
        Get.offNamed('/home');
      } else {
        Fluttertoast.showToast(msg: "이미지 업로드 실패");
      }
    } else {
      Fluttertoast.showToast(msg: "회원 정보를 확인해주세요.");
    }
  }
*/
  Future<void> completeSignUp() async {
    print("completeSignUp 호출"); // 확인용 로그 추가
    if (studentId != null && password != null) {
      //String? photoUrl;
      String photoUrl = "example@example.com";
      int role = 1;                 // 기본값 설정
      String email = "test@example.com";       // 기본값 설정
      String name = "Test User";               // 기본값 설정
      String professor = "Prof";          // 기본값 설정

      // 회원가입 API 호출
      final userData = {
        'student_id': studentId,
        'role': role,
        'email': email,
        'name': name,
        'photo_url': photoUrl,
        'professor': professor,
        'password': password
      };
      print("userData to be sent: $userData"); // userData 로그 출력

      final isRegistered = await apiService.registerUser(userData);
      print("isRegistered: $isRegistered"); // 로그 추가

      /*
      // selectedImage가 있을 경우에만 이미지 업로드
      if (selectedImage.value != null) {
        photoUrl = await apiService.uploadImage(selectedImage.value!);
        if (photoUrl == null) {
          Fluttertoast.showToast(msg: "이미지 업로드 실패");
          return; // 이미지 업로드 실패 시 함수 종료
        }
      } else {
        photoUrl = null; // 이미지가 없으면 photoUrl을 null로 설정
      }
      */

      // 회원가입 API 호출
      if (isRegistered) {

        Fluttertoast.showToast(msg: "회원가입이 완료되었습니다.");
        Get.offNamed('/home');
      } else {
        Fluttertoast.showToast(msg: "회원가입 실패");
      }
    } else {
      Fluttertoast.showToast(msg: "회원 정보를 확인해주세요.");
    }
  }

}
