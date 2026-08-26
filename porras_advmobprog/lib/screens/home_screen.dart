import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'product_screen.dart';
import 'cart_screen.dart';
import 'settings_screen.dart';

import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = 'User'});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: FutureBuilder<bool>(
              future: _logoExists(),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return SizedBox.shrink();
                }
                if (snap.data == true) {
                  return Image.asset(
                    'assets/images/nubdexchange_logo.png',
                    width: 32.w,
                    height: 32.h,
                  );
                }
                return SizedBox.shrink();
              },
            ),
          ),
          elevation: 2,
          title: (_selectedIndex == 0
              ? Image.asset(
                  'assets/images/nubdexchange_logo.png',
                  scale: 11.sp,
                  errorBuilder: (context, error, stackTrace) => CustomText(
                    text: 'Porras',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : CustomText(
                  text: (_selectedIndex == 1)
                      ? 'Cart'
                      : (_selectedIndex == 2)
                      ? 'Profile'
                      : 'Home',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                )),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const <Widget>[
            ProductScreen(),
            CartScreen(),
            SettingsScreen(),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        // Enhancement 2: Hide the chat FloatingActionButton while
        // the user is viewing the cart screen.
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton(
                tooltip: 'Open chat',
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (context) => const SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Chat is available from this screen.'),
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.chat),
              ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTappedBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _selectedIndex,
        ),
      ),
    );
  }

  // Check whether the logo asset is bundled at runtime without crashing the app.
  Future<bool> _logoExists() async {
    try {
      await DefaultAssetBundle.of(
        context,
      ).load('assets/images/nubdexchange_logo.png');
      return true;
    } catch (_) {
      return false;
    }
  }
}
