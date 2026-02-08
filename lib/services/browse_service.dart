import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:grocery_api/api.dart';
import 'package:groceryapp/services/api_service.dart';

class BrowseService {
  final int batchSize = 2;
  final List<_QueuedRequest> _queue = [];
  bool _isProcessing = false;
  final _apiService = GetIt.I<ApiService>();

  Future<List<ProductsPriceResponse>> enqueue(List<ProductsPriceRequest> request) {
    final completer = Completer<List<ProductsPriceResponse>>();

    _queue.add(_QueuedRequest(request: request, completer: completer));

    _tryProcess();

    return completer.future;
  }

  void _tryProcess() {
    if (_isProcessing) return;
    if (_queue.length < batchSize) return;

    _isProcessing = true;

    final batch = _queue.take(batchSize).toList();
    _queue.removeRange(0, batchSize);

    _processBatch(batch);
  }

  Future<void> _processBatch(List<_QueuedRequest> batch) async {
    try {
      final ids = batch.expand((e) => e.request).toList();

      // 🔥 single API call
      final results = await _apiService.productApi.productPriceAsync(
        productsPriceRequest: ids,
      );
      print("@> DONE API");

      for (final req in batch) {
        var x = results
            ?.where((c) => c.productId == req.request.first.productId).toList();
        req.completer.complete(x);
      }
    } catch (e, st) {
      for (final req in batch) {
        req.completer.completeError(e, st);
      }
    } finally {
      _isProcessing = false;
      _tryProcess(); // process next batch if queued
    }
  }
}

class _QueuedRequest {
  final List<ProductsPriceRequest> request;
  final Completer<List<ProductsPriceResponse>> completer;

  _QueuedRequest({required this.request, required this.completer});
}
