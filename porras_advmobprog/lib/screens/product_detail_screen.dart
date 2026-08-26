import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product.dart';
import '../widgets/custom_text.dart';

// Enhancement 2: Product details page shown when a product card is tapped
class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: product.title, fontSize: 18.sp, fontWeight: FontWeight.w600),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Hero(
                tag: 'product_${product.id}',
                child: Image.network(
                  product.thumbnail,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.image, size: 48.sp),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            CustomText(text: product.title, fontSize: 20.sp, fontWeight: FontWeight.bold),
            SizedBox(height: 8.h),
            CustomText(text: '\$${product.price.toStringAsFixed(2)}', fontSize: 18.sp, fontWeight: FontWeight.w600),
            SizedBox(height: 12.h),
            CustomText(text: product.description, fontSize: 14.sp),
          ],
        ),
      ),
    );
  }
}
