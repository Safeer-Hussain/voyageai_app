import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_feedback.dart';
import '../../../domain/repositories/concierge_repository.dart';

class AiConciergeController extends GetxController {
  final ConciergeRepository _repository;

  AiConciergeController(this._repository);

  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isStreaming = false.obs;
  final RxString transientIndicator = ''.obs;
  final ScrollController scrollController = ScrollController();

  static const List<String> promptShortcuts = [
    'Optimize Today\'s Route to Save Transit Time',
    'Audit My Remaining Daily Trip Budget',
    'Generate Packing Checklist for Destination Altitude',
    'Translate Essential Local Phrases',
  ];

  @override
  void onInit() {
    super.onInit();
    // Pre-populate system greeting
    messages.add({
      'role': 'assistant',
      'content': 'VoyageAI Expedition Concierge initialized. Ready to correlate offline flight gates, evaluate remaining daily burn rate, and calculate high-altitude route optimization.',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> sendPrompt({
    required String prompt,
    required String tripId,
  }) async {
    if (prompt.trim().isEmpty || isStreaming.value) return;

    final userMessage = {
      'role': 'user',
      'content': prompt.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    messages.add(userMessage);
    _scrollToBottom();

    isStreaming.value = true;
    transientIndicator.value = 'Correlating flight schedules, local transit routes & remaining trip budget...';

    // Placeholder message for assistant streaming
    final assistantMessageIndex = messages.length;
    messages.add({
      'role': 'assistant',
      'content': '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    final buffer = StringBuffer();

    try {
      final tokenStream = _repository.streamConciergeResponse(
        prompt: prompt,
        tripId: tripId,
      );

      await for (final token in tokenStream) {
        buffer.write(token);
        messages[assistantMessageIndex] = {
          'role': 'assistant',
          'content': buffer.toString(),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
        messages.refresh();
        _scrollToBottom();
      }
    } catch (_) {
      messages[assistantMessageIndex] = {
        'role': 'assistant',
        'content': 'Unable to complete telemetry synthesis due to an unexpected sensor bridge interruption. Offline backup data preserved.',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      messages.refresh();
      AppFeedback.showError(
        title: 'Concierge Error',
        message: 'Could not complete query streaming.',
      );
    } finally {
      // Strictly guaranteed to reset isStreaming
      isStreaming.value = false;
      transientIndicator.value = '';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void clearChat() {
    messages.clear();
    messages.add({
      'role': 'assistant',
      'content': 'Expedition Concierge reset. Ready for new field inquiries.',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    AppFeedback.showInfo(
      title: 'Concierge Reset',
      message: 'Chat history has been cleared.',
    );
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
