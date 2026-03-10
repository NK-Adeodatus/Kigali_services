import 'package:flutter/material.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  Stream<List<ListingModel>> get listingsStream => _service.getListingsStream();

  Stream<List<ListingModel>> getUserListingsStream(String userId) =>
      _service.getUserListingsStream(userId);

  Stream<List<ListingModel>> getFilteredListingsStream() {
    return listingsStream.map((listings) {
      var filtered = listings;
      if (_searchQuery.isNotEmpty) {
        filtered = filtered
            .where((l) => l.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
      if (_selectedCategory != 'All') {
        filtered = filtered.where((l) => l.category == _selectedCategory).toList();
      }
      return filtered;
    });
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> createListing(ListingModel listing) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createListing(listing);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.updateListing(id, data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteListing(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.deleteListing(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
