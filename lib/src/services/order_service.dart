import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../helper/custom_trace.dart';
import '../helper/helper.dart';
import '../models/order.dart';
import '../models/status_enum.dart';

Future<Map<String, dynamic>> getOrders(
    {int? pageSize,
    int currentItem = 0,
    DateTime? dateTimeStart,
    DateTime? dateTimeEnd}) async {
  Map<String, String> queryParameters = {};
  if (pageSize != null) {
    queryParameters.addAll(
        {'limit': pageSize.toString(), 'current_item': currentItem.toString()});
  }
  if (dateTimeStart != null) {
    queryParameters.addAll({
      'datetime_start': dateTimeStart.toString(),
    });
  }
  if (dateTimeEnd != null) {
    queryParameters.addAll({'datetime_end': dateTimeEnd.toString()});
  }
  var response = await http.get(
      Helper.getUri('driver/orders', queryParam: queryParameters),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    List<Order> orders = jsonDecode(response.body)['data']['orders']
        .map((order) => Order.fromJSON(order))
        .toList()
        .cast<Order>();
    bool hasMoreOrders = jsonDecode(response.body)['data']['has_more_orders'];

    return {'hasMoreOrders': hasMoreOrders, 'orders': orders};
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<List<Order>> checkNewOrder({required String lastOrder}) async {
  Map<String, String> queryParameters = {};
  queryParameters.addAll({'order_id': lastOrder});
  var response = await http.get(
      Helper.getUri('driver/checkNewOrder', queryParam: queryParameters),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    return jsonDecode(response.body)['data']
        .map((order) => Order.fromJSON(order))
        .toList()
        .cast<Order>();
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<Order> getOrder(String orderId) async {
  var response = await http
      .get(Helper.getUri('driver/orders/$orderId'), headers: <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  }).timeout(const Duration(seconds: 15));
  print(response.request!.url.toString());
  if (response.statusCode == HttpStatus.ok) {
    return Order.fromJSON(json.decode(response.body)['data']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<Order> updateOrderStatus(
    String orderId, StatusEnum status, String? addressId) async {
  var response = await http
      .patch(
        Helper.getUri('driver/updateStatus'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'order_id': orderId,
          'status': status.originalName,
          'delivery_address_id': addressId ?? '',
        }),
      )
      .timeout(const Duration(seconds: 15));
  print(response.body);
  if (response.statusCode == HttpStatus.ok) {
    return Order.fromJSON(json.decode(response.body)['data']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}

Future<bool> transferOrder(String orderId, String? novoEntregadorId) async {
  var response = await http
      .post(
        Helper.getUri('driver/order/transferOrder'),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'order_id': orderId,
          'novo_entregador_id': novoEntregadorId ?? '',
        }),
      )
      .timeout(const Duration(seconds: 15));

  if (response.statusCode == HttpStatus.ok) {
    print(response.body);
    return true;
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}
