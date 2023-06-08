import 'dart:convert';

import 'package:absensi/page/login/view/login_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../model/detail_precense_model.dart';
import '../model/precense_model.dart';
import 'package:http/http.dart' as http;

import '../page/home/view/home_view.dart';

class PrecenseServices {
  static Future<dynamic> precenseModel(String filter) async {
    print(filter);
    final GetStorage box = GetStorage();
    dynamic userData = box.read('userData');
    print('Data from precense Services : $userData');
    dynamic tokens = userData['token'];
    final Uri url = Uri.parse(
        '${dotenv.env['API_BASE_URL']}/absen?date=$filter');
    try {
      final response =
          await http.get(url, headers: {'x-get-token': '$tokens'});
      if (response.statusCode == 200) {
        return PrecenseModel.fromJson(jsonDecode(response.body));
      } else {
        box.remove('userData');
        Fluttertoast.showToast(
            msg: 'Silakan Login Kembali', gravity: ToastGravity.CENTER);
        Get.offAll(LoginView());
      }
    } catch (e) {
      box.remove('userData');

      Fluttertoast.showToast(
          msg: 'Silakan Login Kembali', gravity: ToastGravity.CENTER);
      Get.offAll(LoginView());
    }
  }

  static Future<dynamic> detaiPrecenseModel(String id) async {
    final GetStorage box = GetStorage();
    dynamic userData = box.read('userData');
    dynamic tokens = userData['token'];
    final Uri url =
        Uri.parse('${dotenv.env['API_BASE_URL']}/mobile/absencies/$id');
    final response =
        await http.get(url, headers: {'x-access-token': '$tokens'});
    if (response.statusCode == 200) {
      return DetailPrecenseModel.fromJson(jsonDecode(response.body));
    } else {
      Get.offAll(HomeView());
      Fluttertoast.showToast(msg: 'Tesrjadi Kesalahan');
    }
  }
}
