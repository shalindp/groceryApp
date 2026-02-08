import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grocery_api/api.dart';
import 'package:groceryapp/services/browse_service.dart';
import 'package:groceryapp/services/http_service.dart';
import 'package:groceryapp/services/search_service.dart';
import 'package:groceryapp/services/store_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:signals/signals_flutter.dart';

class ProductCard extends StatefulWidget {
  final ProductResponse productResponse;

  const ProductCard({super.key, required this.productResponse});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final _httpService = GetIt.I<HttpService>();
  final _productSearchService = GetIt.I<ProductSearchService>();
  final _storeService = GetIt.I<StoreService>();
  final _browseService = GetIt.I<BrowseService>();

  final $productPriceInfo = signal<List<ProductsPriceResponse>>([]);
  final $hasError = signal(false);
  final $quantity = signal(0);

  @override
  void initState() {
    Test();
    // print("@> INIT STATE ${widget.title}");
    // _getPricesForRegionsAsync();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> Test() async {
    List<ProductsPriceRequest> requests = [];

    for (var storeId in _storeService.selectedWoolworthsStoreIds) {
      var woolworthsProducts = widget.productResponse.storeSkus.where(
        (c) => c.storeName == StoreName.number2,
      );

      for (var woolworthsProduct in woolworthsProducts) {
        requests.add(
          ProductsPriceRequest(
            productId: woolworthsProduct.productId!,
            storeName: woolworthsProduct.storeName!,
            storeId: storeId,
            storeSku: woolworthsProduct.storeSku!,
          ),
        );
      }
    }

    for (var storeId in _storeService.selectedPaknSaveStoreIds) {
      var paknSaveProducts = widget.productResponse.storeSkus.where(
            (c) => c.storeName == StoreName.number0,
      );

      for (var woolworthsProduct in paknSaveProducts) {
        requests.add(
          ProductsPriceRequest(
            productId: woolworthsProduct.productId!,
            storeName: woolworthsProduct.storeName!,
            storeId: storeId,
            storeSku: woolworthsProduct.storeSku!,
          ),
        );
      }
    }

    var x = await _browseService.enqueue(requests);
    print("@> Resolved ${widget.productResponse.name} $x");
    $productPriceInfo.set(x);
  }

  // for (final session in widget.sessions) {
  //   final task = () async {
  //     try {
  //       await _httpService.get(
  //         widget.priceFetchUlr,
  //         headers: {
  //           "Accept": "application/json",
  //           "User-Agent": "api-client/1.0",
  //           "x-requested-with": "OnlineShopping.WebApp",
  //         },
  //         cookies: {
  //           "ASP.NET_SessionId": session.sessionId,
  //           "aga": session.aga,
  //         },
  //         fromJson: (json) {
  //           priceForRegions.add(ProductPriceInfo.fromJson(json['price']));
  //         },
  //       );
  //     } catch (e, st) {
  //       // 👇 log + continue, do NOT rethrow
  //       debugPrint(
  //         'Price fetch failed for ${widget.priceFetchUlr} '
  //         '(session=${session.sessionId}): $e',
  //       );
  //       $hasError.set(true);
  //     }
  //   }();
  //
  //   tasks.add(task);
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsetsGeometry.all(8),
            height: 128,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, 0),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              spacing: 8,
              children: [
                _ImageAndTitle(
                  title: widget.productResponse.name,
                  imgUrl: widget.productResponse.imageUrl,
                  $ProductPriceInfo: $productPriceInfo,
                  $hasError: $hasError,
                ),
                _BestPriceHero($quantity: $quantity),
              ],
            ),
          ),
          // Padding(
          //   padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
          //   child: Column(
          //     children: [
          //       Text(
          //         "Other stores",
          //         style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          //       ),
          //     ],
          //   ),
          // ),
          _OtherStores(),
          // Container(
          //   height: 42,
          //   decoration: BoxDecoration(
          //     color: Color(0xFF121212),
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       Icon(Icons.shopping_cart, color: Colors.white),
          //       Text("Add to cart", style: TextStyle(color: Colors.white)),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _OtherStores extends StatelessWidget {
  const _OtherStores({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xFFF3F4F6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _OtherStoresList(),
        ),
      ],
    );
  }
}

