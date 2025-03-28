part of 'upgrade.dart';

Future<void> upgrade4(DBase db) async {
  int pid;
  pid = await db.createPatient({
    'last_name': 'Иванов',
    'first_name': 'Иван',
    'middle_name': 'Иванович',
    'birth': DateTime.now().subtract(Duration(days: 45 * 366)).toString(),
  });
  if (pid == 0) throw db.lastError;

  pid = await db.createPatient({
    'last_name': 'Петров',
    'first_name': 'Петр',
    'middle_name': 'Петрович',
    'birth': DateTime.now().subtract(Duration(days: 20 * 366)).toString(),
  });
  if (pid == 0) throw db.lastError;

  pid = await db.createPatient({
    'last_name': 'Сидоров',
    'first_name': 'Сидр',
    'middle_name': 'Сидорович',
    'birth': DateTime.now().subtract(Duration(days: 10 * 366)).toString(),
  });
  if (pid == 0) throw db.lastError;

  pid = await db.createPatient({
    'last_name': 'Иринова',
    'first_name': 'Ирина',
    'middle_name': 'Ириновна',
    'birth': DateTime.now().subtract(Duration(days: 35 * 366)).toString(),
    'gender': false,
  });
  if (pid == 0) throw db.lastError;

  pid = await db.createPatient({
    'last_name': 'Маринина',
    'first_name': 'Марина',
    'middle_name': 'Маринова',
    'birth': DateTime.now().subtract(Duration(days: 5 * 366)).toString(),
    'gender': false,
  });
  if (pid == 0) throw db.lastError;
}
