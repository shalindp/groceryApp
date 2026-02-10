import 'package:grocery_api/api.dart';

class ApiService {
  final ApiClient _apiClient = ApiClient(basePath: 'http://192.168.0.100:5112');
  late StoreApi storeApi;
  late ProductApi productApi;

  late final Map<String, dynamic> _cache = {};

  ApiService() {
    storeApi = StoreApi(_apiClient);
    productApi = ProductApi(_apiClient);
  }

  void EE() async {
    var x = productApi.productPriceAsync;
  }

  T? getWithManualCache<T>(String cacheKey) {
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }
    return null;
  }

  void setWithManualCache(String cacheKey, dynamic data) {
    _cache[cacheKey] = data;
  }

  Future<T> useMutation<T, K>(
    Future<T> Function() method,
    List<String> invalidators,
  ) async {
    return await method();
  }

  Future<Return> useQuery<Return>(
    Future<Return> Function(ProductApi a) f, {
    String? providerName,
  }) async {
    var cached = _cache.containsValue(providerName);
    if (cached) {
      return _cache[providerName];
    }
    var result = await f(productApi);
    if (providerName != null) {
      _cache[providerName] = result;
    }

    return result;
  }
}

class ProviderKey {
  static String Function(String productId) productPrice = (String productId) => "product-price-$productId";
}
