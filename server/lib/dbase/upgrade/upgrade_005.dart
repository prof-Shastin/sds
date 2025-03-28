part of 'upgrade.dart';

Future<void> upgrade5(DBase db) async {
  try {
    await db.exec('BEGIN');
    await db.exec('''
      CREATE TABLE "anamnes" (
        id serial4 NOT NULL,
        dt timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
        patient_id int4 NOT NULL,
        anamnes_id int4 NOT NULL,
        item_id int4 NOT NULL,
        "check" bool NOT NULL,
        answer text NOT NULL
      );
    ''');
    await db.exec('''
      CREATE UNIQUE INDEX anamnes_id_idx ON "anamnes" USING btree (id);
    ''');
    await db.exec('''
      CREATE INDEX anamnes_patient_id_idx ON "anamnes" USING btree (patient_id);
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
