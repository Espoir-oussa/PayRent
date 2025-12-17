import 'package:flutter_test/flutter_test.dart';
import 'package:payrent/core/services/appwrite_service.dart';

void main() {
  group('AppwriteService.normalizePermissions', () {
    final svc = AppwriteService();

    test('normalizes user permission strings and contains user id', () {
      final userId = '693efd725c7406147a34';
      final raw = [
        'any',
        'users',
        'user: $userId',
      ];

      final perms = svc.normalizePermissions(raw);

      expect(perms, isNotNull);
      expect(perms!.any((p) => p.contains(userId)), isTrue);
      // Ensure no permission contains ': ' (colon followed by space)
      expect(perms.every((p) => !p.contains(': ')), isTrue);
    });

    test('returns null when input is null', () {
      final perms = svc.normalizePermissions(null);
      expect(perms, isNull);
    });
  });
}
