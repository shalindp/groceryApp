import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:grocery_api/api.dart';
import 'package:groceryapp/extensions/string_extensions.dart';
import 'package:groceryapp/services/api_service.dart';
import 'package:groceryapp/services/store_service.dart';
import 'package:groceryapp/widgets/product_card.dart';
import 'package:signals/signals_flutter.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final _apiService = GetIt.I<ApiService>();
  final _storeService = GetIt.I<StoreService>();

  final $products = signal<List<ProductResponse>>([]);
  final $isLoadingMoreProducts = signal(false);

  final _scrollController = ScrollController();
  String _currentSearchTerm = "";

  @override
  void initState() {
    _scrollController.addListener(onLoadMoreProducts);

    selectStores();
    super.initState();
  }

  Future<void> selectStores() async {
    await _storeService.loadAllStores();
    var selectStoresResult = await _storeService.onSelectStores(
      ["1189112", "2791790", "1224936", "1231998"],
      [
        "c180a72d-5dbe-4403-b7c7-91655e505492",
        "33d8d6fc-861a-45ff-9937-5ccdb55eaede",
        "be4c4780-218e-425a-a90f-63e21773572b",
        "d8032da3-c1b9-456e-b626-41ce21f8c67b",
      ],
    );

    if (selectStoresResult == true) {
      await getProductsAsync();
    }
  }

  Future<void> getProductsAsync({String term = ""}) async {
    if (term == _currentSearchTerm && term.isNotEmpty) {
      return;
    }

    // Create an instance of your API client
    final apiClient = ApiClient(basePath: 'http://192.168.0.100:5112');
    final productApi = ProductApi(apiClient);

    if (term.isNotEmpty) {
      $products.set([]);
    }

    try {
      $isLoadingMoreProducts.value = true;
      await Future.delayed(const Duration(seconds: 1));
      var newProducts = await productApi.searchProducts(
        term: term.isEmpty ? "milk" : term,
        skip: $products.value.length,
        limit: 6,
      );

      if ($products.value.isEmpty) {
        $products.set(newProducts!);
      } else {
        $products.set([...$products.value, ...newProducts!]);
      }

      _currentSearchTerm = term;
    } catch (e) {
      print('Error calling searchProductsV2: $e');
    } finally {
      $isLoadingMoreProducts.value = false;
    }
  }

  void onLoadMoreProducts() async {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent &&
        $products.value.length <= 200) {
      await getProductsAsync();
    }
  }

  Timer? _debounce;

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      getProductsAsync(term: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchBar(onSearchChange: onSearchChanged),
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.only(bottom: 24),
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: false,
                controller: _scrollController,
                itemCount: $products
                    .watch(context)
                    .length,
                itemBuilder: (context, index) {
                  var productResponse = $products.value[index];
                  return Column(
                    children: [ProductCard(productResponse: productResponse)],
                  );
                },
              ),
              Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: Container(
                  height: 24,
                  color: Colors.transparent,
                  // color: Colors.pink,
                  child: $isLoadingMoreProducts.watch(context)
                      ? SpinKitFadingCube(color: Colors.black, size: 14)
                      : null,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 62,
          color: Colors.grey[100],
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.shopping_bag_outlined),
              Icon(Icons.list),
              Icon(Icons.store),
              Icon(Icons.account_circle),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchBar extends StatelessWidget {
  final ValueChanged<String> onSearchChange;

  const SearchBar({super.key, required this.onSearchChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: Color(0xFFF3F4F6)),
        ),
        child: Align(
          alignment: AlignmentGeometry.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: onSearchChange,
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Color(0xFF9096A1)),
                border: InputBorder.none,
                isDense: true,
                hintText: "Butter, cheese, meat pies…",
              ),
            ),
          ),
        ),
      ),
    );
  }
}