class _OtherStoresList extends StatelessWidget {
  final $isExpanded = signal(false);

  _OtherStoresList({super.key});

  @override
  Widget build(BuildContext context) {
    if ($isExpanded.watch(context)) {
      return ListView(
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        children: [
          _OtherStoreItem(),
          _OtherStoreItem(),
          _OtherStoreItem(),
          _OtherStoreItem(),
        ],
      );
    } else {
      return Column(
        children: [
          _OtherStoreItem(),
          _OtherStoreItem(isLast: true),
          GestureDetector(
            onTap: () {
              $isExpanded.set(!$isExpanded.value);
            },
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 2, bottom: 12),
              child: Row(
                spacing: 2,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("See more stores", style: TextStyle(fontSize: 12)),
                  Icon(
                    size: 15,
                    Icons.arrow_circle_down_rounded,
                    color: Color(0xFF9096A1),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}

class _OtherStoreItem extends StatelessWidget {
  final bool isLast;

  const _OtherStoreItem({super.key, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  Image.network(
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTk1PHKS-osQYGiGYkXZuekr6B2_6NHcibtEw&s",
                    width: 24,
                    height: 24,
                  ),
                  Text("Woolworths Northlands"),
                ],
              ),
              Column(
                spacing: 2,
                children: [
                  Text(
                    "\$2.00",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color(0xFFFAE6E2),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    child: Text(
                      "+0.33",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFC42921),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        !isLast
            ? Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6))
            : SizedBox(),
      ],
    );
  }
}

class _BestPriceHero extends StatelessWidget {
  final FlutterSignal<int> $quantity;

  const _BestPriceHero({super.key, required this.$quantity});

  void onQuantityChange(int i) {
    $quantity.set(($quantity.value + i).clamp(0, 32));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 8,
          children: [
            Image.network(
              "https://nz.rs-cdn.com/images/nwssb-7kmow/page/e3b47fd6c4f302c9dc9356d8df8b1a6e__f048/w1200.png",
              height: 24,
            ),
            Text("PaknSave Albany"),
          ],
        ),
        Row(
          spacing: 16,
          children: [
            if ($quantity.watch(context) != 0)
              GestureDetector(
                onTap: () {
                  onQuantityChange(-1);
                },
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(0, 0),
                        blurRadius: 6,
                        spreadRadius: 0,
                      ),
                    ],
                    color: Color(0xFF121212),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(Icons.remove, color: Colors.white),
                ),
              ),
            Text($quantity.watch(context) == 0 ? "" : "x${$quantity.value}"),
            GestureDetector(
              onTap: () {
                onQuantityChange(1);
              },
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 0),
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                  color: Color(0xFF121212),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImageAndTitle extends StatelessWidget {
  final String title;
  final String imgUrl;
  final FlutterSignal<List<ProductsPriceResponse>> $ProductPriceInfo;
  final FlutterSignal<bool> $hasError;

  const _ImageAndTitle({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.$ProductPriceInfo,
    required this.$hasError,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentGeometry.topLeft,
          child: Image.network(width: 60, height: 60, imgUrl),
        ),
        Expanded(
          child: Column(
            spacing: 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              $ProductPriceInfo.watch(context).isEmpty &&
                      !$hasError.watch(context)
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: 188,
                        height: 23,
                      ),
                    )
                  : $hasError.value
                  ? Text(
                      "Sorry, something went wrong. Please try again.",
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    )
                  : Row(
                      spacing: 6,
                      children: [
                        Text(
                          "\$${$ProductPriceInfo.value.first.price}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFBEB60),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "save \$${($ProductPriceInfo.value.first.price / 20).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
