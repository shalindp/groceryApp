import 'package:get_it/get_it.dart';
import 'package:groceryapp/services/browse_service.dart';
import 'package:groceryapp/services/http_service.dart';
import 'package:groceryapp/services/search_service.dart';
import 'package:groceryapp/services/store_service.dart';

import 'api_service.dart';

final locator = GetIt.instance;

void addServices(){
  locator.registerSingleton(HttpService());
  locator.registerSingleton(ProductSearchService());
  locator.registerSingleton(ApiService());
  locator.registerSingleton(BrowseService());
  locator.registerSingleton(StoreService());
}