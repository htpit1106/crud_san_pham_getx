import 'package:flutter_test/flutter_test.dart';

import 'package:crud_getx_demo/core/error/failure.dart';
import 'package:crud_getx_demo/core/constants/key_constants.dart';
import 'package:crud_getx_demo/core/extensions/string_extensions.dart';
import 'package:crud_getx_demo/core/utils/validator_utils.dart';
import 'package:crud_getx_demo/data/model/entities/category_entity.dart';
import 'package:crud_getx_demo/data/model/entities/product_entity.dart';
import 'package:crud_getx_demo/data/model/response/array_response.dart';

void main() {
  group('ValidatorUtils', () {
    test('isEmptyOrNull returns true for null, empty and whitespace', () {
      expect(ValidatorUtils.isEmptyOrNull(null), isTrue);
      expect(ValidatorUtils.isEmptyOrNull(''), isTrue);
      expect(ValidatorUtils.isEmptyOrNull('   '), isTrue);
    });

    test('validateRequiredField returns message when value is missing', () {
      expect(
        ValidatorUtils.validateRequiredField(null, title: 'Tên'),
        'Tên không được để trống',
      );
      expect(
        ValidatorUtils.validateRequiredField('  ', title: 'Tên'),
        'Tên không được để trống',
      );
    });

    test('validatePassword validates length constraints', () {
      expect(
        ValidatorUtils.validatePassword(null),
        'Mật khẩu không được để trống',
      );
      expect(
        ValidatorUtils.validatePassword('12345'),
        'Mật khẩu phải từ 6–50 ký tự',
      );
      expect(ValidatorUtils.validatePassword('123456'), isNull);
    });

    test('validateMstOrCCCd validates tax id or cccd format', () {
      expect(
        ValidatorUtils.validateMstOrCCCd(null),
        'Mã số thuế không được để trống',
      );
      expect(ValidatorUtils.validateMstOrCCCd('abc'), isNotNull);
      expect(ValidatorUtils.validateMstOrCCCd('123456789012'), isNull);
      expect(ValidatorUtils.validateMstOrCCCd('1234567890-123'), isNull);
    });
  });

  group('StringExtensions', () {
    test('capitalize uppercases first letter only', () {
      expect('flutter'.capitalize(), 'Flutter');
      expect(''.capitalize(), '');
      expect('a'.capitalize(), 'A');
    });

    test('isValidPassword delegates to password regex', () {
      expect('123456'.isValidPassword(), isTrue);
      expect('12345'.isValidPassword(), isFalse);
    });
  });

  group('Model serialization', () {
    test('CategoryEntity converts to and from json', () {
      final category = CategoryEntity(
        id: 1,
        status: 1,
        name: 'Phones',
        createdAt: DateTime.parse('2026-01-01T10:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-02T10:00:00.000Z'),
      );

      final json = category.toJson();
      final parsed = CategoryEntity.fromJson(json);

      expect(parsed.id, 1);
      expect(parsed.status, 1);
      expect(parsed.name, 'Phones');
      expect(parsed.createdAt, category.createdAt);
      expect(parsed.updatedAt, category.updatedAt);
    });

    test('ProductEntity copyWith keeps unchanged fields', () {
      final category = CategoryEntity(id: 2, name: 'Laptop');
      final product = ProductEntity(
        id: 10,
        status: 1,
        name: 'MacBook',
        code: 'MB-01',
        price: 1999.0,
        stock: 5,
        description: 'Test product',
        image: 'image.png',
        category: category,
      );

      final updated = product.copyWith(name: 'MacBook Pro');

      expect(updated.id, 10);
      expect(updated.name, 'MacBook Pro');
      expect(updated.code, 'MB-01');
      expect(updated.category, category);
    });

    test('ArrayResponse parses list and pagination', () {
      final response = ArrayResponse<CategoryEntity>.fromJson({
        'data': [
          {'id': 1, 'name': 'A'},
          {'id': 2, 'name': 'B'},
        ],
        'paging': {'page': 1, 'limit': 10, 'count': 2},
      }, CategoryEntity.fromJson);

      expect(response.data, hasLength(2));
      expect(response.data?.first.name, 'A');
      expect(response.pagination?.page, 1);
      expect(response.pagination?.count, 2);
    });
  });

  group('Failure mapping', () {
    test('mapMessageKeyFailure maps known keys', () {
      expect(
        mapMessageKeyFailure(KeyConstants.errInvalidAccessToken, null),
        isA<ApiFailure>(),
      );
    });

    test('mapExceptionToFailure maps format exception', () {
      final failure = mapExceptionToFailure(const FormatException('bad json'));
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'bad response format');
    });
  });
}
