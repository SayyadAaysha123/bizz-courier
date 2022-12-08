import 'package:delivery_man_app/src/models/order.dart';
import 'package:delivery_man_app/src/models/status_enum.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helper/custom_trace.dart';
import '../services/order_service.dart';

class OrderController extends ControllerMVC {
  bool updatingStatus = false;
  bool loading = false;
  bool hasMoreOrders = false;
  List<Order> orders = [];
  Order? order;

  Future<List<Order>> doGetOrders(
      {int? pageSize, DateTime? dateTimeStart, DateTime? dateTimeEnd}) async {
    setState(() => loading = true);
    Map<String, dynamic> response = await getOrders(
      pageSize: pageSize,
      currentItem: orders.length,
      dateTimeStart: dateTimeStart,
      dateTimeEnd: dateTimeEnd,
    ).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw 'Erro ao buscar pedidos';
    }).whenComplete(() => setState(() => loading = false));
    List<Order> _orders = response['orders'];
    setState(() {
      hasMoreOrders = response['hasMoreOrders'];
      if (pageSize == null) {
        orders = _orders;
      } else {
        orders.addAll(_orders);
      }
      loading = false;
    });
    return _orders;
  }

  Future<Order> doGetOrder(String orderId) async {
    setState(() {
      loading = true;
      order = null;
    });
    Order _order = await getOrder(orderId).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw 'Erro ao buscar pedido, tente novamente';
    }).whenComplete(() => setState(() => loading = false));
    setState(() {
      order = _order;
      loading = false;
    });
    return _order;
  }

  Future<List<Order>> doCheckNewOrder() async {
    setState(() => loading = true);
    List<Order> _orders = await checkNewOrder(
            lastOrder: orders.isEmpty
                ? "0"
                : orders
                    .reduce((value, element) =>
                        double.parse(value.id) > double.parse(element.id)
                            ? value
                            : element)
                    .id)
        .catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw 'Erro ao buscar pedidos';
    }).whenComplete(() => setState(() => loading = false));
    if (_orders.isNotEmpty) {
      setState(() {
        orders.insertAll(0, _orders);
      });
    }
    setState(() => loading = false);
    return _orders;
  }

  Future<Order> doUpdateOrderStatus(
      String orderId, StatusEnum status, String? addressId) async {
    setState(() {
      loading = true;
    });
    Order _order =
        await updateOrderStatus(orderId, status, addressId).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw 'Erro ao atualizar pedido, tente novamente';
    }).whenComplete(() => setState(() => loading = false));
    setState(() {
      order = _order;
      loading = false;
    });
    return _order;
  }

  double getOrdersValue() {
    double total = 0;
    orders.forEach((_order) {
      total += _order.amount;
    });
    return total;
  }

  Future<void> doTransferOrder(String orderId, String? novoEntregadorId) async {
    await transferOrder(orderId, novoEntregadorId).catchError((error) {
      print(CustomTrace(StackTrace.current, message: error.toString()));
      throw 'Erro ao transferir o pedido, tente novamente';
    });
  }
}
