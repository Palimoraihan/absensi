import 'dart:convert';
import 'dart:io';

import 'package:absensi/page/home/controller/home_controller.dart';
import 'package:absensi/page/login/view/login_view.dart';
import 'package:absensi/page/main_page/main_page_view.dart';
import 'package:absensi/page/pracense/view/confirm_picture_view.dart';
import 'package:absensi/page/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../widget/snacbar_item.dart';
import '../view/confirm_picture_out_view.dart';

class PrecenseController extends GetxController {
  @override
  void onInit() async {
    // TODO: implement onInit
    await GetStorage.init();
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    getToken = null;
  }

  TextEditingController placeC = TextEditingController();
  TextEditingController descriptonC = TextEditingController();
  var controller = Get.put(HomeController());
  var controller2 = Get.put(ProfileController());

  final ImagePicker _picker = ImagePicker();
  final box = GetStorage();
  List<DropdownMenuEntry> menuEntry = [];
  List<String> listDrop = <String>['Meeting', 'POC', 'Presentasi', 'ELSA'];
  String dropDownVal = 'Pilih';
  String? getToken;
  String? getName;
  // String? dropDownVal2;
  RxBool isLoading = false.obs;
  XFile? filePick;
  File? imageResult;
  String? nameFile;
  Position? position;
  bool? isFakeGps;
  String? address;
  DateTime? now;
  String? time;

  void dropDownfun(String val) {
    dropDownVal = val;
    print(dropDownVal);
    update();
  }

  void pickImage(String token, String name) async {
    getToken = token;
    getName = name;
    print('get token $getToken & name $getName');
    var userData = box.read("userData");

    print('user data pic image in $userData');
    isLoading.value = true;
    try {
      Map<String, dynamic> getLocation = await determinePosition();
      if (getLocation['error'] != true) {
        filePick = await _picker.pickImage(
            source: ImageSource.camera, imageQuality: 20);
        position = getLocation['position'];
        if (filePick?.path != null) {
          List<Placemark> placeMarks = await placemarkFromCoordinates(
              position!.latitude, position!.longitude);
          print('Position : ${position}');
          print(
              'Tempat : ${placeMarks[1].street!.length > 10 ? placeMarks[1].street : placeMarks[0].street},\n${placeMarks[0].subLocality},\n${placeMarks[0].locality},\n${placeMarks[0].subAdministrativeArea},\n${placeMarks[0].country}');
          address =
              '${placeMarks[1].street!.length > 10 ? placeMarks[1].street : placeMarks[0].street},${placeMarks[0].subLocality},${placeMarks[0].locality},${placeMarks[0].subAdministrativeArea},${placeMarks[0].country}';
          now = DateTime.now();
          isFakeGps = position!.isMocked;
          print(isFakeGps);
          update();
          // await compress(filePick!);
          nameFile = filePick!.name;
          print(nameFile);
          Get.to(ConfirmPictureView());
          isLoading.value = false;
        } else {
          Get.back();
          isLoading.value = false;
        }
      } else {
        print(getLocation['message']);
        Fluttertoast.showToast(
            msg: '${getLocation['message']}', gravity: ToastGravity.CENTER);
        Get.back();
        isLoading.value = false;
      }
    } on PlatformException catch (e) {
      print('Platform Exception $e');
      Get.back();
      Fluttertoast.showToast(
          msg: 'Cek Koneksi, Lokasi, Camera $e', gravity: ToastGravity.CENTER);
      isLoading.value = false;
    } catch (e) {
      print(e);
      Get.back();
      Fluttertoast.showToast(
          msg: 'Cek Koneksi dan Lokasi $e', gravity: ToastGravity.CENTER);
      isLoading.value = false;
    }
  }

  // Future<void> compress(XFile imageFile) async {
  //   File fileImage = File(imageFile.path);
  //   var comprefile = await FlutterImageCompress.compressAndGetFile(
  //       fileImage.absolute.path, fileImage.path,
  //       quality: 20);
  //   imageResult = comprefile;
  //   update();
  //   print('Result Image ${imageResult}');
  // }

  Future<dynamic> uploadData(context) async {
    isLoading(true);
    print('upload data $getToken & $getName');
    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/absensi');

    try {
      var stream = http.ByteStream(filePick!.openRead());
      stream.cast();
      var lenght = await filePick!.length();

      var multipart =
          http.MultipartFile('foto', stream, lenght, filename: filePick!.name);
      if (dropDownVal != 'Pilih') {
        var request = http.MultipartRequest('POST', url)
          ..headers.addAll({
            "x-get-token": "$getToken",
            "Content-Type": "multipart/form-data"
          })
          ..files.add(multipart)
          ..fields['type'] = 'in'
          ..fields['keperluan'] = dropDownVal
          ..fields['rincian_keperluan'] = descriptonC.text
          ..fields['lokasi_in'] = '${placeC.text}, $address';
        var response = await request.send();
        print(response.statusCode);
        response.stream.transform(utf8.decoder).listen((event) {
          print(event);
          if (response.statusCode == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(milliseconds: 800),
                dismissDirection: DismissDirection.horizontal,
                elevation: 10,
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.40,
                    left: 10,
                    right: 10),
                backgroundColor: Colors.white,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                content: SnackbarItem(
                    isClose: false,
                    colorIcon: Colors.green,
                    colorText: Colors.black,
                    icon: Icons.check_circle,
                    desc: 'Absen Berhasil Di Buat'),
              ),
            );

            Get.offAll(MainPage());
            controller.getPrecense('today');
            controller2.getProfile();
            isLoading(false);
          } else {
            Fluttertoast.showToast(
                msg: 'Gagal Absen Silakan Logini',
                gravity: ToastGravity.CENTER);
            Get.offAll(LoginView());
            isLoading(false);
          }
        });
      } else {
        Fluttertoast.showToast(
            msg: 'Isi Keperluan Terlebih Dahulu', gravity: ToastGravity.CENTER);
        isLoading(false);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Gagal Absen Silakan Absen Ulang Kembali $e',
          gravity: ToastGravity.CENTER);
      Get.offAll(MainPage());
      // print(e);
      isLoading(false);
    }
  }

  Future<Map<String, dynamic>> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // return Future.error('Location services are disabled.');
      return {
        'message': 'Tidak di dapat untuk mengambil GPS dari devaces ini',
        'error': true,
      };
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        // return Future.error('Location permissions are denied');
        return {
          'message': 'Izin di tolak',
          'error': true,
        };
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return {
        'message': 'Tidak di izinkam untuk mangakses gps',
        'error': true,
      };
      // return Future.error(
      //     'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return {
      'position': position,
      'message': 'berhasil mendapatkan posisi',
      'error': false,
    };
  }
}
