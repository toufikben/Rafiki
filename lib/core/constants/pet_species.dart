class PetSpecies {
  static const String cat = 'cat';
  static const String dog = 'dog';
  static const String bunny = 'bunny';

  static const List<String> all = [cat, dog, bunny];

  static String emoji(String species) {
    switch (species) {
      case cat:
        return '🐱';
      case dog:
        return '🐶';
      case bunny:
        return '🐰';
      default:
        return '🐾';
    }
  }
}
