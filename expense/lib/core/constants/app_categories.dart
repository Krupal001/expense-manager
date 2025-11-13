import 'package:flutter/material.dart';

class AppCategories {
  // Main expense categories
  static const List<String> expenseCategories = [
    'Food',
    'Groceries',
    'Transport',
    'Shopping',
    'Bills',
    'Rent',
    'Entertainment',
    'Health',
    'Education',
    'Milk',
    'Other',
  ];

  // Income categories
  static const List<String> incomeCategories = [
    'Salary',
    'Business',
    'Investment',
    'Freelance',
    'Gift',
    'Other',
  ];

  // All categories combined (for analytics)
  static const List<String> allCategories = [
    'All',
    ...expenseCategories,
    ...incomeCategories,
  ];

  // Category icons mapping
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'groceries':
        return Icons.shopping_cart;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'rent':
        return Icons.home;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'milk':
        return Icons.local_drink;
      case 'salary':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'investment':
        return Icons.trending_up;
      case 'freelance':
        return Icons.laptop;
      case 'gift':
        return Icons.card_giftcard;
      case 'all':
        return Icons.all_inclusive;
      default:
        return Icons.category;
    }
  }

  // Category colors mapping
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'groceries':
        return Colors.green;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'bills':
        return Colors.red;
      case 'rent':
        return Colors.brown;
      case 'entertainment':
        return Colors.pink;
      case 'health':
        return Colors.teal;
      case 'education':
        return Colors.indigo;
      case 'milk':
        return Colors.lightBlue;
      case 'salary':
        return Colors.green;
      case 'business':
        return Colors.deepOrange;
      case 'investment':
        return Colors.amber;
      case 'freelance':
        return Colors.cyan;
      case 'gift':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }

  // Get categories based on expense type
  static List<String> getCategoriesForType(String? type) {
    if (type == 'credit') {
      return incomeCategories;
    } else {
      return expenseCategories;
    }
  }
}
