import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grocery_api/api.dart';
import 'package:groceryapp/extensions/string_extensions.dart';
import 'package:groceryapp/widgets/ProductCard.dart';
import 'package:signals/signals_flutter.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final $products = signal<List<ProductResponse>>([]);
  final $isLoadingMoreProducts = signal(false);

  List<CreateSessionWithRegionResponse> _sessions = [];
  final _scrollController = ScrollController();
  String _currentSearchTerm = "";

  @override
  void initState() {
    _scrollController.addListener(onLoadMoreProducts);
    createRegionSession();
    getProductsAsync();
    super.initState();
  }

  Future<void> createRegionSession() async {
    final apiClient = ApiClient(basePath: 'http://192.168.0.100:5112');
    final regionApi = RegionApi(apiClient);

    List<CreateSessionWithRegionId> a = [
      CreateSessionWithRegionId(
        storeName: StoreName.number0,
        regionId: 1497678,
      ),
      CreateSessionWithRegionId(
        storeName: StoreName.number0,
        regionId: 2683184,
      ),
      CreateSessionWithRegionId(
        storeName: StoreName.number0,
        regionId: 1188758,
      ),
      CreateSessionWithRegionId(
        storeName: StoreName.number0,
        regionId: 2791790,
      ),
      // CreateSessionWithRegionId(
      //   storeName: StoreName.number0,
      //   regionId: 2810806,
      // ),
      // CreateSessionWithRegionId(
      //   storeName: StoreName.number0,
      //   regionId: 1155534,
      // ),
    ];

    var response = await regionApi.createSessionWithRegionsAsync(a);
    _sessions = response!;
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
                itemCount: $products.watch(context).length,
                itemBuilder: (context, index) {
                  var item = $products.value[index];
                  return Column(
                    children: [
                      ProductCard(
                        sessions: _sessions,
                        title: toTitleCase(item.name),
                        imgUrl: item.imageUrl,
                        priceFetchUlr: item.pricingUrls[0].pricingUrl!,
                      ),
                    ],
                  );
                },
              ),
              Align(
                alignment: AlignmentGeometry.bottomCenter,
                child: Container(
                  height: 24,
                  color: Colors.transparent,
                  // color: Colors.pink,
                  child: $isLoadingMoreProducts.watch(context) ? SpinKitFadingCube(color: Colors.black, size: 14): null,
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
