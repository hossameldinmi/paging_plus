import 'package:paging_plus/src/paging.dart';
import 'package:test/test.dart';

void main() {
  test('empty Items', () {
    final expected = const Paging(1, 10);
    final pagination0 = Paging.next(0, 10);
    final pagination1 = Paging.next(0, 10, true, 5);
    final pagination2 = Paging.next(0, 10, false, 5);
    expect(pagination0, expected);
    expect(pagination1, expected);
    expect(pagination2, expected);
  });

  test('Items == pageSize', () {
    final expected = const Paging(2, 10);
    final pagination0 = Paging.next(10, 10);
    final pagination1 = Paging.next(10, 10, true, 5);
    final pagination2 = Paging.next(10, 10, false, 5);
    expect(pagination0, expected);
    expect(pagination1, expected);
    expect(pagination2, expected);
  });

  test('Items == 1.2 pageSize, fetchLastIfHasRemaining=true', () {
    final expected = const Paging(2, 10);
    final pagination0 = Paging.next(12, 10);
    final pagination1 = Paging.next(12, 10, true, 5);
    expect(pagination0, expected);
    expect(pagination1, expected);
  });

  test(
      'has items,totalCount > pageSize,latestCount < minimum, fetchLastIfHasRemaining=false, minimumRemainingsToTake=5',
      () {
    final expected = const Paging(2, 10);
    final pagination = Paging.next(12, 10, false, 5);
    expect(pagination, expected);
  });

  test(
      'has items,totalCount > pageSize,latestCount = minimum, fetchLastIfHasRemaining=false, minimumRemainingsToTake=5',
      () {
    final expected = const Paging(4, 5);
    final pagination = Paging.next(15, 10, false, 5);
    expect(pagination, expected);
  });

  test(
      'has items,totalCount > pageSize,latestCount > minimum, fetchLastIfHasRemaining=false, minimumRemainingsToTake=5',
      () {
    expect(Paging.next(160, 100, false, 5), const Paging(5, 40));
    expect(Paging.next(190, 100, false, 5), const Paging(20, 10));
  });

  test('Items == 1.5 pageSize, fetchLastIfHasRemaining=true, minimumRemainingsToTake=0', () {
    final expected = const Paging(2, 10);
    final pagination = Paging.next(15, 10);
    expect(pagination, expected);
  });

  test('Items == 2 * pageSize', () {
    final expected = const Paging(3, 10);
    final pagination = Paging.next(20, 10);
    expect(pagination, expected);
  });
}
