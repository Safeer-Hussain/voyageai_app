abstract class ConciergeRepository {
  Stream<String> streamConciergeResponse({
    required String prompt,
    required String tripId,
  });
}
