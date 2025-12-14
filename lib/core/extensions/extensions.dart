// Extensions utiles pour String
extension StringExtension on String {
  /// Capitalise la première lettre
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalise chaque mot
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Vérifie si c'est un email valide
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(this);
  }

  /// Vérifie si c'est un numéro de téléphone valide
  bool get isValidPhone {
    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(replaceAll(' ', ''));
  }

  /// Retourne les initiales (max 2 caractères)
  String get initials {
    if (isEmpty) return '?';
    final words = trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Tronque le texte avec ellipse
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

// Extensions pour les nombres
extension NumberExtension on num {
  /// Formate en devise FCFA
  String get toCurrency {
    final formatted = toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    return '$formatted FCFA';
  }

  /// Formate en pourcentage
  String toPercentage([int decimals = 0]) {
    return '${toStringAsFixed(decimals)}%';
  }
}

// Extensions pour DateTime
extension DateTimeExtension on DateTime {
  /// Formate en date courte (dd/MM/yyyy)
  String get toShortDate {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  /// Formate en date longue (dd MMMM yyyy)
  String get toLongDate {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '$day ${months[month - 1]} $year';
  }

  /// Formate en date et heure
  String get toDateTime {
    return '${toShortDate} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Vérifie si c'est aujourd'hui
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Vérifie si c'est hier
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Retourne le temps relatif (il y a X...)
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return 'il y a ${(difference.inDays / 365).floor()} an(s)';
    } else if (difference.inDays > 30) {
      return 'il y a ${(difference.inDays / 30).floor()} mois';
    } else if (difference.inDays > 0) {
      return 'il y a ${difference.inDays} jour(s)';
    } else if (difference.inHours > 0) {
      return 'il y a ${difference.inHours} heure(s)';
    } else if (difference.inMinutes > 0) {
      return 'il y a ${difference.inMinutes} minute(s)';
    } else {
      return 'à l\'instant';
    }
  }
}

// Extensions pour List
extension ListExtension<T> on List<T> {
  /// Retourne le premier élément ou null
  T? get firstOrNull => isEmpty ? null : first;

  /// Retourne le dernier élément ou null
  T? get lastOrNull => isEmpty ? null : last;

  /// Groupe les éléments par une clé
  Map<K, List<T>> groupBy<K>(K Function(T) keyFunction) {
    return fold(<K, List<T>>{}, (map, element) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => <T>[]).add(element);
      return map;
    });
  }
}
