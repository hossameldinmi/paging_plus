import 'package:paging_plus/paging_plus.dart';
import 'package:test/test.dart';

void main() {
  group('Page properties', () {
    test('empty items', () {
      final page = const Page(1, 0, 10);
      expect(page.currentTotalCount, 0);
      expect(page.hasRemaining, true);
      expect(page.pageSize, 10);
    });

    test('half-fill Items', () {
      final page = const Page(1, 5, 5);
      expect(page.currentTotalCount, 5);
      expect(page.hasRemaining, true);
      expect(page.pageSize, 10);
    });

    test('Items == pageSize', () {
      final page = const Page(1, 10, 0);
      expect(page.currentTotalCount, 10);
      expect(page.hasRemaining, false);
      expect(page.pageSize, 10);
    });

    test('Items == 1.2 pageSize', () {
      final page = const Page(2, 2, 8);
      expect(page.currentTotalCount, 12);
      expect(page.hasRemaining, true);
      expect(page.pageSize, 10);
    });

    test('Items == 1.5 pageSize', () {
      final page = const Page(2, 5, 5);
      expect(page.currentTotalCount, 15);
      expect(page.hasRemaining, true);
      expect(page.pageSize, 10);
    });

    test('Items == 2 * pageSize', () {
      final page = const Page(2, 10, 0);
      expect(page.currentTotalCount, 20);
      expect(page.hasRemaining, false);
      expect(page.pageSize, 10);
    });
  });

  group('Page constructor validation', () {
    test('rejects pageNumber below 1', () {
      expect(() => Page(0, 5, 5), throwsA(isA<AssertionError>()));
    });

    test('rejects negative count', () {
      expect(() => Page(1, -1, 5), throwsA(isA<AssertionError>()));
    });

    test('rejects negative remainingCount', () {
      expect(() => Page(1, 5, -1), throwsA(isA<AssertionError>()));
    });
  });

  group('Page.lastOf', () {
    test('empty Items', () {
      final expected = const Page(1, 0, 10);
      final page = Page.lastOf(0, 10);
      expect(page, expected);
    });

    test('half-fill Items', () {
      final expected = const Page(1, 5, 5);
      final page = Page.lastOf(5, 10);
      expect(page, expected);
    });

    test('Items == pageSize', () {
      final expected = const Page(1, 10, 0);
      final page = Page.lastOf(10, 10);
      expect(page, expected);
    });

    test('Items == 1.2 pageSize', () {
      final expected = const Page(2, 2, 8);
      final page = Page.lastOf(12, 10);
      expect(page, expected);
    });

    test('Items == 1.5 pageSize', () {
      final expected = const Page(2, 5, 5);
      final page = Page.lastOf(15, 10);
      expect(page, expected);
    });

    test('Items == 2 * pageSize', () {
      final expected = const Page(2, 10, 0);
      final page = Page.lastOf(20, 10);
      expect(page, expected);
    });

    test('throws ArgumentError for pageSize of 0', () {
      expect(() => Page.lastOf(10, 0), throwsArgumentError);
    });

    test('throws ArgumentError for negative pageSize', () {
      expect(() => Page.lastOf(10, -3), throwsArgumentError);
    });

    test('throws ArgumentError for negative itemCount', () {
      expect(() => Page.lastOf(-5, 10), throwsArgumentError);
    });
  });

  group('Page.getPages', () {
    test('empty items returns empty list', () {
      final pages = Page.getPages(0, 10);
      expect(pages, isEmpty);
    });

    test('items less than page size returns one page', () {
      final pages = Page.getPages(5, 10);
      expect(pages, [const Page(1, 5, 5)]);
      expect(pages[0].hasRemaining, true);
    });

    test('items equal to page size returns one full page', () {
      final pages = Page.getPages(10, 10);
      expect(pages, [const Page(1, 10, 0)]);
      expect(pages[0].hasRemaining, false);
    });

    test('items equal to 2 pages returns two full pages', () {
      final pages = Page.getPages(20, 10);
      expect(pages, [const Page(1, 10, 0), const Page(2, 10, 0)]);
    });

    test('items with partial last page (25 items, 10 per page)', () {
      final pages = Page.getPages(25, 10);
      expect(pages, [
        const Page(1, 10, 0),
        const Page(2, 10, 0),
        const Page(3, 5, 5),
      ]);
      expect(pages.last.hasRemaining, true);
    });

    test('items with different page size (12 items, 5 per page)', () {
      final pages = Page.getPages(12, 5);
      expect(pages, [
        const Page(1, 5, 0),
        const Page(2, 5, 0),
        const Page(3, 2, 3),
      ]);
    });

    test('single item with large page size', () {
      final pages = Page.getPages(1, 100);
      expect(pages, [const Page(1, 1, 99)]);
    });

    test('large dataset (100 items, 20 per page)', () {
      final pages = Page.getPages(100, 20);
      expect(pages.length, 5);
      for (int i = 0; i < 5; i++) {
        expect(pages[i], Page(i + 1, 20, 0));
      }
    });

    test('verify page size consistency', () {
      final pages = Page.getPages(27, 10);
      for (final page in pages) {
        expect(page.pageSize, 10);
      }
    });

    test('verify currentTotalCount progression', () {
      final pages = Page.getPages(35, 10);
      expect(pages[0].currentTotalCount, 10);
      expect(pages[1].currentTotalCount, 20);
      expect(pages[2].currentTotalCount, 30);
      expect(pages[3].currentTotalCount, 35);
    });

    test('page size of 1 (100 items)', () {
      final pages = Page.getPages(100, 1);
      expect(pages.length, 100);
      for (int i = 0; i < 100; i++) {
        expect(pages[i], Page(i + 1, 1, 0));
      }
    });

    test('verify last page details (23 items, 10 per page)', () {
      final pages = Page.getPages(23, 10);
      final lastPage = pages.last;
      expect(lastPage, const Page(3, 3, 7));
      expect(lastPage.currentTotalCount, 23);
    });

    test('throws ArgumentError for pageSize of 0 instead of looping forever', () {
      expect(() => Page.getPages(10, 0), throwsArgumentError);
    });

    test('throws ArgumentError for negative pageSize', () {
      expect(() => Page.getPages(10, -1), throwsArgumentError);
    });

    test('throws ArgumentError for negative itemCount', () {
      expect(() => Page.getPages(-1, 10), throwsArgumentError);
    });
  });

  group('Page equality', () {
    test('equal pages are equal with same hashCode', () {
      final a = const Page(2, 5, 5);
      final b = const Page(2, 5, 5);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different pageNumber makes pages unequal', () {
      expect(const Page(1, 5, 5), isNot(equals(const Page(2, 5, 5))));
    });

    test('different count makes pages unequal', () {
      expect(const Page(1, 4, 5), isNot(equals(const Page(1, 5, 5))));
    });

    test('different remainingCount makes pages unequal', () {
      expect(const Page(1, 5, 4), isNot(equals(const Page(1, 5, 5))));
    });
  });

  group('Page.toString()', () {
    test('includes all properties', () {
      final page = const Page(1, 10, 5);
      expect(page.toString(), 'Page(pageNumber: 1, count: 10, remainingCount: 5)');
    });
  });
}
