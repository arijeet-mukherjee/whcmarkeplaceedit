import 'dart:convert';

import 'package:answer_me/models/Conversation.dart';
import 'package:answer_me/models/Message.dart';
import 'package:answer_me/providers/BaseProvider.dart';
import 'package:answer_me/services/ApiRepository.dart';
import 'package:flutter/material.dart';

class ConversationProvider extends BaseProvider {
  List<Conversation> _concersations = [];

  List<Conversation> get concersations => _concersations;

  Future<List<Conversation>> getConversations(BuildContext context) async {
    if (_concersations.isNotEmpty) return _concersations;
    setBusy(true);
    var response = await ApiRepository().getConversations(context);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      data['data'].forEach((conversation) =>
          _concersations.add(Conversation.fromJson(conversation)));
      print(response.body);
      notifyListeners();
      setBusy(false);
    }
    return _concersations;
  }

  resetConversations() {
    _concersations = [];
    notifyListeners();
  }

  Future<Conversation> createConversation(
      BuildContext context, int secondUserId, Message message) async {
    setBusy(true);
    var response = await ApiRepository()
        .createConversation(context, secondUserId, message);
    print(response.statusCode);
    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      // print('data: ${data['data']}');
      // _concersations.add(Conversation.fromJson(data['data']));
      // print(data);
      await resetConversations();
      await getConversations(context);
      // addMessageToConversation(
      //     data['data']['id'], Message.fromJson(data['data']['messages'][0]));
      print(response.body);
      notifyListeners();
      setBusy(false);
      return Conversation.fromJson(data['data']);
    }
    return null;
  }

  Future<void> storeMessage(BuildContext context, Message message) async {
    setBusy(true);
    var response = await ApiRepository().storeMessage(context, message);
    print(message.conversationId);
    print(response.body);
    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      print('message is: ${data['data']}');

      setBusy(false);
      addMessageToConversation(
          message.conversationId, Message.fromJson(data['data']));
      notifyListeners();
    }
    setBusy(false);
  }

  Future<void> deleteConversation(
      BuildContext context, int conversationId) async {
    setBusy(true);
    print('conversationId :$conversationId');
    var response =
        await ApiRepository().deleteConversation(context, conversationId);
    // print(response.body);
    if (response.statusCode == 201) {
      setBusy(false);
      removeConversation(conversationId);
    }
    setBusy(false);
  }

  addMessageToConversation(int conversationId, Message message) {
    var conversation = _concersations
        .firstWhere((conversation) => conversation.id == conversationId);
    conversation.messages.add(message);
    toTheTop(conversation);
    notifyListeners();
  }

  removeConversation(int conversationId) {
    _concersations.removeWhere((conv) => conv.id == conversationId);
    notifyListeners();
  }

  toTheTop(Conversation conversation) {
    var index = _concersations.indexOf(conversation);

    for (var i = index; i > 0; i--) {
      var x = _concersations[i];
      _concersations[i] = _concersations[i - 1];
      _concersations[i - 1] = x;
    }
  }
}
