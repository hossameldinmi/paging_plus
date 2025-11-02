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

  test('Items == 1.2 pageSize, fetchLatestIfHasRemaining=true', () {
    final expected = const Paging(2, 10);
    final pagination0 = Paging.next(12, 10);
    final pagination1 = Paging.next(12, 10, true, 5);
    expect(pagination0, expected);
    expect(pagination1, expected);
  });

  test(
      'has items,totalCount > pageSize,latestCount < minimum, fetchLatestIfHasRemaining=false, minimumRemainingsToTake=5',
      () {
    final expected = const Paging(2, 10);
    final pagination = Paging.next(12, 10, false, 5);
    expect(pagination, expected);
  });

  test(
      'has items,totalCount > pageSize,latestCount = minimum, fetchLatestIfHasRemaining=false, minimumRemainingsToTake=5',
      () {
    final expected = const Paging(4, 5);
    final pagination = Paging.next(15, 10, false, 5);
    expect(pagination, expected);
  });

  test(
      'has items,totalCount > pageSize,latestCount > minimum, fetchLatestIfHasRemaining=false, minimumRemainingsToTake=5',
      () {
    expect(Paging.next(160, 100, false, 5), const Paging(5, 40));
    expect(Paging.next(190, 100, false, 5), const Paging(20, 10));
    expect(Paging.next(136, 50, false, 5), const Paging(10, 15, true));
    expect(Paging.next(168, 100, false, 5), const Paging(6, 33, true));
    expect(Paging.next(199, 100, false, 5), const Paging(200, 1, false));
  });
  test(
      'has items,totalCount > pageSize,latestCount > minimum, fetchLatestIfHasRemaining=false, minimumRemainingsToTake=5, and minimum to request',
      () {
    expect(Paging.next(160, 100, false, 5, 40), const Paging(5, 40));
    expect(Paging.next(190, 100, false, 5, 20), const Paging(10, 20, true));
    expect(Paging.next(136, 50, false, 5, 14), const Paging(10, 15, true));
    expect(Paging.next(168, 100, false, 5, 35), const Paging(5, 40, true));
    expect(Paging.next(199, 100, false, 5), const Paging(200, 1, false));
    expect(Paging.next(199, 100, false, 5, 25), const Paging(8, 25, true));
  }, skip: 'todo: implement minimumToRequest');

  test('Items == 1.5 pageSize, fetchLatestIfHasRemaining=true, minimumRemainingsToTake=0', () {
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
