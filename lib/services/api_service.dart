import 'package:grocery_api/api.dart';

class ApiService {
  final ApiClient _apiClient = ApiClient(basePath: 'http://192.168.0.100:5112');
  late RegionApi regionApi;
  late StoreApi storeApi;
  late ProductApi productApi;

  ApiService() {
    regionApi = RegionApi(_apiClient);
    storeApi = StoreApi(_apiClient);
    productApi = ProductApi(_apiClient);
  }

  Future<T> useMutation<T, K>(
    Future<T> Function() method,
    List<String> invalidators,
  ) async {
    return await method();
  }

  void useQuery() {}
}
