import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grocery_api/api.dart';
import 'package:groceryapp/services/http_service.dart';
import 'package:groceryapp/services/search_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:signals/signals_flutter.dart';

class ProductCard extends StatefulWidget {
  final String title;
  final String imgUrl;

  final List<CreateSessionWithRegionResponse> sessions;
  final String priceFetchUlr;

  const ProductCard({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.priceFetchUlr,
    required this.sessions,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final $productPriceInfo = signal<List<ProductPriceInfo>>([]);
  final $hasError = signal(false);
  final _httpService = GetIt.I<HttpService>();
  final _productSearchService = GetIt.I<ProductSearchService>();

  @override
  void initState() {
    // print("@> INIT STATE ${widget.title}");
    _getPricesForRegionsAsync();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getPricesForRegionsAsync() async {
    var existingProductPrice = _productSearchService
        .existingFetchedProductsPrices[widget.priceFetchUlr];
    if (existingProductPrice != null) {
      $productPriceInfo.set(existingProductPrice);
      return;
    }

    List<Future<void>> tasks = [];
    List<ProductPriceInfo> priceForRegions = [];

    for (final session in widget.sessions) {
      final task = () async {
        try {
          await _httpService.get(
            widget.priceFetchUlr,
            headers: {
              "Accept": "application/json",
              "User-Agent": "api-client/1.0",
              "x-requested-with": "OnlineShopping.WebApp",
            },
            cookies: {
              "ASP.NET_SessionId": session.sessionId,
              "aga": session.aga,
            },
            fromJson: (json) {
              priceForRegions.add(ProductPriceInfo.fromJson(json['price']));
            },
          );
        } catch (e, st) {
          // 👇 log + continue, do NOT rethrow
          debugPrint(
            'Price fetch failed for ${widget.priceFetchUlr} '
            '(session=${session.sessionId}): $e',
          );
          $hasError.set(true);
        }
      }();

      tasks.add(task);
    }

    await _httpService.withWoolworthsThrottling(() async {
      print("1 Loading prices for [${widget.title}]...");
      await Future.wait(tasks);

      List<ProductPriceInfo> sortedByEffective = List.from(priceForRegions)
        ..sort((a, b) {
          double effectiveA = a.salePrice < a.originalPrice
              ? a.salePrice
              : a.originalPrice;
          double effectiveB = b.salePrice < b.originalPrice
              ? b.salePrice
              : b.originalPrice;
          return effectiveA.compareTo(effectiveB);
        });

      _productSearchService.existingFetchedProductsPrices[widget
              .priceFetchUlr] =
          sortedByEffective;
      $productPriceInfo.set(sortedByEffective);
      print("2 Loaded [${widget.title}]");
    });
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
            height: 160,
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
                  title: widget.title,
                  imgUrl: widget.imgUrl,
                  $ProductPriceInfo: $productPriceInfo,
                  $hasError: $hasError,
                ),
                _BestPriceHero(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
            child: Column(
              children: [
                Text(
                  "Other stores",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          _OtherStores(),
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: Color(0xFF121212),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, color: Colors.white),
                Text("Add to cart", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
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
  const _BestPriceHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          spacing: 4,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsetsGeometry.only(top: 8, bottom: 1),
                child: Text(
                  "Best Price",
                  style: TextStyle(
                    height: 0.8,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Image.network(
                            "https://images.squarespace-cdn.com/content/v1/5bfb6ce7b10598545932984f/1561073211525-I3H6TWVK0U3PZ9DNTRQ3/PaknSave.png",
                            width: 28,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("PAK'nSave", style: TextStyle(fontSize: 14, height: 0.95)),
                              Text("Botany", style: TextStyle(fontSize: 12, height: 0.95)),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        "\$1.67 ea",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageAndTitle extends StatelessWidget {
  final String title;
  final String imgUrl;
  final FlutterSignal<List<ProductPriceInfo>> $ProductPriceInfo;
  final FlutterSignal<bool> $hasError;

  const _ImageAndTitle({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.$ProductPriceInfo,
    required this.$hasError,
  });

  double getPriceToDisplay() {
    var lowestPrice = $ProductPriceInfo.value.first;
    if (lowestPrice.salePrice < lowestPrice.originalPrice) {
      return lowestPrice.salePrice;
    } else {
      return lowestPrice.originalPrice;
    }
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              $ProductPriceInfo.watch(context).isEmpty && !$hasError.watch(context)
                  ? Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: 188,
                        height: 17,
                      ),
                    )
                  : $hasError.value
                  ? Text(
                      "Sorry, something went wrong. Please try again.",
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    )
                  : Text(
                      "Cheapest near you \$${getPriceToDisplay()} ea",
                      style: TextStyle(fontSize: 12),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}
