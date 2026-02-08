import 'package:get_it/get_it.dart';
import 'package:grocery_api/api.dart';
import 'package:groceryapp/services/api_service.dart';

class StoreService {
  final _apiService = GetIt.I<ApiService>();

  late List<String> selectedWoolworthsStoreIds = [];
  late List<String> selectedPaknSaveStoreIds = [];

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

    if(result == true){
      selectedPaknSaveStoreIds = newPaknSaveStoreIds;
      selectedWoolworthsStoreIds = newWoolworthsStoreIds;
    }

    return result;
  }
}
