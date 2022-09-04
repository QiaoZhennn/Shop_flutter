import 'package:flutter/material.dart';
import 'package:my_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../widgets/order_item.dart' as widget;

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);
  static const String routeName = '/order_screen';

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future _ordersFuture = Future.value();
  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }
  @override
  void initState() {
    // insure only fetch once
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Your Orders')),
        drawer: AppDrawer(),
        // recommend to use FutureBuilder
        body: FutureBuilder(
            future: _ordersFuture,
            builder: (ctx, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (dataSnapshot.error != null) {
                // do error handing
                return Center(
                  child: Text("An error occured"),
                );
              } else {
                return Consumer<Orders>(
                    builder: (context, orderData, child) => ListView.builder(
                          itemCount: orderData.orders.length,
                          itemBuilder: (context, index) =>
                              widget.OrderItem(orderData.orders[index]),
                        ));
              }
            }));
  }
}
