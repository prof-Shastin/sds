part of 'upgrade.dart';

Future<void> upgrade1(DBase db) async {
  try {
    await db.exec('BEGIN');
    await db.exec('''
      CREATE TABLE "version" (
        dt timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
        value int DEFAULT 0 NOT NULL
      );
    ''');
    await db.exec('''
      INSERT INTO "version" (value) VALUES (0);
    ''');
    await db.exec('COMMIT');
  } catch (e) {
    db.lastError = e.toString();
    try {
      await db.exec('ROLLBACK');
    } catch (_) {}
    throw db.lastError;
  }
}
