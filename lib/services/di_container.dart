import 'package:get_it/get_it.dart';
import 'package:groceryapp/services/http_service.dart';
import 'package:groceryapp/services/search_service.dart';

final locator = GetIt.instance;

void addServices(){
  locator.registerSingleton(HttpService());
  locator.registerSingleton(ProductSearchService());
}