import 'package:flutter/material.dart';
import 'package:my_app/helpers/custom_route.dart';
import 'package:my_app/providers/auth.dart';
import 'package:my_app/providers/cart.dart';
import 'package:my_app/providers/orders.dart';
import 'package:my_app/providers/products.dart';
import 'package:my_app/screens/cart_screen.dart';
import 'package:my_app/screens/edit_product_screen.dart';
import 'package:my_app/screens/order_screen.dart';
import 'package:my_app/screens/product_detail_screen.dart';
import 'package:my_app/screens/products_overview_screen.dart';
import 'package:my_app/screens/splash_screen.dart';
import 'package:my_app/screens/user_products_screen.dart';
import 'package:my_app/screens/auth_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page 2'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => Auth()),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (context) => Products(null, null, []),
          update: (ctx, auth, previousProducts) =>
              Products(auth.token, auth.userId, previousProducts!.items),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: ((context) => Orders(null, null, [])),
          update: (ctx, auth, previousOrders) => Orders(auth.token, auth.userId,
              previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, child) => MaterialApp(
          title: 'My Shop',
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          theme: ThemeData(
              fontFamily: 'Lato',
              // pageTransitionsTheme: PageTransitionsTheme(builders: {
              //   TargetPlatform.android: CustomPageTransitionBuild(),
              //   TargetPlatform.iOS: CustomPageTransitionBuild(),
              // }),
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                  .copyWith(secondary: Colors.deepOrange)),
          routes: {
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrderScreen.routeName: (context) => OrderScreen(),
            UserProductsScreen.routeName: (context) => UserProductsScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen(),
            AuthScreen.routeName: (context) => AuthScreen(),
          },
        ),
      ),
    );
  }
}
