// ignore_for_file: avoid_print

import 'package:paging_plus/paging_plus.dart';

void main() {
  // --- Page: describe a single page -------------------------------------
  final page = Page(1, 10, 5);
  print('Page ${page.pageNumber}: ${page.count} items, '
      '${page.remainingCount} remaining slots, size ${page.pageSize}');
  // Page 1: 10 items, 5 remaining slots, size 15

  // --- Page.lastOf: where does the last item land? ----------------------
  final lastPage = Page.lastOf(25, 10);
  print('Last page for 25 items: $lastPage');
  // Page(pageNumber: 3, count: 5, remainingCount: 5)

  // --- Page.getPages: all pages for a dataset ---------------------------
  final pages = Page.getPages(25, 10);
  for (final p in pages) {
    print('Page ${p.pageNumber}: ${p.count} items');
  }
  // Page 1: 10 items
  // Page 2: 10 items
  // Page 3: 5 items

  // --- Paging.next: what to fetch next -----------------------------------
  print(Paging.next(0, 20)); // Paging(pageNumber: 1, pageSize: 20)
  print(Paging.next(40, 20)); // Paging(pageNumber: 3, pageSize: 20)
  // Partial last page is re-fetched by default:
  print(Paging.next(50, 20)); // Paging(pageNumber: 3, pageSize: 20)

  // --- Optimized fetching: avoid re-downloading items --------------------
  // 15 items with page size 10: instead of re-fetching page 2 (5 duplicates),
  // fetch page 4 with size 5 - it starts exactly at item 15, zero duplicates.
  print(Paging.next(15, 10, refetchPartialLastPage: false));
  // Paging(pageNumber: 4, pageSize: 5)

  // Even for awkward counts the optimizer minimizes duplicates:
  print(Paging.next(199, 100, refetchPartialLastPage: false));
  // Paging(pageNumber: 3, pageSize: 99) -> starts at 198, only 1 duplicate

  // --- Load-more loop -----------------------------------------------------
  final loaded = <int>[];
  const pageSize = 20;
  var hasMore = true;
  while (hasMore) {
    final paging = Paging.next(loaded.length, pageSize);
    final batch = fetchFromServer(paging.pageNumber, paging.pageSize);
    // Drop items we already have (a re-fetched partial page contains them).
    loaded.addAll(batch.where((item) => !loaded.contains(item)));
    hasMore = batch.length == paging.pageSize;
  }
  print('Loaded ${loaded.length} items'); // Loaded 45 items
}

/// Simulates a paginated API holding 45 items (1..45).
List<int> fetchFromServer(int pageNumber, int pageSize) {
  const totalItems = 45;
  final start = (pageNumber - 1) * pageSize;
  final end = start + pageSize;
  return [
    for (var i = start; i < end && i < totalItems; i++) i + 1,
  ];
}
