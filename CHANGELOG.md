# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-07-14

### Fixed
- `Page.getPages` no longer hangs forever when called with a `pageSize` of 0
  (and no longer grows the list unboundedly for negative page sizes) — it now
  throws an `ArgumentError`
- `Page.lastOf` and `Paging.next` no longer crash with an obscure
  `Unsupported operation` error for a `pageSize` of 0, and no longer return
  nonsensical pages for negative item counts — they now throw an `ArgumentError`
- The pagination optimizer can no longer degenerate into pathological requests
  such as `Paging(200, 1)` (one item per request); the optimized page size is
  bounded below by the new `minPageSize` parameter, which defaults to half of
  `pageSize`
- The optimizer now finds strictly better results: it picks the largest page
  size in `[minPageSize, pageSize]` whose fetch window starts closest to the
  items already fetched, producing zero duplicates whenever a divisor of
  `itemCount` is in range (e.g. 160 items / page size 100 now yields page 3 of
  size 80 instead of page 5 of size 40)

### Changed
- **BREAKING**: `Paging.next` optional parameters are now named:
  `Paging.next(itemCount, pageSize, refetchPartialLastPage: ..., minCountToOptimize: ..., minPageSize: ...)`
- **BREAKING**: Renamed `fetchLastIfHasRemaining` to `refetchPartialLastPage`
  and `minimumRemainingsToTake` to `minCountToOptimize` — the old name and its
  documentation contradicted the actual behavior (the threshold compares
  against the last page's item count, not its remaining slots)
- **BREAKING**: Renamed `Page.remainingsCount` to `Page.remainingCount`
- **BREAKING**: `Page` and `Paging` constructors now assert their arguments
  are in range (page numbers >= 1, counts >= 0, page sizes >= 1)
- **BREAKING**: Removed the `equatable` dependency; `Page` and `Paging`
  implement `==`/`hashCode` directly (the `props` getter is gone) — the
  package now has zero runtime dependencies
- `toString()` now returns `Page(pageNumber: 1, count: 10, remainingCount: 5)`
  style output instead of a map literal
- Minimum SDK raised to Dart 3.6
- Enabled the `lints/recommended` lint set

### Added
- `example/main.dart` — a runnable example (the README previously pointed to a
  file that did not exist)
- Contract tests sweeping thousands of input combinations to guarantee
  `Paging.next` never skips items and always requests at least one new item

## [1.0.0] - 2025-11-03

### Added
- Comprehensive test suite with 89 tests:
  - 31 tests for `Page` class (constructor, properties, factory methods, equality, toString)
  - 58 tests for `Paging` class (constructor, equality, edge cases, optimization, various scenarios)
  - 100% code coverage for all public APIs
- `Page.toString()` method for better debugging
- `Paging.toString()` method for better debugging
- Complete API documentation with examples throughout

### Changed
- **BREAKING**: Simplified `Paging` class by removing `shouldHasDuplicates` property for cleaner API
- **BREAKING**: Renamed `Page.latestPage()` to `Page.lastOf()` for more concise naming
- Improved documentation across all classes and methods
- Updated README with comprehensive examples and API reference
- Updated example README to match new API

### Removed
- `shouldHasDuplicates` property from `Paging` class (breaking change)
- `expectedTotalCount` property from `Page` class

## [0.0.1-alpha.1] - 2025-11-02

### Added
- Initial alpha release of the `paging_plus` package
- `Page` class for representing a single page in a paginated dataset
  - Constructor: `Page(pageNumber, count, remainingsCount)`
  - Properties: `pageNumber`, `count`, `remainingsCount`, `hasRemaining`, `pageSize`, `currentTotalCount`
  - Factory method: `Page.latestPage(itemCount, pageSize)` - creates the latest page based on item count
  - Static method: `Page.getPages(itemCount, pageSize)` - generates all pages for a dataset
  - Implements `Equatable` for value equality
- `Paging` class for intelligent pagination request calculation
  - Constructor: `Paging(pageNumber, pageSize, shouldHasDuplicates)`
  - Factory method: `Paging.next(itemCount, pageSize, [fetchLatestIfHasRemaining, minimumRemainingsToTake, minimumToRequest])` with optimization options
  - Support for optimized pagination to minimize redundant data fetching
  - GCD-based algorithm for efficient page size calculation
  - Implements `Equatable` for easy comparison
- Built on Equatable for easy comparison and testing
- Comprehensive dartdoc documentation for all classes and methods
- Detailed README.md with:
  - Installation instructions
  - Usage examples for basic and advanced scenarios
  - Practical examples (infinite scroll, REST API pagination, Flutter ListView)
  - Complete API reference
  - Explanation of pagination optimization
- Example code demonstrating real-world use cases
- Basic unit tests covering core features

### Features
- 📄 Calculate detailed page information from item counts
- 🔄 Intelligently determine the next page to fetch
- ⚡ Minimize redundant data fetching with optimized pagination
- 📊 Built-in support for "load more" functionality
- 🎯 Type safe with null safety support
- 🔗 Built on Equatable for easy comparison
- ⚡ Lightweight with minimal dependencies
- 🧪 Test coverage for core functionality

[2.0.0]: https://github.com/balsm-health/paging_plus/releases/tag/v2.0.0
[1.0.0]: https://github.com/balsm-health/paging_plus/releases/tag/v1.0.0
[0.0.1-alpha.1]: https://github.com/balsm-health/paging_plus/releases/tag/v0.0.1-alpha.1

