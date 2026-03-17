import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'configs/routes.dart';

void main() {
  runApp(
    GetMaterialApp(
      initialRoute: "/",
      getPages: routes,
      debugShowCheckedModeBanner: false,
    ),
  );
}
