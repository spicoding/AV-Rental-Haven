import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../models/user_model.dart'; // Import User model if needed elsewhere in this controller

class ProductController extends GetxController {
  final ApiService _apiService = ApiService();

  var products = <Product>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      var fetchedProducts = await _apiService.fetchProducts();
      products.assignAll(fetchedProducts);
    } catch (e) {
      Get.snackbar("Error", "Could not load products from server");
    } finally {
      isLoading.value = false;
    }
  }
}
