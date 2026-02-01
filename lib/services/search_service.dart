class ProductPriceInfo {
  final double originalPrice;
  final double salePrice;

  ProductPriceInfo({required this.originalPrice, required this.salePrice});

  ProductPriceInfo.fromJson(Map<String, dynamic> json)
      : originalPrice = json['originalPrice'] as double,
        salePrice = json['salePrice'] as double;
}

class ProductSearchService {
  final Map<String, List<ProductPriceInfo>> existingFetchedProductsPrices = {};
}