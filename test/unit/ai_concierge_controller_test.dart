import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:voyage_ai_app/domain/repositories/concierge_repository.dart';
import 'package:voyage_ai_app/presentation/ai_concierge/controllers/ai_concierge_controller.dart';

class MockConciergeRepository implements ConciergeRepository {
  bool shouldThrow = false;

  @override
  Stream<String> streamConciergeResponse({
    required String prompt,
    required String tripId,
  }) async* {
    if (shouldThrow) {
      throw Exception('Simulated telemetry failure');
    }
    yield 'Field ';
    yield 'analysis ';
    yield 'complete.';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockConciergeRepository mockRepo;
  late AiConciergeController controller;

  setUp(() {
    Get.testMode = true;
    mockRepo = MockConciergeRepository();
    controller = AiConciergeController(mockRepo);
    controller.onInit();
  });

  group('AiConciergeController Unit Tests', () {
    test(
      'Initializes with default greeting message and isStreaming as false',
      () {
        expect(controller.messages.length, 1);
        expect(controller.messages.first['role'], 'assistant');
        expect(controller.isStreaming.value, false);
      },
    );

    test('sendPrompt streams tokens and resets isStreaming to false upon completion', () async {
      await controller.sendPrompt(
        prompt: 'Optimize route',
        tripId: 'trip_hunza_7d',
      );

      expect(controller.isStreaming.value, false);
      expect(controller.messages.length, 3);
      expect(controller.messages[1]['role'], 'user');
      expect(controller.messages[2]['role'], 'assistant');
      expect(controller.messages[2]['content'], 'Field analysis complete.');
    });

    test('isStreaming is strictly guaranteed to reset to false in finally block on exception', () async {
      mockRepo.shouldThrow = true;

      await controller.sendPrompt(
        prompt: 'Trigger fault',
        tripId: 'trip_hunza_7d',
      );

      expect(controller.isStreaming.value, false);
      expect(controller.transientIndicator.value, isEmpty);
      expect(
        controller.messages.last['content'],
        contains('Unable to complete telemetry synthesis'),
      );
    });
  });
}
