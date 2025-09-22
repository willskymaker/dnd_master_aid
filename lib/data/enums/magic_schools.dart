/// Enum per le scuole di magia di D&D 5e
enum MagicSchool {
  abjurazione("Abjurazione"),
  invocazione("Invocazione"),
  divinazione("Divinazione"),
  incantamento("Incantamento"),
  evocazione("Evocazione"),
  illusione("Illusione"),
  necromanzia("Necromanzia"),
  trasmutazione("Trasmutazione");

  const MagicSchool(this.displayName);

  final String displayName;

  /// Ottiene tutte le scuole di magia disponibili
  static List<String> getAllSchools() {
    return MagicSchool.values.map((school) => school.displayName).toList();
  }

  /// Verifica se una stringa è una scuola di magia valida
  static bool isValidSchool(String schoolName) {
    return getAllSchools().contains(schoolName);
  }

  /// Ottiene una scuola di magia dal nome
  static MagicSchool? fromString(String schoolName) {
    try {
      return MagicSchool.values.firstWhere(
        (school) => school.displayName == schoolName,
      );
    } catch (e) {
      return null;
    }
  }

  /// Ottiene la descrizione della scuola di magia
  String getDescription() {
    switch (this) {
      case MagicSchool.abjurazione:
        return "Magie protettive che bloccano, scacciano o proteggono";
      case MagicSchool.invocazione:
        return "Magie che evocano creature o oggetti dal nulla";
      case MagicSchool.divinazione:
        return "Magie che rivelano informazioni o prevedono il futuro";
      case MagicSchool.incantamento:
        return "Magie che influenzano la mente e i comportamenti";
      case MagicSchool.evocazione:
        return "Magie che creano energia o effetti elementali";
      case MagicSchool.illusione:
        return "Magie che ingannano i sensi o la mente";
      case MagicSchool.necromanzia:
        return "Magie che manipolano la forza vitale e la morte";
      case MagicSchool.trasmutazione:
        return "Magie che trasformano o cambiano le proprietà";
    }
  }
}