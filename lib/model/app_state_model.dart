import 'package:flutter/foundation.dart' as foundation;

import 'singer.dart';
import 'singer_repository.dart';

double _salesTaxRate = 0.06;
double _shippingCostPerItem = 7;

class AppStateModel extends foundation.ChangeNotifier {
  // All the available singers.
  List<Singer> _availableSingers;

  // The currently selected category of singers.
  Category _selectedCategory = Category.all;

  // The IDs and quantities of singers currently in the cart.
  final _singersInCart = <int, int>{};

  Map<int, int> get singersInCart {
    return Map.from(_singersInCart);
  }

  // Total number of items in the cart.
  int get totalCartQuantity {
    return _singersInCart.values.fold(0, (accumulator, value) {
      return accumulator + value;
    });
  }

  Category get selectedCategory {
    return _selectedCategory;
  }

  // Totaled prices of the items in the cart.
  double get subtotalCost {
    return _singersInCart.keys.map((id) {
      // Extended price for singer line
      return _availableSingers[id].price * _singersInCart[id];
    }).fold(0, (accumulator, extendedPrice) {
      return accumulator + extendedPrice;
    });
  }

  // Total shipping cost for the items in the cart.
  double get shippingCost {
    return _shippingCostPerItem *
        _singersInCart.values.fold(0.0, (accumulator, itemCount) {
          return accumulator + itemCount;
        });
  }

  // Sales tax for the items in the cart
  double get tax {
    return subtotalCost * _salesTaxRate;
  }

  // Total cost to order everything in the cart.
  double get totalCost {
    return subtotalCost + shippingCost + tax;
  }

  // Returns a copy of the list of available singers, filtered by category.
  List<Singer> getSingers() {
    if (_availableSingers == null) {
      return [];
    }

    if (_selectedCategory == Category.all) {
      return List.from(_availableSingers);
    } else {
      return _availableSingers.where((p) {
        return p.category == _selectedCategory;
      }).toList();
    }
  }

  // Search the singer catalog
  List<Singer> search(String searchTerms) {
    return getSingers().where((singer) {
      return singer.name.toLowerCase().contains(searchTerms.toLowerCase());
    }).toList();
  }

  // Adds a singer to the cart.
  void addSingerToCart(int singerId) {
    if (!_singersInCart.containsKey(singerId)) {
      _singersInCart[singerId] = 1;
    } else {
      _singersInCart[singerId]++;
    }

    notifyListeners();
  }

  // Removes an item from the cart.
  void removeItemFromCart(int singerId) {
    if (_singersInCart.containsKey(singerId)) {
      if (_singersInCart[singerId] == 1) {
        _singersInCart.remove(singerId);
      } else {
        _singersInCart[singerId]--;
      }
    }

    notifyListeners();
  }

  // Returns the singer instance matching the provided id.
  Singer getSingerById(int id) {
    return _availableSingers.firstWhere((p) => p.id == id);
  }

  // Removes everything from the cart.
  void clearCart() {
    _singersInCart.clear();
    notifyListeners();
  }

  // Loads the list of available singers from the repo.
  void loadSingers() {
    _availableSingers = SingersRepository.loadSingers(Category.all);
    notifyListeners();
  }

  void setCategory(Category newCategory) {
    _selectedCategory = newCategory;
    notifyListeners();
  }
}