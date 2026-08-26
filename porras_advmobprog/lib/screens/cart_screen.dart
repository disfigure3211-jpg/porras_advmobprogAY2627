import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../models/cart.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';
import 'product_detail_screen.dart';

// Enhancement 1: Cart screen displays the user's cart and allows
// cart products to navigate to the existing product detail screen.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late Future<Cart?> _cartFuture;
  final Map<int, int> _quantities = {};

  @override
  void initState() {
    super.initState();
    _cartFuture = CartService().getCartByUser(cartUserId);
  }

  void _retry() {
    setState(() {
      _cartFuture = CartService().getCartByUser(cartUserId);
    });
  }

  void _changeQuantity(CartProduct product, int change) {
    final currentQuantity = _quantities[product.id] ?? product.quantity;
    final nextQuantity = (currentQuantity + change).clamp(1, 999);
    setState(() => _quantities[product.id] = nextQuantity);
  }

  double _discountedUnitPrice(CartProduct product) {
    return product.price * (1 - product.discountPercentage / 100);
  }

  void _confirmOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order confirmed for this demo cart.')),
    );
  }

  Future<void> _openProduct(CartProduct cartProduct) async {
    try {
      final product = await ProductService().getById(cartProduct.id);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: Product.sample(
              id: cartProduct.id,
              title: cartProduct.title,
              price: cartProduct.price,
              thumbnail: cartProduct.thumbnail,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Cart?>(
        future: _cartFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageState(
              message: 'Could not load your cart.',
              action: ElevatedButton(
                onPressed: _retry,
                child: const Text('Retry'),
              ),
            );
          }

          final cart = snapshot.data;
          if (cart == null || cart.products.isEmpty) {
            return const _MessageState(message: 'Your cart is empty.');
          }

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text:
                        '${cart.totalProducts} products (${cart.totalQuantity} items)',
                    fontSize: 14.sp,
                  ),
                  CustomText(
                    text: '\$${_cartTotal(cart).toStringAsFixed(2)}',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ...cart.products.map(
                (product) => Card(
                  margin: EdgeInsets.only(bottom: 10.h),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12.r),
                    onTap: () => _openProduct(product),
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 84.w,
                            height: 84.w,
                            child: Image.network(
                              product.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomText(
                                  text: product.title,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 5.h),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Decrease quantity',
                                      onPressed: () =>
                                          _changeQuantity(product, -1),
                                      icon: const Icon(Icons.remove),
                                      color: Colors.pinkAccent,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    Text(
                                      '${_quantities[product.id] ?? product.quantity}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Increase quantity',
                                      onPressed: () =>
                                          _changeQuantity(product, 1),
                                      icon: const Icon(Icons.add),
                                      color: Colors.pinkAccent,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)} each',
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${(_discountedUnitPrice(product) * (_quantities[product.id] ?? product.quantity)).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (product.discountPercentage > 0)
                                Text(
                                  '${product.discountPercentage.toStringAsFixed(0)}% off',
                                  style: TextStyle(fontSize: 11.sp),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Divider(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cart total'),
                  Text(
                    '\$${_cartTotal(cart).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmOrder,
                  child: const Text('Confirm Order'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _cartTotal(Cart cart) {
    return cart.products.fold(0, (total, product) {
      final quantity = _quantities[product.id] ?? product.quantity;
      return total + (_discountedUnitPrice(product) * quantity);
    });
  }
}

class _MessageState extends StatelessWidget {
  final String message;
  final Widget? action;

  const _MessageState({required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(text: message, fontSize: 15.sp),
          if (action != null) ...[SizedBox(height: 12.h), action!],
        ],
      ),
    );
  }
}
