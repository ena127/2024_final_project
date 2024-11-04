import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mulos/constants/app_colors.dart';
import 'package:mulos/constants/app_router.dart';
import 'package:mulos/service/api_service.dart';
import '../../constants/app_prefs_keys.dart';
import '../../service/preference_service.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignInController());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset("assets/image/app_icon.png"),
            TextField(
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.text,// 영문도 입력 가능하게 변경 (11.03)
              controller: controller.idTextController,
              decoration: InputDecoration(
                hintText: "학번",
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.grey100,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 13,
            ),
            TextField(
              obscureText: true,
              controller: controller.passwordTextController,
              decoration: InputDecoration(
                hintText: "비밀번호",
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.grey100,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 13,
            ),
            ElevatedButton(
                onPressed: () {
                  controller.verifyLogin();
                },
                child: Text("로그인")),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Color(0xffFFEB00),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset("assets/image/ic_logo_kakao.svg"),
                  Text("카카오로 시작하기"),
                  Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: false,
                      child:
                          SvgPicture.asset("assets/image/ic_logo_kakao.svg")),
                ],
              ),
            ),
            const SizedBox(
              height: 13,
            ),
            Container(
              decoration: const BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset("assets/image/ic_logo_google.svg"),
                  Text("구글로 시작하기"),
                  Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: false,
                      child:
                          SvgPicture.asset("assets/image/ic_logo_google.svg")),
                ],
              ),
            ),
            TextButton(
                onPressed: () {
                  Get.toNamed(AppRouter.sign_up);
                },
                child: Text(
                  "회원가입",
                  style: TextStyle(color: Colors.black),
                )),
            TextButton(
                onPressed: () {
                  Get.toNamed(AppRouter.admin);
                },
                child: Text("관리자", style: TextStyle(color: Colors.black)))
          ],
        ),
      ),
    );
  }
}

class SignInController extends GetxController {
  final ApiService apiService = ApiService(); // (11.02) ApiService 인스턴스 추가

  late TextEditingController idTextController;
  late TextEditingController passwordTextController;

  @override
  void onInit() {
    idTextController = TextEditingController();
    passwordTextController = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    idTextController.dispose();
    passwordTextController.dispose();
    super.onClose();
  }

  void verifyLogin() async {
    var id = idTextController.value.text;
    var password = passwordTextController.value.text;

    /*
    if (id == "12345678" && password == "12345678") {
      await AppPreferences().prefs?.setBool(AppPrefsKeys.isLoginUser, true) ??
          false;
      Get.offNamed(AppRouter.home);
      return;
    }

    Fluttertoast.showToast(msg: "학번 혹은 비밀번호가 일치하지 않습니다.");
    */
    print("학번: $id, 비밀번호: $password"); // 입력 값 확인용

    // 로그인 API 호출 --- 임시 작성 코드, 로그인 성공 후 main 파일로 넘어가지 않는 문제 있음
    bool isLoggedIn = await apiService.isLoginUser(id, password);
    if (isLoggedIn) {
      await AppPreferences().prefs?.setBool(AppPrefsKeys.isLoginUser, true);
      Get.offNamed(AppRouter.home);
    } else {
      Fluttertoast.showToast(msg: "학번 혹은 비밀번호가 일치하지 않습니다.");
    }
  }
}
