import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SignUpController extends GetxController {
  var username = "".obs;
  var email = "".obs;
  var password = "".obs;

  signUp(user, email, pass) {
    username.value = user;
    email.value = email;
    password.value = pass;
  }
}
