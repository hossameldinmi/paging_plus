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
  group('getLatestPage', () {
    test('empty Items', () {
      final expected = const Page(1, 0, 10);
      final page = Page.latestPage(0, 10);
      expect(page, expected);
    });

    test('half-fill Items', () {
      final expected = const Page(1, 5, 5);
      final page = Page.latestPage(5, 10);
      expect(page, expected);
    });

    test('Items == pageSize', () {
      final expected = const Page(1, 10, 0);
      final page = Page.latestPage(10, 10);
      expect(page, expected);
    });

    test('Items == 1.2 pageSize', () {
      final expected = const Page(2, 2, 8);
      final page = Page.latestPage(12, 10);
      expect(page, expected);
    });
    test('Items == 1.5 pageSize', () {
      final expected = const Page(2, 5, 5);
      final page = Page.latestPage(15, 10);
      expect(page, expected);
    });

    test('Items == 2 * pageSize', () {
      final expected = const Page(2, 10, 0);
      final page = Page.latestPage(20, 10);
      expect(page, expected);
    });
  });
}
