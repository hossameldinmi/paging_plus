<h2 align="center">
  Paging Plus
</h2>

<p align="center">
   <a href="https://github.com/balsm-health/paging_plus/actions/workflows/dart.yml">
    <img src="https://github.com/balsm-health/paging_plus/actions/workflows/dart.yml/badge.svg?branch=main" alt="Github action">
  </a>
  <a href="https://codecov.io/github/hossameldinmi/paging_plus">
    <img src="https://codecov.io/github/hossameldinmi/paging_plus/graph/badge.svg?token=JzTIIzoQOq" alt="Code Coverage">
  </a>
  <a href="https://pub.dev/packages/paging_plus">
    <img alt="Pub Package" src="https://img.shields.io/pub/v/paging_plus">
  </a>
   <a href="https://pub.dev/packages/paging_plus">
    <img alt="Pub Points" src="https://img.shields.io/pub/points/paging_plus">
  </a>
  <br/>
  <a href="https://opensource.org/licenses/MIT">
    <img alt="MIT License" src="https://img.shields.io/badge/License-MIT-blue.svg">
  </a>
</p>

---

A lightweight and intuitive Dart package for pagination and paging management. Easy-to-use utilities for handling page numbers, item counts, and load more functionality in Flutter and Dart applications.

## Features

- 📄 **Page Information**: Calculate detailed page information from item counts
- 🔄 **Smart Pagination**: Intelligently determine the next page to fetch
- ⚡ **Optimization**: Minimize redundant data fetching with optimized pagination
- 📊 **Load More**: Built-in support for "load more" functionality
- 🎯 **Type Safe**: Built with strong typing, null safety, and input validation
- 🧪 **Well Tested**: Comprehensive test coverage
- ⚡ **Lightweight**: Zero dependencies, pure Dart implementation

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  paging_plus: ^2.0.0
```

Then run:

```bash
dart pub get
```

Or with Flutter:

```bash
flutter pub get
```

## Usage

### Basic Usage

#### Page Information

The `Page` class represents a single page in a paginated dataset:

```dart
import 'package:paging_plus/paging_plus.dart';

// Create a page directly
final page = Page(1, 10, 5); // page 1, 10 items, 5 remaining slots
print('Page ${page.pageNumber} has ${page.count} items');
print('Page size: ${page.pageSize}'); // 15
print('Has remaining: ${page.hasRemaining}'); // true

// Get the last page based on item count
final lastPage = Page.lastOf(25, 10);
print('Last page: ${lastPage.pageNumber}'); // 3
print('Items in page: ${lastPage.count}'); // 5
print('Remaining slots: ${lastPage.remainingCount}'); // 5
```

#### Generate All Pages

Generate a complete list of pages for your dataset:

```dart
// Generate all pages for 25 items with page size 10
final pages = Page.getPages(25, 10);
print('Total pages: ${pages.length}'); // 3

for (final page in pages) {
  print('Page ${page.pageNumber}: ${page.count} items');
}
// Output:
// Page 1: 10 items
// Page 2: 10 items
// Page 3: 5 items
```

### Pagination

The `Paging` class helps determine what to fetch next:

```dart
import 'package:paging_plus/paging_plus.dart';

// Calculate next page to fetch
// If you have 0 items, fetch page 1
final paging1 = Paging.next(0, 20);
print('Fetch page ${paging1.pageNumber} with size ${paging1.pageSize}');
// Output: Fetch page 1 with size 20

// If you have 50 items with page size 20, the last page is partially
// filled, so it is re-fetched by default
final paging2 = Paging.next(50, 20);
print('Fetch page ${paging2.pageNumber} with size ${paging2.pageSize}');
// Output: Fetch page 3 with size 20

// If you have 40 items (exactly 2 full pages), fetch page 3
final paging3 = Paging.next(40, 20);
print('Fetch page ${paging3.pageNumber} with size ${paging3.pageSize}');
// Output: Fetch page 3 with size 20
```

### Advanced Pagination Options

`Paging.next()` accepts named parameters that control how a partially filled
last page is handled:

```dart
// Default behavior: re-fetch the partial last page with the original size.
// With 25 items and page size 10 the request is page 3 of size 10,
// which downloads 5 duplicates alongside the 5 new items.
final basic = Paging.next(25, 10);
print(basic); // Paging(pageNumber: 3, pageSize: 10)

