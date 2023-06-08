import 'dart:io';

import 'package:absensi/page/detail_precense/view/detail_precense_view.dart';
import 'package:absensi/page/home/view/home_view.dart';
import 'package:absensi/page/main_page/main_page_view.dart';
import 'package:absensi/services/precense_services.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

import '../../../model/detail_precense_model.dart';
import '../../login/view/login_view.dart';

class DetailPrecenseController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit

    super.onInit();
  }

  RxBool isLoading = false.obs;
  RxBool isLoadingDownload = false.obs;
  RxInt countDownload = 0.obs;

  RxBool isLoadingDownloadOut = false.obs;
  RxInt countDownloadOut = 0.obs;

  DetailPrecenseModel? detailPrecenseModel;

  Future<dynamic> downloadImg(String nameImage) async {
    Dio dio = Dio();
    final GetStorage box = GetStorage();
    dynamic userDataLocal = box.read('userData');
    dynamic userId = userDataLocal['_id'];
    final String imageUrl =
        'https://api-kepegawaian.qtera.co.id/files/users/$userId/$nameImage';
    try {
      String savePath = await getFilePath(nameImage);
      await dio.download(
        imageUrl,
        savePath,
        onReceiveProgress: (count, total) {
          print(count);
          print(total);
          double hasil = (count / total) * 100;
          countDownload.value = hasil.toInt();
          print(countDownload.value);
          if (countDownload.value == 100) {
            Fluttertoast.showToast(
                msg: 'Unduh Berhasil', gravity: ToastGravity.CENTER);
          }
          isLoadingDownload(true);
        },
      );
      print(savePath);
      isLoadingDownload(false);
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> downloadImgOut(String nameImageOut) async {
    Dio dio = Dio();
    final box = GetStorage();
    var userDataLocal = box.read('userData');
    var userId = userDataLocal['_id'];
    final imageUrl =
        'https://sencored/$userId/$nameImageOut';
    try {
      String savePath = await getFilePath(nameImageOut);
      await dio.download(
        imageUrl,
        savePath,
        onReceiveProgress: (count, total) {
          print(count);
          print(total);
          double hasil = (count / total) * 100;
          countDownloadOut.value = hasil.toInt();
          print(countDownloadOut.value);
          if (countDownloadOut.value == 100) {
            Fluttertoast.showToast(
                msg: 'Unduh Berhasil', gravity: ToastGravity.CENTER);
          }
          isLoadingDownloadOut(true);
        },
      );
      print(savePath);
      isLoadingDownloadOut(false);
    } catch (e) {
      print(e);
    }
  }

  Future<String> getFilePath(nameFlie) async {
    String path = '';
    // Directory('/storage/emulated/0/Download')
    Directory dir = Platform.isAndroid
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();
    // await getApplicationDocumentsDirectory();
    path = '${dir.path}/imagesQtera/$nameFlie';
    return path;
  }

  Future<dynamic> getDetailPrecense(String id) async {
    final GetStorage box = GetStorage();

    try {
      isLoading(true);
      dynamic dataPrecense = await PrecenseServices.detaiPrecenseModel(id);
      if (dataPrecense != null) {
        detailPrecenseModel = dataPrecense;
        Get.to(DetailPrecenseView());
        isLoading(false);
      } else {
        print('Data Kosong');
        isLoading(false);
        Get.offAll(MainPage());
        Fluttertoast.showToast(msg: 'Silahkan Login Kembali');
      }
    } catch (e) {
      print(e);
      isLoading(false);
      Get.offAll(MainPage());
      Fluttertoast.showToast(msg: 'Silahkan Login Kembali');
    }
  }
}
