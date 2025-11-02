import 'package:paging_plus/src/paging.dart';
import 'package:test/test.dart';

void main() {
  group('Paging.next basic scenarios', () {
    test('empty Items', () {
      final pagination0 = Paging.next(0, 10);
      final pagination1 = Paging.next(0, 10, true, 5);
      final pagination2 = Paging.next(0, 10, false, 5);

      final expected = const Paging(1, 10);

      expect(pagination0, expected);
      expect(pagination1, expected);
      expect(pagination2, expected);
    });

    test('Items == pageSize', () {
      final pagination0 = Paging.next(10, 10);
      final pagination1 = Paging.next(10, 10, true, 5);
      final pagination2 = Paging.next(10, 10, false, 5);

      final expected = const Paging(2, 10);

      expect(pagination0, expected);
      expect(pagination1, expected);
      expect(pagination2, expected);
    });

    test('Items == 1.2 pageSize, fetchLastIfHasRemaining=true', () {
      final pagination0 = Paging.next(12, 10);
      final pagination1 = Paging.next(12, 10, true, 5);

      final expected = const Paging(2, 10);

      expect(pagination0, expected);
      expect(pagination1, expected);
    });

    test('Items == 1.5 pageSize, fetchLastIfHasRemaining=true', () {
      final pagination = Paging.next(15, 10);

      final expected = const Paging(2, 10);

      expect(pagination, expected);
    });

    test('Items == 2 * pageSize', () {
      final pagination = Paging.next(20, 10);

      final expected = const Paging(3, 10);

      expect(pagination, expected);
    });

    test('latestCount < minimum, fetchLastIfHasRemaining=false', () {
      final pagination = Paging.next(12, 10, false, 5);

      final expected = const Paging(2, 10);

      expect(pagination, expected);
    });

    test('latestCount = minimum, fetchLastIfHasRemaining=false', () {
      final pagination = Paging.next(15, 10, false, 5);

      final expected = const Paging(4, 5);

      expect(pagination, expected);
    });

    test('latestCount > minimum, fetchLastIfHasRemaining=false', () {
      expect(Paging.next(160, 100, false, 5), const Paging(5, 40));
      expect(Paging.next(190, 100, false, 5), const Paging(20, 10));
    });
  });

  group('Paging constructor', () {
    test('creates paging with pageNumber and pageSize', () {
      final paging = const Paging(1, 10);
      expect(paging.pageNumber, 1);
      expect(paging.pageSize, 10);
    });

    test('creates paging with different values', () {
      final paging = const Paging(5, 25);
      expect(paging.pageNumber, 5);
      expect(paging.pageSize, 25);
    });
  });

  group('Paging.next edge cases', () {
    test('single item returns page 1', () {
      final paging = Paging.next(1, 10);
      expect(paging.pageNumber, 1);
      expect(paging.pageSize, 10);
    });

    test('pageSize of 1', () {
      final paging = Paging.next(5, 1);
      expect(paging.pageNumber, 6);
      expect(paging.pageSize, 1);
    });

    test('large page size with few items', () {
      final paging = Paging.next(5, 100);
      expect(paging.pageNumber, 1);
      expect(paging.pageSize, 100);
    });

    test('one item more than full page', () {
      final paging = Paging.next(11, 10);
      expect(paging.pageNumber, 2);
      expect(paging.pageSize, 10);
    });
  });

  group('Paging.next multiple pages', () {
    test('3 full pages', () {
      final paging = Paging.next(30, 10);
      expect(paging.pageNumber, 4);
      expect(paging.pageSize, 10);
    });

    test('5 full pages', () {
      final paging = Paging.next(50, 10);
      expect(paging.pageNumber, 6);
      expect(paging.pageSize, 10);
    });

    test('10 full pages', () {
      final paging = Paging.next(100, 10);
      expect(paging.pageNumber, 11);
      expect(paging.pageSize, 10);
    });
  });

  group('Paging.next various page sizes', () {
    test('pageSize 5', () {
      final paging = Paging.next(12, 5);
      expect(paging.pageNumber, 3);
      expect(paging.pageSize, 5);
    });

    test('pageSize 20', () {
      final paging = Paging.next(40, 20);
      expect(paging.pageNumber, 3);
      expect(paging.pageSize, 20);
    });

    test('pageSize 50', () {
      final paging = Paging.next(100, 50);
      expect(paging.pageNumber, 3);
      expect(paging.pageSize, 50);
    });

    test('pageSize 100', () {
      final paging = Paging.next(250, 100);
      expect(paging.pageNumber, 3);
      expect(paging.pageSize, 100);
    });
  });

  group('Paging.next with partial pages', () {
    test('25% filled page', () {
      final paging = Paging.next(25, 100);
      expect(paging.pageNumber, 1);
      expect(paging.pageSize, 100);
    });

    test('75% filled page', () {
      final paging = Paging.next(75, 100);
      expect(paging.pageNumber, 1);
      expect(paging.pageSize, 100);
    });
  });

  group('Paging.next optimization algorithm', () {
    test('optimization with 160 items, pageSize 100', () {
      final paging = Paging.next(160, 100, false, 5);
      expect(paging.pageNumber, 5);
      expect(paging.pageSize, 40);
    });

    test('optimization with 190 items, pageSize 100', () {
      final paging = Paging.next(190, 100, false, 5);
      expect(paging.pageNumber, 20);
      expect(paging.pageSize, 10);
    });

    test('no optimization when fetchLastIfHasRemaining is true', () {
      final paging1 = Paging.next(160, 100, true, 5);
      expect(paging1.pageNumber, 2);
      expect(paging1.pageSize, 100);

      final paging2 = Paging.next(190, 100, true, 5);
      expect(paging2.pageNumber, 2);
      expect(paging2.pageSize, 100);
    });
  });

  group('Paging props', () {
    test('props includes pageNumber and pageSize', () {
      final paging = const Paging(3, 20);
      expect(paging.props, [3, 20]);
    });

    test('props for different values', () {
      final paging = const Paging(1, 10);
      expect(paging.props, [1, 10]);
    });
  });

  group('Paging equality', () {
    test('equal paging instances are equal', () {
      final paging1 = const Paging(2, 10);
      final paging2 = const Paging(2, 10);
      expect(paging1, equals(paging2));
    });

    test('different pageNumber makes paging unequal', () {
      final paging1 = const Paging(1, 10);
      final paging2 = const Paging(2, 10);
      expect(paging1, isNot(equals(paging2)));
    });

    test('different pageSize makes paging unequal', () {
      final paging1 = const Paging(2, 10);
      final paging2 = const Paging(2, 20);
      expect(paging1, isNot(equals(paging2)));
    });

    test('hashCode is consistent for equal instances', () {
      final paging1 = const Paging(3, 15);
      final paging2 = const Paging(3, 15);
      expect(paging1.hashCode, equals(paging2.hashCode));
    });
  });

  group('Paging.toString', () {
    test('toString for different values', () {
      final paging = const Paging(5, 25);
      final pagingString = paging.toString();
      expect(
          pagingString,
          {
            'pageNumber': '5',
            'pageSize': '25',
          }.toString());
    });
  });
}
