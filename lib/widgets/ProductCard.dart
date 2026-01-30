import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          padding: EdgeInsetsGeometry.all(8),
          height: 200,
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
            children: [_ImageAndTitle(), _BestPriceHero()],
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _OtherStoresList(isExpanded: true,),
            ),
          ],
        ),
      ],
    );
  }
}

class _OtherStoresList extends StatelessWidget {
  final bool isExpanded;

  const _OtherStoresList({
    super.key, required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    if (isExpanded) {
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
      return Placeholder();
    }
  }
}

  class _OtherStoreItem extends StatelessWidget {
  const _OtherStoreItem({
  super.key,
  });

  @override
  Widget build(BuildContext context) {
  return Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
  Row(
  spacing: 4,
  children: [
  Container(color: Colors.red, width: 24, height: 24),
  Text("Woolworths Northlands"),
  ],
  ),
  Column(
  spacing: 2,
  children: [
  Text("\$2.00", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),),
  Container(
  decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(8),
  color: Color(0xFFFAE6E2),
  ),
  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
  child: Text("+0.33", style: TextStyle(fontSize: 10, color: Color(0xFFC42921), fontWeight: FontWeight.w500)),
  ),
  ],
  ),
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
  child: Text(
  "Best Price",
  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
  width: 38,
  ),
  Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text("PAK'nSave", style: TextStyle(fontSize: 14)),
  Text("Botany", style: TextStyle(fontSize: 12)),
  ],
  ),
  ],
  ),
  Text("\$1.67 ea", style: TextStyle(fontWeight: FontWeight.w500),),
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
  const _ImageAndTitle();

  @override
  Widget build(BuildContext context) {
  return Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Align(
  alignment: AlignmentGeometry.topLeft,
  child: Image.network(
  width: 90,
  height: 90,
  "https://assets.woolworths.com.au/images/2010/282819.jpg?impolicy=wowcdxwbjbx&w=400&h=400",
  ),
  ),
  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Text(
  "Anchor Milk Standard Blue (2L)",
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  ),
  Text("Cheapest near you \$1.67 ea", style: TextStyle(fontSize: 14)),
  ],
  ),
  ],
  );
  }
  }
