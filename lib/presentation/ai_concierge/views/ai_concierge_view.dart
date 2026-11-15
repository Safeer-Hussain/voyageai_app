import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../itinerary/controllers/itinerary_controller.dart';
import '../controllers/ai_concierge_controller.dart';

class AiTravelConciergeView extends StatefulWidget {
  const AiTravelConciergeView({super.key});

  @override
  State<AiTravelConciergeView> createState() => _AiTravelConciergeViewState();
}

class _AiTravelConciergeViewState extends State<AiTravelConciergeView> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _sendCurrentPrompt() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    final conciergeCtrl = Get.find<AiConciergeController>();
    final itineraryCtrl = Get.find<ItineraryController>();
    final tripId = itineraryCtrl.activeTrip.value?.id ?? 'trip_hunza_7d';

    _inputController.clear();
    conciergeCtrl.sendPrompt(prompt: text, tripId: tripId);
  }

  @override
  Widget build(BuildContext context) {
    final conciergeCtrl = Get.find<AiConciergeController>();
    final itineraryCtrl = Get.find<ItineraryController>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // Prompt shortcuts horizontal scroll
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AiConciergeController.promptShortcuts.map((shortcut) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      label: Text(
                        shortcut,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      avatar: Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      onPressed: () {
                        final tripId =
                            itineraryCtrl.activeTrip.value?.id ??
                            'trip_hunza_7d';
                        conciergeCtrl.sendPrompt(
                          prompt: shortcut,
                          tripId: tripId,
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Message stream
          Expanded(
            child: Obx(() {
              return ListView.builder(
                controller: conciergeCtrl.scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount:
                    conciergeCtrl.messages.length +
                    (conciergeCtrl.isStreaming.value &&
                            conciergeCtrl.transientIndicator.value.isNotEmpty
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  if (index == conciergeCtrl.messages.length) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              conciergeCtrl.transientIndicator.value,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final msg = conciergeCtrl.messages[index];
                  final isUser = msg['role'] == 'user';
                  final content = msg['content'] as String;

                  if (content.isEmpty) return const SizedBox.shrink();

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.82,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                        border: Border.all(
                          color: isUser
                              ? colorScheme.primary.withAlpha(50)
                              : colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isUser ? Icons.person : Icons.psychology,
                                size: 14,
                                color: isUser
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isUser ? 'Traveler' : 'VoyageAI Concierge',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isUser
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            content,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              color: isUser
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Bottom Input Bar
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    tooltip: 'Reset Conversation',
                    onPressed: conciergeCtrl.clearChat,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText:
                            'Inquire route telemetry, budget, altitude...',
                        hintStyle: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendCurrentPrompt(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final streaming = conciergeCtrl.isStreaming.value;
                    return FloatingActionButton.small(
                      heroTag: 'fab_ai_concierge_clear',
                      onPressed: streaming ? null : _sendCurrentPrompt,
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      elevation: 1,
                      child: streaming
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.arrow_upward, size: 20),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
