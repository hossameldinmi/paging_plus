import 'package:test/test.dart';
import 'package:paging_plus/src/page.dart';

void main() {
  group('page', () {
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
  });

  group('Page.getPages', () {
    test('empty items returns empty list', () {
      final pages = Page.getPages(0, 10);
      expect(pages, isEmpty);
    });

    test('items less than page size returns one page', () {
      final pages = Page.getPages(5, 10);
      expect(pages.length, 1);
      expect(pages[0].pageNumber, 1);
      expect(pages[0].count, 5);
      expect(pages[0].remainingsCount, 5);
      expect(pages[0].hasRemaining, true);
    });

    test('items equal to page size returns one full page', () {
      final pages = Page.getPages(10, 10);
      expect(pages.length, 1);
      expect(pages[0].pageNumber, 1);
      expect(pages[0].count, 10);
      expect(pages[0].remainingsCount, 0);
      expect(pages[0].hasRemaining, false);
    });

    test('items equal to 2 pages returns two full pages', () {
      final pages = Page.getPages(20, 10);
      expect(pages.length, 2);

      expect(pages[0].pageNumber, 1);
      expect(pages[0].count, 10);
      expect(pages[0].remainingsCount, 0);

      expect(pages[1].pageNumber, 2);
      expect(pages[1].count, 10);
      expect(pages[1].remainingsCount, 0);
    });

    test('items with partial last page (25 items, 10 per page)', () {
      final pages = Page.getPages(25, 10);
      expect(pages.length, 3);

      // First page: full
      expect(pages[0].pageNumber, 1);
      expect(pages[0].count, 10);
      expect(pages[0].remainingsCount, 0);
      expect(pages[0].hasRemaining, false);

      // Second page: full
      expect(pages[1].pageNumber, 2);
      expect(pages[1].count, 10);
      expect(pages[1].remainingsCount, 0);
      expect(pages[1].hasRemaining, false);

      // Third page: partial
      expect(pages[2].pageNumber, 3);
      expect(pages[2].count, 5);
      expect(pages[2].remainingsCount, 5);
      expect(pages[2].hasRemaining, true);
    });

    test('items with different page size (12 items, 5 per page)', () {
      final pages = Page.getPages(12, 5);
      expect(pages.length, 3);

      expect(pages[0].pageNumber, 1);
      expect(pages[0].count, 5);
      expect(pages[0].remainingsCount, 0);

      expect(pages[1].pageNumber, 2);
      expect(pages[1].count, 5);
      expect(pages[1].remainingsCount, 0);

      expect(pages[2].pageNumber, 3);
      expect(pages[2].count, 2);
      expect(pages[2].remainingsCount, 3);
    });

    test('single item with large page size', () {
      final pages = Page.getPages(1, 100);
      expect(pages.length, 1);
      expect(pages[0].pageNumber, 1);
      expect(pages[0].count, 1);
      expect(pages[0].remainingsCount, 99);
    });

    test('large dataset (100 items, 20 per page)', () {
      final pages = Page.getPages(100, 20);
      expect(pages.length, 5);

      for (int i = 0; i < 5; i++) {
        expect(pages[i].pageNumber, i + 1);
        expect(pages[i].count, 20);
        expect(pages[i].remainingsCount, 0);
        expect(pages[i].hasRemaining, false);
      }
    });

    test('verify page size consistency', () {
      final pages = Page.getPages(27, 10);

      // All pages should have the same pageSize
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
        expect(pages[i].pageNumber, i + 1);
        expect(pages[i].count, 1);
        expect(pages[i].remainingsCount, 0);
      }
    });

    test('verify last page details (23 items, 10 per page)', () {
      final pages = Page.getPages(23, 10);
      final lastPage = pages.last;

      expect(lastPage.pageNumber, 3);
      expect(lastPage.count, 3);
      expect(lastPage.remainingsCount, 7);
      expect(lastPage.hasRemaining, true);
      expect(lastPage.currentTotalCount, 23);
    });
  });

  group('Page.toString()', () {
    test('toString includes all properties', () {
      final page = const Page(1, 10, 5);
      final pageString = page.toString();

      expect(pageString, {'pageNumber': 1, 'count': 10, 'remainingsCount': 5}.toString());
    });
  });
}
