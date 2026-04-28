import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/models.dart';
import '../services/child_service.dart';
import '../services/api_service.dart';

class ChildrenProvider extends ChangeNotifier {
  List<Child> _children = [];
  Child? _selectedChild;
  Map<String, List<InstalledApp>> _installedApps = {};
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────
  List<Child> get children => List.unmodifiable(_children);
  Child? get selectedChild => _selectedChild;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get hasChildren => _children.isNotEmpty;

  List<InstalledApp> installedAppsFor(String deviceId) =>
      _installedApps[deviceId] ?? [];

  // ── Load Children ─────────────────────────────────────────────────
  Future<void> loadChildren() async {
    _setLoading(true);
    _clearError();
    try {
      _children = await ChildService.getChildren();
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    } finally {
      _setLoading(false);
    }
  }

  // ── Select Child ──────────────────────────────────────────────────
  void selectChild(Child child) {
    _selectedChild = child;
    notifyListeners();
  }

  // ── Register Child ────────────────────────────────────────────────
  Future<bool> registerChild({
    required String name,
    required int age,
    required String deviceId,
    required String nationality,
    required File nationalIdFile,
  }) async {
    _isSubmitting = true;
    _clearError();
    notifyListeners();
    try {
      // Step 1: Upload national ID photo
      final idUrl = await ChildService.uploadNationalId(imageFile: nationalIdFile);

      // Step 2: Register child with the returned URL
      final child = await ChildService.registerChild(
        name: name,
        age: age,
        deviceId: deviceId,
        nationality: nationality,
        nationalIdUrl: idUrl,
      );

      _children.add(child);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Update Child ──────────────────────────────────────────────────
  Future<bool> updateChild(
    String childId, {
    String? name,
    int? age,
    String? nationality,
    String? deviceId,
  }) async {
    _isSubmitting = true;
    _clearError();
    notifyListeners();
    try {
      final updated = await ChildService.updateChild(
        childId,
        name: name,
        age: age,
        nationality: nationality,
        deviceId: deviceId,
      );
      final idx = _children.indexWhere((c) => c.id == childId);
      if (idx != -1) _children[idx] = updated;
      if (_selectedChild?.id == childId) _selectedChild = updated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ── Delete Child ──────────────────────────────────────────────────
  Future<bool> deleteChild(String childId) async {
    _clearError();
    try {
      await ChildService.deleteChild(childId);
      _children.removeWhere((c) => c.id == childId);
      if (_selectedChild?.id == childId) _selectedChild = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ── Load Installed Apps ───────────────────────────────────────────
  Future<void> loadInstalledApps(String deviceId) async {
    try {
      final apps = await ChildService.getInstalledApps(deviceId);
      _installedApps[deviceId] = apps;
      notifyListeners();
    } on ApiException catch (e) {
      _setError(e.message);
    }
  }

  // ── Emergency Lock ────────────────────────────────────────────────
  Future<bool> lockDevice(String deviceId) async {
    try {
      await ChildService.setDeviceLock(deviceId, locked: true);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  Future<bool> unlockDevice(String deviceId) async {
    try {
      await ChildService.setDeviceLock(deviceId, locked: false);
      return true;
    } on ApiException catch (e) {
      _setError(e.message);
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() => _errorMessage = null;
}
