part of 'upgrade.dart';

Future<void> upgrade3(DBase db) async {
  try {
    await db.exec('BEGIN');
    await db.exec('''
      CREATE TABLE "patient" (
        id serial4 NOT NULL,
        dt timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
        last_name text DEFAULT ''::text NOT NULL,
        first_name text DEFAULT ''::text NOT NULL,
        middle_name text DEFAULT ''::text NOT NULL,
        birth date DEFAULT CURRENT_DATE NOT NULL,
        gender bool DEFAULT true NOT NULL,
        address text DEFAULT ''::text NOT NULL,
        phone_home text DEFAULT ''::text NOT NULL,
        phone_work text DEFAULT ''::text NOT NULL,
        phone text DEFAULT ''::text NOT NULL,
        email text DEFAULT ''::text NOT NULL,
        begin_observation date DEFAULT CURRENT_DATE NOT NULL,
        notes text DEFAULT ''::text NOT NULL,
        "scale" float8 DEFAULT 1 NOT NULL,
        offset_x float8 DEFAULT 0 NOT NULL,
        offset_y float8 DEFAULT 0 NOT NULL
      );
    ''');
    await db.exec('''
      CREATE UNIQUE INDEX patient_id_idx ON "patient" USING btree (id);
    ''');
    await db.exec('''
      CREATE TABLE "dental_exam" (
        id serial4 NOT NULL,
        dt timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
        patient_id int4 NOT NULL
      );
    ''');
    await db.exec('''
      CREATE UNIQUE INDEX dental_exam_id_idx ON "dental_exam" USING btree (id);
    ''');
    // type = 1 - exam, 2 - plan, 3 - fact
    // select = 1 - one, 2 - left, 3 - right, 4 - all
    await db.exec('''
      CREATE TABLE "dental_item" (
        id serial4 NOT NULL,
        dt timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
        "type" int4 NOT NULL,
        parent_id int4 NOT NULL,
        index int4 NOT NULL,
        tool_id int4 NOT NULL,
        btn_id int4 DEFAULT 0 NOT NULL,
        "select" int4 NOT NULL
      );
    ''');
    await db.exec('''
      CREATE UNIQUE INDEX dental_item_id_idx ON "dental_item" USING btree (id);
    ''');
    await db.exec('''
      CREATE INDEX dental_item_second_idx ON "dental_item" USING btree ("type", parent_id, index, tool_id, btn_id);
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
