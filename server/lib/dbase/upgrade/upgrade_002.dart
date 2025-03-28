part of 'upgrade.dart';

Future<void> upgrade2(DBase db) async {
  try {
    await db.exec('BEGIN');
    await db.exec('''
      CREATE TABLE "user" (
        id serial4 NOT NULL,
        dt timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
        last_name text DEFAULT ''::text NOT NULL,
        first_name text DEFAULT ''::text NOT NULL,
        middle_name text DEFAULT ''::text NOT NULL,
        "grant" int4 DEFAULT 0 NOT NULL,
        image text DEFAULT ''::text NOT NULL,
        "scale" float8 DEFAULT 1 NOT NULL,
        offset_x float8 DEFAULT 0 NOT NULL,
        offset_y float8 DEFAULT 0 NOT NULL,
        login text DEFAULT ''::text NOT NULL,
        "password" text DEFAULT ''::text NOT NULL,
        code text DEFAULT ''::text NOT NULL,
        "session" text DEFAULT ''::text NOT NULL,
        deleted bool DEFAULT false NOT NULL
      );
    ''');
    await db.exec('''
      CREATE UNIQUE INDEX user_id_idx ON "user" USING btree (id);
    ''');
    await db.exec('''
      CREATE UNIQUE INDEX user_session_idx ON "user" USING btree (session);
    ''');
    final session = Uuid().v1();
    await db.exec('''
      INSERT INTO "user" (last_name,first_name,middle_name,"grant",image,"scale",offset_x,offset_y,login,"password",code,"session",deleted) VALUES
        ('Шастин','Евгений','Николаевич',7,'',1.0,0.0,0.0,'main','1111','1111','$session',false);
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
