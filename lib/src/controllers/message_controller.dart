import 'dart:io';

import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/message.dart';
import '../services/message_service.dart';

class MessageController extends ControllerMVC {
  bool sendingMessage = false;
  bool needsScroll = false;
  List<Message> messages = [];

  Future<void> listenForMessages(String orderId,
      {DateTime? lastMessage}) async {
    List<Message> mensagens =
        await getMessages(orderId, lastMessage: lastMessage)
            .catchError((error) async {
      throw error;
    });
    setState(() {
      if (lastMessage != null) {
        messages.addAll(mensagens);
      } else {
        messages = mensagens;
      }
      if (mensagens.isNotEmpty) {
        needsScroll = true;
      }
    });
  }

  Future<void> sendNewMessage(String orderId, {String? msg, File? file}) async {
    setState(() {
      sendingMessage = true;
    });
    Message message = await sendMessage(orderId, message: msg, file: file)
        .catchError((error) async {
      setState(() {
        sendingMessage = false;
      });
      throw error;
    });
    setState(() {
      messages.add(message);
      sendingMessage = false;
      needsScroll = true;
    });
  }
}
