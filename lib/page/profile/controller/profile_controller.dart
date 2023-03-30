import 'package:absensi/model/user_model.dart';
import 'package:absensi/services/user_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../login/view/login_view.dart';

class ProfileController extends GetxController {
  @override
  void onInit() async {
    await getProfile();
    // TODO: implement onInit
    super.onInit();
  }

  RxBool isLoading = false.obs;
  UserModel? _userModel;
  UserModel? get resul => _userModel;

  Future<dynamic> getProfile() async {
    isLoading(true);
    final box = GetStorage();

    var dataProfile = await UserServices.userServices();

    if (dataProfile != null) {
      _userModel = dataProfile;
      print(_userModel!.data.name);
      isLoading(false);
    } else {
      print('Data kosong');
      isLoading(false);
      Get.offAll(LoginView());
      box.erase();
      Fluttertoast.showToast(msg: 'Silahkan Login Kembali');
    }
  }
}