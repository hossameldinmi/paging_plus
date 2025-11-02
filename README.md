<h2 align="center">
  Paging Plus
</h2>

<p align="center">
   <a href="https://github.com/hossameldinmi/paging_plus/actions/workflows/dart.yml">
    <img src="https://github.com/hossameldinmi/paging_plus/actions/workflows/dart.yml/badge.svg?branch=main" alt="Github action">
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
- 🎯 **Type Safe**: Built with strong typing and null safety
- 🧪 **Well Tested**: Comprehensive test coverage
- 🔗 **Equatable**: Built on Equatable for easy comparison
- ⚡ **Lightweight**: Minimal dependencies, pure Dart implementation

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  paging_plus: ^1.3.3
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

// Get the latest page based on item count
final latestPage = Page.latestPage(25, 10);
print('Latest page: ${latestPage.pageNumber}'); // 3
print('Items in page: ${latestPage.count}'); // 5
print('Remaining slots: ${latestPage.remainingsCount}'); // 5
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

// If you have 50 items with page size 20, fetch page 3
final paging2 = Paging.next(50, 20);
print('Fetch page ${paging2.pageNumber} with size ${paging2.pageSize}');
// Output: Fetch page 3 with size 20

// If you have 40 items (exactly 2 full pages), fetch page 3
final paging3 = Paging.next(40, 20);
print('Fetch page ${paging3.pageNumber} with size ${paging3.pageSize}');
// Output: Fetch page 3 with size 20
```

### Advanced Pagination Options

The `Paging.next()` factory provides advanced options for optimization:

```dart
// Basic usage - always refetch latest page if it has remaining slots
final basic = Paging.next(25, 10);
print('Page: ${basic.pageNumber}, Size: ${basic.pageSize}');
// Output: Page: 3, Size: 10

// Don't refetch latest page if it has remaining slots
final optimized = Paging.next(
  25, 
  10,
  false, // fetchLastIfHasRemaining
);
print('Page: ${optimized.pageNumber}, Size: ${optimized.pageSize}');

// Advanced: Set minimum remainings threshold and minimum request size
final advanced = Paging.next(
  25,
  10,
  true,  // fetchLastIfHasRemaining
  3,     // minimumRemainingsToTake - only refetch if >= 3 slots remaining
);
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
const Page(int pageNumber, int count, int remainingsCount)
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `pageNumber` | `int` | The current page number (1-indexed) |
| `count` | `int` | Number of items in this page |
| `remainingsCount` | `int` | Number of remaining slots in this page |
| `hasRemaining` | `bool` | Whether this page has remaining slots |
| `pageSize` | `int` | Total page size (count + remaining) |
| `currentTotalCount` | `int` | Total items up to this page |
| `expectedTotalCount` | `int` | Expected total if remaining slots filled |

#### Factory Methods

##### `Page.latestPage(int itemCount, int pageSize)`

Creates the latest page based on total item count.

```dart
final page = Page.latestPage(25, 10);
print(page.pageNumber); // 3
print(page.count); // 5
```

##### `Page.getPages(int itemCount, int pageSize)`

Generates a list of all pages for the dataset.

```dart
final pages = Page.getPages(25, 10);
print(pages.length); // 3
```

### Paging Class

Represents a pagination request with optimized page size calculation.

#### Constructor

```dart
const Paging(int pageNumber, int pageSize, [bool shouldHasDuplicates = false])
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `pageNumber` | `int` | Page number to fetch (1-indexed) |
| `pageSize` | `int` | Number of items per page |
| `shouldHasDuplicates` | `bool` | Whether duplicates may occur |

#### Factory Methods

##### `Paging.next()`

```dart
factory Paging.next(
  int itemCount, 
  int pageSize,
  [bool fetchLastIfHasRemaining = true, 
   int minimumRemainingsToTake = 0]
)
```

Calculates the next page to fetch with optional optimization.

**Parameters:**
- `itemCount` - Current total number of items
- `pageSize` - Desired items per page
- `fetchLastIfHasRemaining` - Re-fetch latest page if it has remaining slots (default: true)
- `minimumRemainingsToTake` - Minimum remaining slots before optimization (default: 0)

**Returns:** A `Paging` object specifying the next page to fetch.

```dart
// Simple usage
final paging = Paging.next(50, 20);

// With optimization
final optimized = Paging.next(50, 20, false, 5, 10);
```

## Understanding Pagination Optimization

The `Paging.next()` method includes an optimization algorithm that can reduce redundant data fetching:

### Standard Behavior (default)

```dart
// With 25 items and page size 10:
// Page 1: 10 items, Page 2: 10 items, Page 3: 5 items (5 remaining)
final paging = Paging.next(25, 10); // Default: refetch page 3
// Result: page 3, size 10 (will fetch 5 new items + 5 duplicates)
```

### Optimized Behavior

```dart
// Don't refetch if latest page has remaining slots
final paging = Paging.next(25, 10, false);
// Result: Uses GCD algorithm to find optimal page size
// This minimizes duplicate data while filling remaining slots
```

The optimization uses the Greatest Common Divisor (GCD) algorithm to calculate an efficient page size that:
- Minimizes duplicate data fetching
- Respects minimum request size requirements
- Fills remaining page slots efficiently

## Testing

The package includes comprehensive unit tests covering:

- Page creation and calculations
- Latest page determination
- Page list generation
- Next page calculation
- Pagination optimization
- Edge cases and boundary conditions
- Equatable implementation

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
3. Open an issue on [GitHub](https://github.com/hossameldinmi/paging_plus/issues)

---

Made with ❤️ for the Dart and Flutter community
