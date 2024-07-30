import 'package:drift/drift.dart';
import 'package:drift/web.dart';

LazyDatabase constructDb() {
  return LazyDatabase(() async {
    return WebDatabase('db');
  });
}