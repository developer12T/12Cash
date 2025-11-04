import 'package:_12sale_app/data/models/User.dart';
import 'package:_12sale_app/data/service/apiService.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../data/models/order/Product.dart';

class ProductService {
  static Future<List<Product>> fetchProduct({
    String? area,
    String? period,
    int page = 1,
    int limit = 5,
    String? q,
    String channel = 'cash', // ตัวอย่าง channel
    List<String> selectedGroups = const [],
    List<String> selectedBrands = const [],
    List<String> selectedSizes = const [],
    List<String> selectedFlavours = const [],
  }) async {
    String period =
        "${DateTime.now().year}${DateFormat('MM').format(DateTime.now())}";
    ApiService apiService = ApiService();
    await apiService.init();

    var response = await apiService.request(
      endpoint: 'api/cash/product/getProductPage',
      method: 'POST',
      body: {
        "type": "sale",
        "area": "${User.area}",
        "period": "${period}",
        "page": page,
        "limit": limit,
        "group": selectedGroups,
        "brand": selectedBrands,
        "size": selectedSizes,
        "flavour": selectedFlavours
      },
    );

    if (response.statusCode == 200) {
      final data = response.data['data'] as List;
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load fetchProduct');
    }
  }
}
