import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/services/api_service.dart';

void main() {
  test('Base URL loads from .env', () {
    final base = ApiService.base;
    expect(base.isNotEmpty, true);
  });
}
