// Stub for web compilation to avoid dart:io _Namespace errors
class Platform {
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
  static bool get isAndroid => false;
  static bool get isIOS => false;
}

class Directory {
  final String path;
  Directory(this.path);
  static Directory get current => Directory('');
  Future<bool> exists() async => false;
  bool existsSync() => false;
  Future<Directory> create({bool recursive = false}) async => this;
  Future<void> delete({bool recursive = false}) async {}
}

class File {
  final String path;
  File(this.path);
  Future<bool> exists() async => false;
  bool existsSync() => false;
  Future<File> copy(String newPath) async => File(newPath);
  void copySync(String newPath) {}
  Future<void> writeAsString(String contents) async {}
  Future<String> readAsString() async => '';
}
