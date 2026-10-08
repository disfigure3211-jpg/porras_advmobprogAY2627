import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'product_screen.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

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

  void _onTappedBottomBar(int value) {
    const pageIndexes = [0, 1, 3];
    _onTappedBar(pageIndexes[value]);
  }

  int get _bottomBarIndex {
    if (_selectedIndex >= 2) return _selectedIndex == 2 ? 1 : 2;
    return _selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: SvgPicture.asset(
              'assets/icons/NU_shield.svg',
              width: 32.w,
              height: 32.h,
              fit: BoxFit.contain,
            ),
          ),
          elevation: 2,
          title: (_selectedIndex == 0
              ? CustomText(
                  text: 'HellBExchange',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                )
              : CustomText(
                  text: (_selectedIndex == 1)
                      ? 'Cart'
                      : (_selectedIndex == 2)
                      ? 'Chats'
                      : 'Profile',
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
            ChatScreen(),
            ProfileScreen(),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () => _onTappedBar(2),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 6,
                shape: const CircleBorder(),
                child: const Icon(Icons.chat_bubble_outline),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onTappedBottomBar,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'Shop'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          currentIndex: _bottomBarIndex,
        ),
      ),
    );
  }
}
