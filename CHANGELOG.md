# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[1.0.0]: https://github.com/hossameldinmi/paging_plus/releases/tag/v1.0.0
[0.0.1-alpha.1]: https://github.com/hossameldinmi/paging_plus/releases/tag/v0.0.1-alpha.1