// Optimized: pick a page size whose window starts exactly at item 25.
final optimized = Paging.next(25, 10, refetchPartialLastPage: false);
print(optimized); // Paging(pageNumber: 6, pageSize: 5) - zero duplicates

// Only optimize when the last page already holds at least 5 items;
// below that threshold, re-fetching the last page is cheap anyway.
final guarded = Paging.next(
  25,
  10,
  refetchPartialLastPage: false,
  minCountToOptimize: 5,
);

// Control how small the optimizer may make the page size
// (defaults to half of pageSize):
final bounded = Paging.next(
  199,
  100,
  refetchPartialLastPage: false,
  minPageSize: 50,
);
print(bounded); // Paging(pageNumber: 3, pageSize: 99) - only 1 duplicate
```

### Practical Examples

#### Infinite Scroll / Load More

```dart
class DataController {
  List<Item> items = [];
  final int pageSize = 20;
  bool isLoading = false;

  Future<void> loadMore() async {
    if (isLoading) return;

    isLoading = true;

    // Calculate what page to fetch next
    final paging = Paging.next(items.length, pageSize);

    print('Fetching page ${paging.pageNumber}...');

    // Fetch the data
    final newItems = await fetchItems(
      page: paging.pageNumber,
      pageSize: paging.pageSize,
    );

    items.addAll(newItems);
    isLoading = false;
  }

  Future<List<Item>> fetchItems({
    required int page,
    required int pageSize,
  }) async {
    // Your API call here
    return [];
  }
}
```

#### Pagination UI Helper

```dart
class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPreviousPage;

  factory PaginationInfo.fromItemCount(int totalItems, int pageSize) {
    final pages = Page.getPages(totalItems, pageSize);
    final latestPage = pages.isNotEmpty ? pages.last : Page(1, 0, pageSize);

    return PaginationInfo(
      currentPage: latestPage.pageNumber,
      totalPages: pages.length,
      itemsPerPage: pageSize,
      totalItems: totalItems,
      hasNextPage: latestPage.hasRemaining || latestPage.pageNumber < pages.length,
      hasPreviousPage: latestPage.pageNumber > 1,
    );
  }

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}
```

#### REST API Pagination

```dart
class ApiClient {
  Future<PaginatedResponse<T>> fetchPage<T>({
    required int currentItemCount,
    required int pageSize,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    // Calculate next page
    final paging = Paging.next(currentItemCount, pageSize);

    // Make API call
    final response = await http.get(
      Uri.parse('https://api.example.com/items')
          .replace(queryParameters: {
        'page': paging.pageNumber.toString(),
        'pageSize': paging.pageSize.toString(),
      }),
    );

    final data = jsonDecode(response.body);
    final items = (data['items'] as List)
        .map((json) => fromJson(json))
        .toList();

    return PaginatedResponse(
      items: items,
      page: paging.pageNumber,
      pageSize: paging.pageSize,
      hasMore: items.length == paging.pageSize,
    );
  }
}

class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
}
```

#### Flutter ListView with Load More

```dart
class ItemListView extends StatefulWidget {
  @override
  _ItemListViewState createState() => _ItemListViewState();
}

class _ItemListViewState extends State<ItemListView> {
  final List<Item> items = [];
  final int pageSize = 20;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    final paging = Paging.next(items.length, pageSize);
    final newItems = await fetchItems(
      page: paging.pageNumber,
      pageSize: paging.pageSize,
    );

    setState(() {
      items.addAll(newItems);
      isLoading = false;
      hasMore = newItems.length == pageSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          // Load more indicator
          loadMore();
          return Center(child: CircularProgressIndicator());
        }
        return ListTile(title: Text(items[index].name));
      },
    );
  }

  Future<List<Item>> fetchItems({required int page, required int pageSize}) async {
    // Your API call
    return [];
  }
}
```

## API Reference

### Page Class

Represents a single page in a paginated dataset.

#### Constructor

```dart
const Page(int pageNumber, int count, int remainingCount)
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `pageNumber` | `int` | The current page number (1-indexed) |
| `count` | `int` | Number of items in this page |
| `remainingCount` | `int` | Number of remaining slots in this page |
| `hasRemaining` | `bool` | Whether this page has remaining slots |
| `pageSize` | `int` | Total page size (count + remaining) |
| `currentTotalCount` | `int` | Total items up to this page |

