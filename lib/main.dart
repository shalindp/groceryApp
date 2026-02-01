import 'package:flutter/material.dart';
import 'package:grocery_api/api.dart';
import 'package:groceryapp/extensions/string_extensions.dart';
import 'package:groceryapp/widgets/ProductCard.dart';
import 'package:signals/signals_flutter.dart';

import 'services/di_container.dart';

void main() {
  addServices();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.only(top: 20, bottom: 0),
          child: ProductList(),
        ),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final $products = signal<List<ProductResponse>>([]);
  final $isLoadingMoreProducts = signal(false);

  List<CreateSessionWithRegionResponse> _sessions = [];
  final _scrollController = ScrollController();

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
      CreateSessionWithRegionId(
        storeName: StoreName.number0,
        regionId: 2810806,
      ),
      CreateSessionWithRegionId(
        storeName: StoreName.number0,
        regionId: 1155534,
      ),
    ];

    var response = await regionApi.createSessionWithRegionsAsync(a);
    _sessions = response!;
  }

  Future<void> getProductsAsync() async {
    // Create an instance of your API client
    final apiClient = ApiClient(basePath: 'http://192.168.0.100:5112');
    final productApi = ProductApi(apiClient);

    try {
      $isLoadingMoreProducts.value = true;
      await Future.delayed(const Duration(seconds: 1));
      var newProducts = await productApi.searchProducts(
        term: "milk",
        skip: $products.value.length,
        limit: 6,
      );

      if ($products.value.isEmpty) {
        $products.set(newProducts!);
      } else {
        $products.set([...$products.value, ...newProducts!]);
      }
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
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
            if (index == $products.value.length - 1 &&
                $isLoadingMoreProducts.watch(context))
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Loading..."),
              ),
          ],
        );
      },
    );
  }
}
