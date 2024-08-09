import 'dart:io';
import 'dart:convert';

class Student {
  String id;
  String name;
  Map<String, double> subjects;

  Student(this.id, this.name, this.subjects);

  // Chuyển đổi đối tượng Student thành Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subjects': subjects,
    };
  }

  // Chuyển đổi Map thành đối tượng Student
  static Student fromJson(Map<String, dynamic> json) {
    return Student(
      json['id'],
      json['name'],
      Map<String, double>.from(json['subjects']),
    );
  }
}

// Tải danh sách sinh viên từ file JSON
List<Student> loadStudents() {
  final file = File('students.json');
  if (!file.existsSync()) {
    return [];
  }
  final jsonString = file.readAsStringSync();
  final List<dynamic> jsonData = json.decode(jsonString);
  return jsonData.map((json) => Student.fromJson(json)).toList();
}

// Lưu danh sách sinh viên vào file JSON
void saveStudents(List<Student> students) {
  final file = File('students.json');
  final jsonString = json.encode(students.map((student) => student.toJson()).toList());
  file.writeAsStringSync(jsonString);
}

// Hiển thị tất cả sinh viên
void displayStudents(List<Student> students) {
  if (students.isEmpty) {
    print('No students found.');
  } else {
    for (var student in students) {
      print('ID: ${student.id}, Name: ${student.name}');
      student.subjects.forEach((subject, score) {
        print('  Subject: $subject, Score: $score');
      });
    }
  }
  print('');
}

// Thêm sinh viên mới
void addStudent(List<Student> students) {
  stdout.write('Enter student ID: ');
  final id = stdin.readLineSync()!;
  stdout.write('Enter student name: ');
  final name = stdin.readLineSync()!;
  final subjects = <String, double>{};

  while (true) {
    stdout.write('Enter subject name (or type "done" to finish): ');
    final subject = stdin.readLineSync()!;
    if (subject.toLowerCase() == 'done') break;
    stdout.write('Enter score for $subject: ');
    final score = double.parse(stdin.readLineSync()!);
    subjects[subject] = score;
  }

  students.add(Student(id, name, subjects));
  saveStudents(students);
  print('Student added successfully.\n');
}

// Sửa thông tin sinh viên
void editStudent(List<Student> students) {
  stdout.write('Enter student ID to edit: ');
  final id = stdin.readLineSync()!;
  final student = students.firstWhere((student) => student.id == id, orElse: () => Student('0', 'Unknown', {}));

  if (student.id != '0') { // Kiểm tra xem có tìm thấy sinh viên không
    stdout.write('Enter new name (or press enter to skip): ');
    final newName = stdin.readLineSync();
    if (newName != null && newName.isNotEmpty) {
      student.name = newName;
    }

    while (true) {
      stdout.write('Type "add" to add a subject, "edit" to edit a subject score, "delete" to remove a subject, or "done" to finish: ');
      final action = stdin.readLineSync()!;
      if (action == 'done') break;

      if (action == 'add') {
        stdout.write('Enter subject name: ');
        final subject = stdin.readLineSync()!;
        stdout.write('Enter score for $subject: ');
        final score = double.parse(stdin.readLineSync()!);
        student.subjects[subject] = score;
      } else if (action == 'edit') {
        stdout.write('Enter subject name to edit: ');
        final subject = stdin.readLineSync()!;
        if (student.subjects.containsKey(subject)) {
          stdout.write('Enter new score for $subject: ');
          final score = double.parse(stdin.readLineSync()!);
          student.subjects[subject] = score;
        } else {
          print('Subject not found.');
        }
      } else if (action == 'delete') {
        stdout.write('Enter subject name to delete: ');
        final subject = stdin.readLineSync()!;
        if (student.subjects.containsKey(subject)) {
          student.subjects.remove(subject);
        } else {
          print('Subject not found.');
        }
      }
    }

    saveStudents(students);
    print('Student information updated successfully.\n');
  } else {
    print('Student ID not found.\n');
  }
}

// Tìm kiếm sinh viên theo tên hoặc ID
void searchStudent(List<Student> students) {
  stdout.write('Enter student name or ID to search: ');
  final searchTerm = stdin.readLineSync()!;
  final student = students.firstWhere((student) => student.id == searchTerm || student.name == searchTerm, orElse: () => Student('0', 'Unknown', {}));

  if (student.id != '0') { // Kiểm tra xem có tìm thấy sinh viên không
    print('ID: ${student.id}, Name: ${student.name}');
    student.subjects.forEach((subject, score) {
      print('  Subject: $subject, Score: $score');
    });
  } else {
    print('Student not found.\n');
  }
}

// Hiển thị sinh viên có điểm môn thi cao nhất
void displayHighestScore(List<Student> students) {
  stdout.write('Enter subject name: ');
  final subject = stdin.readLineSync()!;
  double highestScore = -1;
  final topStudents = <Student>[];

  for (var student in students) {
    if (student.subjects.containsKey(subject)) {
      final score = student.subjects[subject]!;
      if (score > highestScore) {
        highestScore = score;
        topStudents.clear();
        topStudents.add(student);
      } else if (score == highestScore) {
        topStudents.add(student);
      }
    }
  }

  if (topStudents.isEmpty) {
    print('No students found with scores in $subject.\n');
  } else {
    print('Students with the highest score in $subject:');
    for (var student in topStudents) {
      print('ID: ${student.id}, Name: ${student.name}, Score: $highestScore');
    }
  }
}

// Vòng lặp chính của chương trình
void main() {
  final students = loadStudents();

  while (true) {
    print('1. Display all students');
    print('2. Add student');
    print('3. Edit student');
    print('4. Search student by name or ID');
    print('5. Display students with highest score in a subject');
    print('6. Exit');
    stdout.write('Enter your choice: ');
    final choice = stdin.readLineSync()!;

    switch (choice) {
      case '1':
        displayStudents(students);
        break;
      case '2':
        addStudent(students);
        break;
      case '3':
        editStudent(students);
        break;
      case '4':
        searchStudent(students);
        break;
      case '5':
        displayHighestScore(students);
        break;
      case '6':
        exit(0);
      default:
        print('Invalid choice. Please try again.\n');
    }
  }
}
