import 'dart:convert';
import 'package:absensi/model/user_model.dart';
import 'package:absensi/page/login/view/login_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class UserServices {
  static Future<dynamic> userServices() async {
    final GetStorage box = GetStorage();
    dynamic userData = box.read('userData');
    print('Data from User Services : $userData');
    dynamic employeeId = userData['employee'];
    dynamic tokens = userData['token'];
    print('toke profile :$tokens ,employeeId : $employeeId');

    try {
      final url =
          Uri.parse('${dotenv.env['API_BASE_URL']}/pegawai/$employeeId');
      final response =
          await http.get(url, headers: {'x-get-token': '$tokens'});
      if (response.statusCode == 200) {
        print(response.statusCode);
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        Fluttertoast.showToast(
            msg: 'Silakan Login Kembali', gravity: ToastGravity.CENTER);
        box.erase();
        return Get.offAll(LoginView());
      }
    } catch (e) {
      print('user services error $e');
      box.erase();
      Get.offAll(LoginView());
      Fluttertoast.showToast(
          msg: 'Silakan Login Kembali', gravity: ToastGravity.CENTER);
    }
  }
}
