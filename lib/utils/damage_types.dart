/// I 13 tipi di danno ufficiali D&D 5e, in italiano.
const List<String> tipiDanno = [
  'Contundente',
  'Perforante',
  'Tagliente',
  'Acido',
  'Freddo',
  'Fuoco',
  'Forza',
  'Fulmine',
  'Necrotico',
  'Veleno',
  'Psichico',
  'Radiante',
  'Tuono',
];

/// Parola chiave inglese usata in monsters.json per ciascun tipo di danno,
/// da cercare (case-insensitive, come sottostringa) nei campi
/// damage_resistances/damage_immunities/damage_vulnerabilities.
const Map<String, String> _tipoDannoInglese = {
  'Contundente': 'bludgeoning',
  'Perforante': 'piercing',
  'Tagliente': 'slashing',
  'Acido': 'acid',
  'Freddo': 'cold',
  'Fuoco': 'fire',
  'Forza': 'force',
  'Fulmine': 'lightning',
  'Necrotico': 'necrotic',
  'Veleno': 'poison',
  'Psichico': 'psychic',
  'Radiante': 'radiant',
  'Tuono': 'thunder',
};

class RisultatoDanno {
  final int dannoApplicato;
  final String? messaggio;

  const RisultatoDanno({required this.dannoApplicato, this.messaggio});
}

/// Applica resistenza/immunità/vulnerabilità di [datiMostro] (se presente)
/// a un danno di tipo [tipoDannoItaliano], secondo le regole D&D 5e:
/// immunità -> 0 danno, resistenza -> danno dimezzato (arrotondato per
/// difetto), vulnerabilità -> danno raddoppiato. Se il mostro ha sia
/// resistenza che vulnerabilità allo stesso tipo si annullano a vicenda
/// (danno pieno), come da regolamento.
RisultatoDanno applicaResistenze({
  required int danno,
  required String tipoDannoItaliano,
  required Map<String, dynamic>? datiMostro,
}) {
  if (datiMostro == null) {
    return RisultatoDanno(dannoApplicato: danno);
  }
  final chiave = _tipoDannoInglese[tipoDannoItaliano];
  if (chiave == null) {
    return RisultatoDanno(dannoApplicato: danno);
  }

  bool contiene(String campo) {
    final lista = datiMostro[campo] as List?;
    if (lista == null) return false;
    return lista.any((v) => v.toString().toLowerCase().contains(chiave));
  }

  final immune = contiene('damage_immunities');
  final resistente = contiene('damage_resistances');
  final vulnerabile = contiene('damage_vulnerabilities');

  if (immune) {
    return RisultatoDanno(
      dannoApplicato: 0,
      messaggio: 'Immune a $tipoDannoItaliano: nessun danno',
    );
  }
  if (resistente && vulnerabile) {
    return RisultatoDanno(
      dannoApplicato: danno,
      messaggio:
          'Resistente e vulnerabile a $tipoDannoItaliano: si annullano, danno pieno',
    );
  }
  if (resistente) {
    final dimezzato = danno ~/ 2;
    return RisultatoDanno(
      dannoApplicato: dimezzato,
      messaggio:
          'Resistente a $tipoDannoItaliano: danno dimezzato a $dimezzato',
    );
  }
  if (vulnerabile) {
    final raddoppiato = danno * 2;
    return RisultatoDanno(
      dannoApplicato: raddoppiato,
      messaggio:
          'Vulnerabile a $tipoDannoItaliano: danno raddoppiato a $raddoppiato',
    );
  }
  return RisultatoDanno(dannoApplicato: danno);
}
