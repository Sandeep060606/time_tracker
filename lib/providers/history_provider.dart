import 'package:flutter/foundation.dart';

import '../models/scan_history_model.dart';
import '../services/storage_service.dart';
import '../utils/date_time_utils.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._storageService);

  final StorageService _storageService;
  List<ScanHistoryModel> _history = [];
  String _searchQuery = '';
  DateTime? _filterDate;

  List<ScanHistoryModel> get history => List.unmodifiable(_history);
  String get searchQuery => _searchQuery;
  DateTime? get filterDate => _filterDate;

  List<ScanHistoryModel> get filteredHistory {
    final query = _searchQuery.trim().toLowerCase();
    return _history.where((item) {
      final matchesQuery =
          query.isEmpty ||
          item.studentQr.toLowerCase().contains(query) ||
          (item.student?.name.toLowerCase().contains(query) ?? false) ||
          item.purpose.toLowerCase().contains(query);
      final matchesDate =
          _filterDate == null ||
          DateTimeUtils.isSameDate(item.time, _filterDate!);
      return matchesQuery && matchesDate;
    }).toList();
  }

  int get totalToday => _todayItems.length;
  int get successfulToday =>
      _todayItems.where((item) => item.status == ScanStatus.success).length;
  int get failedToday =>
      _todayItems.where((item) => item.status == ScanStatus.failed).length;

  List<ScanHistoryModel> get _todayItems {
    final now = DateTime.now();
    return _history
        .where((item) => DateTimeUtils.isSameDate(item.time, now))
        .toList();
  }

  Future<void> loadHistory() async {
    _history = List<ScanHistoryModel>.of(_storageService.loadHistory())
      ..sort((a, b) => b.time.compareTo(a.time));
    notifyListeners();
  }

  Future<void> add(ScanHistoryModel item) async {
    _history = [item, ..._history];
    await _storageService.saveHistory(_history);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _history = _history.where((item) => item.id != id).toList();
    await _storageService.saveHistory(_history);
    notifyListeners();
  }

  Future<void> clear() async {
    _history = [];
    await _storageService.clearHistory();
    notifyListeners();
  }

  void updateSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void updateDateFilter(DateTime? value) {
    _filterDate = value;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadHistory();
  }
}