#### Factory Methods

##### `Page.lastOf(int itemCount, int pageSize)`

Creates the last page based on total item count. Throws an `ArgumentError`
if `itemCount` is negative or `pageSize` is less than 1.

```dart
final page = Page.lastOf(25, 10);
print(page.pageNumber); // 3
print(page.count); // 5
```

##### `Page.getPages(int itemCount, int pageSize)`

Generates a list of all pages for the dataset. Throws an `ArgumentError`
if `itemCount` is negative or `pageSize` is less than 1.

```dart
final pages = Page.getPages(25, 10);
print(pages.length); // 3
```

### Paging Class

Represents a pagination request with optimized page size calculation.

#### Constructor

```dart
const Paging(int pageNumber, int pageSize)
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `pageNumber` | `int` | Page number to fetch (1-indexed) |
| `pageSize` | `int` | Number of items per page |

#### Factory Methods

##### `Paging.next()`

```dart
factory Paging.next(
  int itemCount,
  int pageSize, {
  bool refetchPartialLastPage = true,
  int minCountToOptimize = 0,
  int? minPageSize,
})
```

Calculates the next page to fetch with optional optimization.

**Parameters:**
- `itemCount` - Current total number of items already fetched
- `pageSize` - Desired items per page
- `refetchPartialLastPage` - If true (default), a partially filled last page is re-fetched with the original `pageSize`
- `minCountToOptimize` - Only optimize when the last page already holds at least this many items (default: 0)
- `minPageSize` - Smallest page size the optimizer may pick, between 1 and `pageSize` (default: half of `pageSize`)

**Returns:** A `Paging` object specifying the next page to fetch. The result
never skips items (`(pageNumber - 1) * pageSize <= itemCount`) and always
reaches past the items already fetched (`pageNumber * pageSize > itemCount`).

**Throws:** `ArgumentError` if any argument is out of range.

```dart
// Simple usage
final paging = Paging.next(50, 20);

// With optimization
final optimized = Paging.next(
  50,
  20,
  refetchPartialLastPage: false,
  minCountToOptimize: 5,
);
```

## Understanding Pagination Optimization

`Paging.next()` includes an optimization that can reduce redundant data
fetching when the last page is partially filled:

### Standard Behavior (default)

```dart
// With 25 items and page size 10:
// Page 1: 10 items, Page 2: 10 items, Page 3: 5 items (5 remaining)
final paging = Paging.next(25, 10); // Default: refetch page 3
// Result: page 3, size 10 (will fetch 5 new items + 5 duplicates)
```

### Optimized Behavior

```dart
// Don't refetch the partial last page as-is
final paging = Paging.next(25, 10, refetchPartialLastPage: false);
// Result: page 6, size 5 - the window starts exactly at item 25,
// so the request contains zero duplicates
```

The optimizer searches page sizes from `pageSize` down to `minPageSize` and
picks the one whose fetch window starts closest to `itemCount`, preferring
the largest size on ties:

- When a size in that range divides `itemCount` evenly, the request contains
  **no duplicates at all** (e.g. 160 items with page size 100 becomes page 3
  of size 80).
- Otherwise it minimizes the overlap (e.g. 199 items with page size 100
  becomes page 3 of size 99 - a single duplicate).
- `minPageSize` (default: half of `pageSize`) keeps the result from
  degenerating into tiny requests.

## Testing

The package includes comprehensive unit tests covering:

- Page creation and calculations
- Latest page determination
- Page list generation
- Next page calculation
- Pagination optimization
- Input validation
- Edge cases and boundary conditions
- Equality and hashCode behavior

Run tests with:

```bash
dart test
```

Or with Flutter:

```bash
flutter test
```

## Examples

For more comprehensive examples, check out the [example](example/) directory.

To run the examples:

```bash
cd example
dart pub get
dart run main.dart
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes in each version.

## Support

If you encounter any issues or have questions:

1. Check the [API Reference](#api-reference) section
2. Look at the [examples](#practical-examples)
3. Open an issue on [GitHub](https://github.com/balsm-health/paging_plus/issues)

---

Made with ❤️ for the Dart and Flutter community
