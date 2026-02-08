import 'package:get_it/get_it.dart';
import 'package:grocery_api/api.dart';
import 'package:groceryapp/services/api_service.dart';

class StoreService {
  final _apiService = GetIt.I<ApiService>();

  late List<StoreResponse> allStores = [];
  late List<StoreResponse> selectedWoolworthsStore = [];
  late List<StoreResponse> selectedPaknSaveStore = [];

  Future<List<StoreResponse>> loadAllStores() async {
    var result = await _apiService.storeApi.storesAsync();
    allStores = result!;
    return result;
  }

  Future<bool?> onSelectStores(
    List<String> newWoolworthsStoreIds,
    List<String> newPaknSaveStoreIds,
  ) async {
    var result = await _apiService.storeApi.selectStoresAsync(
      selectStoresRequest: SelectStoresRequest(
        woolworthStoreIds: newWoolworthsStoreIds,
        paknSaveStoreIds: newPaknSaveStoreIds,
      ),
    );

    if (result == true) {
      selectedPaknSaveStore = allStores
          .where(
            (c) =>
                newPaknSaveStoreIds.contains(c.storeId) &&
                c.storeName == StoreName.number0,
          )
          .toList();

      selectedWoolworthsStore = allStores
          .where(
            (c) =>
                newWoolworthsStoreIds.contains(c.storeId) &&
                c.storeName == StoreName.number2,
          )
          .toList();
    }

    return result;
  }
}
