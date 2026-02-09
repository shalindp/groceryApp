import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get_it/get_it.dart';
import 'package:grocery_api/api.dart';
import 'package:groceryapp/services/browse_service.dart';
import 'package:groceryapp/services/http_service.dart';
import 'package:groceryapp/services/search_service.dart';
import 'package:groceryapp/services/store_service.dart';
import 'package:groceryapp/widgets/with_shimmer.dart';
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

  final $ProductPriceInfos = signal<List<ProductsPriceResponse>>([]);
  final $hasError = signal(false);
  final $quantity = signal(0);

  @override
  void initState() {
    fetchPriceAsync();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchPriceAsync() async {
    List<ProductsPriceRequest> requests = [];

    for (var store in _storeService.selectedWoolworthsStore) {
      var woolworthsProducts = widget.productResponse.storeSkus.where(
        (c) => c.storeName == StoreName.number2,
      );

      for (var woolworthsProduct in woolworthsProducts) {
        requests.add(
          ProductsPriceRequest(
            productId: woolworthsProduct.productId!,
            storeName: woolworthsProduct.storeName!,
            storeId: store.storeId,
            storeSku: woolworthsProduct.storeSku!,
          ),
        );
      }
    }

    for (var store in _storeService.selectedPaknSaveStore) {
      var paknSaveProducts = widget.productResponse.storeSkus.where(
        (c) => c.storeName == StoreName.number0,
      );

      for (var woolworthsProduct in paknSaveProducts) {
        requests.add(
          ProductsPriceRequest(
            productId: woolworthsProduct.productId!,
            storeName: woolworthsProduct.storeName!,
            storeId: store.storeId,
            storeSku: woolworthsProduct.storeSku!,
          ),
        );
      }
    }

    var result = await _browseService.enqueue(requests);
    $ProductPriceInfos.set(result);
  }

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
            child: SingleChildScrollView(
              child: Column(
                spacing: 8,
                children: [
                  _ImageAndTitle(
                    title: widget.productResponse.name,
                    imgUrl: widget.productResponse.imageUrl,
                    $ProductPriceInfos: $ProductPriceInfos,
                    $hasError: $hasError,
                    $quantity: $quantity,
                  ),
                  _BestPriceHero($ProductPriceInfos: $ProductPriceInfos),
                ],
              ),
            ),
          ),
          _OtherStores($ProductPriceInfos: $ProductPriceInfos),
        ],
      ),
    );
  }
}

class _OtherStores extends StatelessWidget {
  final FlutterSignal<List<ProductsPriceResponse>> $ProductPriceInfos;

  const _OtherStores({super.key, required this.$ProductPriceInfos});

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
          child: _OtherStoresList($ProductPriceInfos: $ProductPriceInfos),
        ),
      ],
    );
  }
}

class _OtherStoresList extends StatelessWidget {
  final FlutterSignal<List<ProductsPriceResponse>> $ProductPriceInfos;
  final $isExpanded = signal(false);

  _OtherStoresList({super.key, required this.$ProductPriceInfos});

