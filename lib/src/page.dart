import 'package:equatable/equatable.dart';

class Page extends Equatable {
  final int pageNumber;
  final int count;
  final int remainingsCount;
  bool get hasRemaining => remainingsCount > 0;
  int get pageSize => remainingsCount + count;
  int get currentTotalCount => ((pageNumber - 1) * pageSize) + count;
  int get expectedTotalCount => currentTotalCount + remainingsCount;
  const Page(this.pageNumber, this.count, this.remainingsCount);

  @override
  List<Object> get props => [pageNumber, count, remainingsCount];

  factory Page.latestPage(int itemCount, int pageSize) {
    if (itemCount <= pageSize) {
      return Page(1, itemCount, pageSize - itemCount);
    }
    final pageNumber = (itemCount / pageSize).ceil();
    final remaining = itemCount % pageSize;
    final latestPageItems = remaining == 0 ? pageSize : remaining;
    return Page(pageNumber, latestPageItems, pageSize - latestPageItems);
  }

  static List<Page> getPages(int itemCount, int pageSize) {
    final pages = <Page>[];
    int remainingItems = itemCount;
    int currentPageNumber = 1;

    while (remainingItems > 0) {
      final currentPageItems = remainingItems >= pageSize ? pageSize : remainingItems;
      final remainingsCount = pageSize - currentPageItems;
      pages.add(Page(currentPageNumber, currentPageItems, remainingsCount));
      remainingItems -= currentPageItems;
      currentPageNumber++;
    }
    return pages;
  }

  @override
  bool get stringify => true;
}
