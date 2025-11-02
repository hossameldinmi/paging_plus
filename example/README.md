# Paging Plus Examples

This folder contains example code demonstrating how to use the `paging_plus` package for pagination management.

## Running the Examples

To run the examples:

```bash
# Navigate to the example directory
cd example

# Get dependencies
dart pub get

# Run the main example (comprehensive overview)
dart run main.dart
```

## Example Files

### `main.dart` - Comprehensive Overview
The main example demonstrates core features and basic usage:

1. **Creating Page instances** - Understanding page structure
2. **Page.lastOf()** - Getting the last page information
3. **Page.getPages()** - Generating all pages for a dataset
4. **Paging.next()** - Calculating the next page to fetch
5. **Advanced pagination options** - Optimization parameters
6. **Infinite scroll pattern** - Load more implementation
7. **Real-world scenarios** - Practical pagination examples

## Quick Examples

### Basic Page Information

```dart
import 'package:paging_plus/paging_plus.dart';

void main() {
  // Get the last page for 25 items with page size 10
  final page = Page.lastOf(25, 10);
  
  print('Page ${page.pageNumber}'); // Page 3
  print('Items: ${page.count}'); // Items: 5
  print('Remaining: ${page.remainingsCount}'); // Remaining: 5
  print('Has remaining: ${page.hasRemaining}'); // true
}
```

### Next Page Calculation

```dart
import 'package:paging_plus/paging_plus.dart';

void main() {
  // Calculate next page to fetch
  // Current: 50 items, page size: 20
  final paging = Paging.next(50, 20);
  
  print('Fetch page ${paging.pageNumber}'); // Fetch page 3
  print('Page size: ${paging.pageSize}'); // Page size: 20
}
```

### Load More Pattern

```dart
import 'package:paging_plus/paging_plus.dart';

class DataController {
  List<Item> items = [];
  final int pageSize = 20;
  bool isLoading = false;
  
  Future<void> loadMore() async {
    if (isLoading) return;
    
    isLoading = true;
    
    // Calculate next page
    final paging = Paging.next(items.length, pageSize);
    
    // Fetch data
    final newItems = await fetchItems(
      page: paging.pageNumber,
      pageSize: paging.pageSize,
    );
    
    items.addAll(newItems);
    isLoading = false;
  }
}
```
