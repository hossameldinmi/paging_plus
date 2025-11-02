# File Size Examples

This folder contains example code demonstrating how to use the `paging_plus` package with all its features.

## Running the Examples

To run the examples:

```bash
# Navigate to the example directory
cd example

# Get dependencies
dart pub get

# Run the main example (comprehensive overview)
dart run main.dart

# Run the equality and comparison focused example
dart run equality_comparison_example.dart

# Run the advanced features example (NEW!)
dart run advanced_features_example.dart
```

## Example Files

### `main.dart` - Comprehensive Overview
The main example demonstrates core features and basic usage:

1. **Creating SizedFile instances** from different units (B, KB, MB, GB, TB)
2. **Accessing values** in different units
3. **Formatting** with custom fraction digits
4. **Custom postfixes** for individual format calls
5. **Global postfix generator** for localization
6. **Arithmetic operations** (addition, subtraction)
7. **Equality and comparison operations**
8. **Multiplication and division operations** - NEW!
9. **Static helper methods** (min, max, sum, average) - NEW!
10. **Comparable interface and sorting** - NEW!
11. **Real-world scenarios** - EXPANDED!

### `equality_comparison_example.dart` - Equality & Comparison Focus
A dedicated example focusing on equality and comparison features:

1. **Basic Equality Operations** - Same size in different units, hash codes
2. **Comparison Operations** - All comparison operators (<, <=, >, >=)
3. **Collections** - Using SizedFile with Set, Map, and other data structures
4. **Sorting and Ordering** - Sorting files by size, finding min/max
5. **Practical Use Cases** - File validation, storage planning
6. **Arithmetic Operations** - Addition and subtraction examples
7. **Advanced Scenarios** - File categorization, priority processing

### `advanced_features_example.dart` - Advanced Features (NEW!)
A comprehensive example showcasing all advanced features:

1. **Arithmetic Operations**
   - Multiplication by scalar (×2, ×3, ×0.5)
   - Division by scalar (÷2, ÷4, ÷10)
   - Ratio calculation with `ratioTo()` (percentage used)
   - Complex calculations with multiple operations

2. **Static Helper Methods**
   - Finding min and max sizes
   - Calculating total size with `sum()`
   - Computing average size with `average()`
   - Filtered aggregation examples

3. **Comparable Interface**
   - Natural sorting with `.sort()`
   - Ascending and descending order
   - Direct comparison with `compareTo()`
   - Finding median values

4. **Real-World Examples**
   - Disk quota management
   - Backup rotation strategy
   - Video streaming quality selection
   - Cloud storage cost calculation
   - Data transfer time estimation

## Quick Examples

### Basic Usage

```dart
import 'package:paging_plus/paging_plus.dart';

void main() {
  // Create from megabytes
  final fileSize = SizedFile.mb(5);
  
  // Format for display
  print(fileSize.format()); // "5.00 MB"
  
  // Access in different units
  print(fileSize.inBytes); // 5242880
  print(fileSize.inKB);    // 5120.0
}
```

### Custom Formatting

```dart
final size = SizedFile.kb(1.5);

// Different fraction digits
print(size.format(fractionDigits: 0)); // "2 KB"
print(size.format(fractionDigits: 3)); // "1.500 KB"

// Custom postfixes
final custom = {'B': 'bytes', 'KB': 'kilobytes', 'MB': 'megabytes', 'GB': 'gigabytes'};
print(size.format(postfixes: custom)); // "1.50 kilobytes"
```
