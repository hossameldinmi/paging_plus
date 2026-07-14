import 'package:paging_plus/paging_plus.dart';
import 'package:test/test.dart';

void main() {
  group('Paging constructor', () {
    test('creates paging with pageNumber and pageSize', () {
      final paging = const Paging(1, 10);
      expect(paging.pageNumber, 1);
      expect(paging.pageSize, 10);
    });

    test('rejects pageNumber below 1', () {
      expect(() => Paging(0, 10), throwsA(isA<AssertionError>()));
    });

    test('rejects pageSize below 1', () {
      expect(() => Paging(1, 0), throwsA(isA<AssertionError>()));
    });
  });

  group('Paging.next input validation', () {
    test('throws ArgumentError for negative itemCount', () {
      expect(() => Paging.next(-1, 10), throwsArgumentError);
    });

    test('throws ArgumentError for pageSize of 0', () {
      expect(() => Paging.next(10, 0), throwsArgumentError);
    });

    test('throws ArgumentError for negative minCountToOptimize', () {
      expect(
        () => Paging.next(10, 10, minCountToOptimize: -1),
        throwsArgumentError,
      );
    });

    test('throws ArgumentError for minPageSize below 1', () {
      expect(() => Paging.next(10, 10, minPageSize: 0), throwsArgumentError);
    });

    test('throws ArgumentError for minPageSize above pageSize', () {
      expect(() => Paging.next(10, 10, minPageSize: 11), throwsArgumentError);
    });
  });

  group('Paging.next basic scenarios', () {
    test('empty Items', () {
      expect(Paging.next(0, 10), const Paging(1, 10));
      expect(Paging.next(0, 10, minCountToOptimize: 5), const Paging(1, 10));
      expect(
        Paging.next(0, 10, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(1, 10),
      );
    });

    test('Items == pageSize', () {
      expect(Paging.next(10, 10), const Paging(2, 10));
      expect(Paging.next(10, 10, minCountToOptimize: 5), const Paging(2, 10));
      expect(
        Paging.next(10, 10, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(2, 10),
      );
    });

    test('partial last page refetched by default', () {
      expect(Paging.next(12, 10), const Paging(2, 10));
      expect(Paging.next(15, 10), const Paging(2, 10));
      expect(Paging.next(12, 10, minCountToOptimize: 5), const Paging(2, 10));
    });

    test('Items == 2 * pageSize', () {
      expect(Paging.next(20, 10), const Paging(3, 10));
    });

    test('last page count below minCountToOptimize refetches last page', () {
      // 12 items / pageSize 10 -> last page holds 2 items, 2 < 5
      expect(
        Paging.next(12, 10, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(2, 10),
      );
      // 11 items / pageSize 10 -> last page holds 1 item, 1 < 5
      expect(
        Paging.next(11, 10, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(2, 10),
      );
    });
  });

  group('Paging.next edge cases', () {
    test('single item returns page 1', () {
      expect(Paging.next(1, 10), const Paging(1, 10));
    });

    test('pageSize of 1', () {
      expect(Paging.next(5, 1), const Paging(6, 1));
    });

    test('large page size with few items', () {
      expect(Paging.next(5, 100), const Paging(1, 100));
    });

    test('one item more than full page', () {
      expect(Paging.next(11, 10), const Paging(2, 10));
    });
  });

  group('Paging.next multiple full pages', () {
    test('3 full pages', () {
      expect(Paging.next(30, 10), const Paging(4, 10));
    });

    test('5 full pages', () {
      expect(Paging.next(50, 10), const Paging(6, 10));
    });

    test('10 full pages', () {
      expect(Paging.next(100, 10), const Paging(11, 10));
    });
  });

  group('Paging.next optimization', () {
    test('picks a divisor of itemCount when one exists (zero duplicates)', () {
      // 15 items: 5 divides 15, so page 4 of size 5 starts exactly at offset 15.
      expect(
        Paging.next(15, 10, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(4, 5),
      );
      // 160 items: largest divisor within [50, 100] is 80.
      expect(
        Paging.next(160, 100, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(3, 80),
      );
      // 190 items: largest divisor within [50, 100] is 95.
      expect(
        Paging.next(190, 100, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(3, 95),
      );
      // 12 items: largest divisor within [5, 10] is 6.
      expect(
        Paging.next(12, 10, refetchPartialLastPage: false),
        const Paging(3, 6),
      );
      // 25 items: largest divisor within [5, 10] is 5.
      expect(
        Paging.next(25, 10, refetchPartialLastPage: false),
        const Paging(6, 5),
      );
      // 16 items: largest divisor within [5, 10] is 8.
      expect(
        Paging.next(16, 10, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(3, 8),
      );
      // 18 items: largest divisor within [5, 10] is 9.
      expect(
        Paging.next(18, 10, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(3, 9),
      );
      // 5 items: largest divisor within [5, 10] is 5.
      expect(
        Paging.next(5, 10, refetchPartialLastPage: false),
        const Paging(2, 5),
      );
    });

    test('minimizes duplicates when no divisor is in range', () {
      // 17 items (prime): best in [5, 10] is size 8 -> offset 16, 1 duplicate.
      expect(
        Paging.next(17, 10, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(3, 8),
      );
      // 23 items (prime): best in [7, 15] is size 11 -> offset 22, 1 duplicate.
      expect(
        Paging.next(23, 15, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(3, 11),
      );
      // 27 items: best in [10, 20] is size 13 -> offset 26, 1 duplicate.
      expect(
        Paging.next(27, 20, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(3, 13),
      );
      // 199 items (prime): best in [50, 100] is size 99 -> offset 198, 1 duplicate.
      // The old algorithm degenerated to Paging(200, 1) here.
      expect(
        Paging.next(199, 100, refetchPartialLastPage: false, minCountToOptimize: 5),
        const Paging(3, 99),
      );
    });

    test('never returns pageSize below minPageSize', () {
      for (int itemCount = 1; itemCount <= 300; itemCount++) {
        final paging = Paging.next(
          itemCount,
          100,
          refetchPartialLastPage: false,
          minPageSize: 50,
        );
        expect(paging.pageSize, greaterThanOrEqualTo(50), reason: 'itemCount=$itemCount');
        expect(paging.pageSize, lessThanOrEqualTo(100), reason: 'itemCount=$itemCount');
      }
    });

    test('explicit minPageSize widens the search range', () {
      // With the floor lowered to 1, size 1 divides 199 exactly.
      expect(
        Paging.next(199, 100, refetchPartialLastPage: false, minPageSize: 1),
        const Paging(200, 1),
      );
    });

    test('no optimization when refetchPartialLastPage is true', () {
      expect(
        Paging.next(160, 100, minCountToOptimize: 5),
        const Paging(2, 100),
      );
      expect(
        Paging.next(190, 100, minCountToOptimize: 5),
        const Paging(2, 100),
      );
    });
  });

  group('Paging.next contract', () {
    test('never skips items and always reaches new ones', () {
      for (int itemCount = 0; itemCount <= 250; itemCount++) {
        for (int pageSize = 1; pageSize <= 25; pageSize++) {
          for (final refetch in [true, false]) {
            final paging = Paging.next(
              itemCount,
              pageSize,
              refetchPartialLastPage: refetch,
            );
            final offset = (paging.pageNumber - 1) * paging.pageSize;
            final reason = 'itemCount=$itemCount pageSize=$pageSize refetch=$refetch -> $paging';
            expect(paging.pageNumber, greaterThanOrEqualTo(1), reason: reason);
            expect(paging.pageSize, greaterThanOrEqualTo(1), reason: reason);
            // No gap: the request starts at or before the first missing item.
            expect(offset, lessThanOrEqualTo(itemCount), reason: reason);
            // Progress: the request reaches past the items already fetched.
            expect(offset + paging.pageSize, greaterThan(itemCount), reason: reason);
          }
        }
      }
    });
  });

  group('Paging equality', () {
    test('equal paging instances are equal with same hashCode', () {
      expect(const Paging(2, 10), equals(const Paging(2, 10)));
      expect(const Paging(3, 15).hashCode, const Paging(3, 15).hashCode);
    });

    test('different pageNumber makes paging unequal', () {
      expect(const Paging(1, 10), isNot(equals(const Paging(2, 10))));
    });

    test('different pageSize makes paging unequal', () {
      expect(const Paging(2, 10), isNot(equals(const Paging(2, 20))));
    });
  });

  group('Paging.toString', () {
    test('includes all properties', () {
      expect(const Paging(5, 25).toString(), 'Paging(pageNumber: 5, pageSize: 25)');
    });
  });
}
