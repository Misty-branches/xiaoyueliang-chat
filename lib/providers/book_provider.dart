import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import '../models/book.dart';
import '../services/chapter_parser.dart';

class BookProvider extends ChangeNotifier {
  List<Book> _books = [];
  final Uuid _uuid = const Uuid();

  List<Book> get books => List.unmodifiable(_books);

  BookProvider() {
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final booksJson = prefs.getString('books');
    if (booksJson != null) {
      final list = jsonDecode(booksJson) as List;
      _books = list
          .map((b) => Book.fromJson(b as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _saveBooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('books', jsonEncode(_books.map((b) => b.toJson()).toList()));
  }

  /// Add a book by pasting or providing raw text content
  Future<void> addBook(String title, String content) async {
    final chapters = ChapterParser.parse(content);
    final book = Book(
      id: _uuid.v4(),
      title: title.trim().isEmpty ? '未命名书籍' : title.trim(),
      content: content,
      chapters: chapters,
    );
    _books.insert(0, book);
    await _saveBooks();
    notifyListeners();
  }

  /// Add a book from a file path (reads the file content)
  Future<void> addBookFromFile(String filePath, String fileName) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return;
      final content = await file.readAsString();
      final chapters = ChapterParser.parse(content);
      final book = Book(
        id: _uuid.v4(),
        title: fileName.replaceAll(RegExp(r'\.[^.]+$'), ''),
        content: content,
        chapters: chapters,
        filePath: filePath,
      );
      _books.insert(0, book);
      await _saveBooks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error reading file: $e');
    }
  }

  /// Open file picker to select a .txt file
  Future<void> pickAndAddBook() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
        withData: false,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path;
        if (filePath != null) {
          await addBookFromFile(filePath, file.name);
        }
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
  }

  Future<void> removeBook(String bookId) async {
    _books.removeWhere((b) => b.id == bookId);
    await _saveBooks();
    notifyListeners();
  }

  Book? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Search books by title or content
  List<Book> searchBooks(String query) {
    if (query.isEmpty) return _books;
    final lower = query.toLowerCase();
    return _books.where((b) =>
      b.title.toLowerCase().contains(lower) ||
      b.content.toLowerCase().contains(lower)
    ).toList();
  }
}