  @override
  Widget build(BuildContext context) {
    if ($isExpanded.watch(context)) {
      return ListView.builder(
        padding: EdgeInsets.all(0),
        shrinkWrap: true,
        itemCount: $ProductPriceInfos.value.length,
        itemBuilder: (context, index) {
          var item = $ProductPriceInfos.value[index];
          return _OtherStoreItem(productPriceInfo: item);
        },
      );
    } else {
      return Column(
        children: [
          _OtherStoreItem(
            productPriceInfo: $ProductPriceInfos.watch(context).firstOrNull,
          ),
          _OtherStoreItem(
            productPriceInfo: $ProductPriceInfos.watch(context).length >= 2
                ? $ProductPriceInfos.value[1]
                : null,
            isLast: true,
          ),
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
  final ProductsPriceResponse? productPriceInfo;
  final bool isLast;

  final _storeService = GetIt.I<StoreService>();

  _OtherStoreItem({
    super.key,
    this.isLast = false,
    required this.productPriceInfo,
  });

  @override
  Widget build(BuildContext context) {
    final $store = computed<StoreResponse?>(() {
      var allSelected = [
        ..._storeService.selectedPaknSaveStore,
        ..._storeService.selectedWoolworthsStore,
      ];

      return allSelected
          .where(
            (c) =>
                c.storeId == productPriceInfo?.storeId &&
                c.storeName == productPriceInfo?.storeName,
          )
          .firstOrNull;
    });

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
                  WithShimmer(
                    condition: $store.watch(context) != null,
                    width: 24,
                    height: 24,
                    child: Image.network(
                      $store.watch(context)?.storeName == StoreName.number2
                          ? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTk1PHKS-osQYGiGYkXZuekr6B2_6NHcibtEw&s"
                          : "https://nz.rs-cdn.com/images/nwssb-7kmow/page/e3b47fd6c4f302c9dc9356d8df8b1a6e__f048/w1200.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                  WithShimmer(
                    condition: $store.watch(context) != null,
                    width: 160,
                    height: 20,
                    child: Text($store.watch(context)?.storeRegionName ?? ""),
                  ),
                ],
              ),
              Column(
                spacing: 2,
                children: [
                  WithShimmer(
                    condition: $store.watch(context) != null,
                    width: 35,
                    height: 17,
                    child: Text(
                      "${productPriceInfo?.price}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  WithShimmer(
                    condition: $store.watch(context) != null,
                    width: 34,
                    height: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xFFFAE6E2),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),

                      child: Text(
                        (productPriceInfo?.price ?? 0).toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFC42921),
                          fontWeight: FontWeight.w500,
                        ),
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
  final FlutterSignal<List<ProductsPriceResponse>> $ProductPriceInfos;
  final _storeService = GetIt.I<StoreService>();

  _BestPriceHero({super.key, required this.$ProductPriceInfos});

  @override
  Widget build(BuildContext context) {
    final $bestProductPrice = computed<ProductsPriceResponse?>(() {
      final prices = $ProductPriceInfos.value;

      if (prices.isEmpty) return null;

      final sorted = [...prices]..sort((a, b) => a.price.compareTo(b.price));

      return sorted.first;
    });

    final $selectedBestStore = computed<StoreResponse?>(() {
      final productPriceInfo = $bestProductPrice.value;
      if (productPriceInfo == null) return null;

      final allSelected = [
        ..._storeService.selectedPaknSaveStore,
        ..._storeService.selectedWoolworthsStore,
      ];

      return allSelected
          .where(
            (c) =>
                c.storeId == productPriceInfo.storeId &&
                c.storeName == productPriceInfo.storeName,
          )
          .firstOrNull;
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 8,
          children: [
            WithShimmer(
              condition: $selectedBestStore.watch(context) != null,
              width: 24,
              height: 24,
              child: Image.network(
                $selectedBestStore.watch(context)?.storeName ==
                        StoreName.number0
                    ? "https://nz.rs-cdn.com/images/nwssb-7kmow/page/e3b47fd6c4f302c9dc9356d8df8b1a6e__f048/w1200.png"
                    : "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTk1PHKS-osQYGiGYkXZuekr6B2_6NHcibtEw&s",
                height: 24,
              ),
            ),
            WithShimmer(
              condition: $selectedBestStore.watch(context) != null,
              width: 190,
              height: 20,
              child: Text(
                $selectedBestStore.watch(context)?.storeRegionName ?? "",
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
  final FlutterSignal<List<ProductsPriceResponse>> $ProductPriceInfos;
  final FlutterSignal<bool> $hasError;
  final FlutterSignal<int> $quantity;

  const _ImageAndTitle({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.$ProductPriceInfos,
    required this.$hasError,
    required this.$quantity,
  });

  void onQuantityChange(int i) {
    $quantity.set(($quantity.value + i).clamp(0, 32));
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      WithShimmer(
                        condition: $ProductPriceInfos.watch(context).isNotEmpty,
                        width: 23,
                        height: 23,
                        child: Text(
                          "${$ProductPriceInfos.value.firstOrNull?.price ?? 0}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      WithShimmer(
                        condition: $ProductPriceInfos.watch(context).isNotEmpty,
                        width: 23,
                        height: 23,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFBEB60),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "save \$${(($ProductPriceInfos.value.firstOrNull?.price ?? 1) / 20).toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  QuantityActions($quantity: $quantity),
                  // Row(
                  //   spacing: 16,
                  //   children: [
                  //     if ($quantity.watch(context) != 0)
                  //       GestureDetector(
                  //         onTap: () {
                  //           onQuantityChange(-1);
                  //         },
                  //         child: Container(
                  //           height: 38,
                  //           width: 38,
                  //           decoration: BoxDecoration(
                  //             boxShadow: [
                  //               BoxShadow(
                  //                 color: Colors.black.withOpacity(0.2),
                  //                 offset: const Offset(0, 0),
                  //                 blurRadius: 6,
                  //                 spreadRadius: 0,
                  //               ),
                  //             ],
                  //             color: Color(0xFF121212),
                  //             borderRadius: BorderRadius.circular(999),
                  //           ),
                  //           child: Icon(Icons.remove, color: Colors.white),
                  //         ),
                  //       ),
                  //     Text(
                  //       $quantity.watch(context) == 0
                  //           ? ""
                  //           : "x${$quantity.value}",
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         onQuantityChange(1);
                  //       },
                  //       child: Container(
                  //         height: 38,
                  //         width: 38,
                  //         decoration: BoxDecoration(
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: Colors.black.withOpacity(0.2),
                  //               offset: const Offset(0, 0),
                  //               blurRadius: 6,
                  //               spreadRadius: 0,
                  //             ),
                  //           ],
                  //           color: Color(0xFF121212),
                  //           borderRadius: BorderRadius.circular(999),
                  //         ),
                  //         child: Icon(Icons.add, color: Colors.white),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuantityActions extends StatefulWidget {
  final FlutterSignal<int> $quantity;

  const QuantityActions({super.key, required this.$quantity});

  @override
  State<QuantityActions> createState() => _QuantityActionsState();
}

class _QuantityActionsState extends State<QuantityActions> {
  final Duration animationDuration = 100.milliseconds;

  void onQuantityChange(int i) {
    widget.$quantity.set((widget.$quantity.value + i).clamp(0, 32));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      width: 134,
      height: 46,
      child: Stack(
        children: [
          if (widget.$quantity.watch(context) > 0)
            Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {
                      onQuantityChange(1);
                    },
                    child: GestureDetector(
                      onTap: () {
                        onQuantityChange(-1);
                      },
                      child: Container(
                        height: 42,
                        width: 42,
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
                  ),
                )
                .animate()
                .fadeIn(duration:animationDuration)
                .slideX(
                  begin: -0.2,
                  end: 0,
                  duration:animationDuration,
                  curve: Curves.easeOut,
                ),
          if (widget.$quantity.watch(context) > 0)
            Align(
              alignment: Alignment.center,
              child:
                  Text(
                        widget.$quantity.watch(context) == 0
                            ? ""
                            : "x${widget.$quantity.value}",
                      )
                      .animate()
                      .fadeIn(duration:animationDuration)
                      .slideX(
                        begin: -1,
                        end: 0,
                        duration:animationDuration,
                        curve: Curves.easeOut,
                      ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                onQuantityChange(1);
              },
              child: Container(
                height: 42,
                width: 42,
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
          ),
        ],
      ),
    );
  }
}
