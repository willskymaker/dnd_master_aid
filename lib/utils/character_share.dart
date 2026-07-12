// lib/utils/character_share.dart
//
// Serializza/deserializza un PGBase in un codice testuale condivisibile
// (es. tramite WhatsApp), cosi' un giocatore puo' mandare il proprio
// personaggio al Master perche' lo carichi tra "I Miei Personaggi".

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../factory_pg_base.dart';

/// Prefisso che identifica un codice personaggio valido e ne marca la
/// versione del formato, per poter evolvere il formato in futuro senza
/// rompere l'import di codici generati da versioni precedenti dell'app.
const String _prefissoCodice = 'DNDMA1:';

/// Estensione del file esportato: registrata in AndroidManifest.xml cosi'
/// che, ricevuto ad es. da WhatsApp, un tap sul file apra direttamente
/// questa app invece di un visualizzatore generico.
const String estensioneFileEsportazione = '.dnd';

/// Codifica [pg] in un codice testuale da condividere (es. via il pannello
/// di condivisione nativo). Il codice e' un blob base64 per restare
/// leggibile/incollabile in qualunque app di messaggistica, senza andare
/// in conflitto con virgolette o a-capo del JSON sottostante.
String esportaPersonaggio(PGBase pg) {
  final jsonString = jsonEncode(pg.toJson());
  return _prefissoCodice + base64Encode(utf8.encode(jsonString));
}

/// Decodifica un codice prodotto da [esportaPersonaggio] e ricostruisce il
/// [PGBase]. Lancia [FormatException] se il codice non e' valido.
PGBase importaPersonaggio(String codice) {
  final pulito = codice.trim();
  if (!pulito.startsWith(_prefissoCodice)) {
    throw const FormatException(
      'Codice non riconosciuto: assicurati di aver incollato l\'intero '
      'codice ricevuto.',
    );
  }
  final base64Body = pulito.substring(_prefissoCodice.length);
  final Map<String, dynamic> json;
  try {
    final jsonString = utf8.decode(base64Decode(base64Body));
    json = jsonDecode(jsonString) as Map<String, dynamic>;
  } catch (_) {
    throw const FormatException('Codice corrotto o incompleto.');
  }
  return PGBase.fromJson(json);
}

String _nomeFileSicuro(String nome) {
  final pulito = nome.trim().isEmpty ? 'personaggio' : nome.trim();
  return pulito.replaceAll(RegExp(r'[^\w\-]+'), '_');
}

/// Scrive il codice di [pg] in un file temporaneo con estensione
/// [estensioneFileEsportazione], da condividere con [Share.shareXFiles].
/// Solo per piattaforme native (Android/iOS/desktop): su web non esiste il
/// concetto di file scaricabile e riapribile con un tap, quindi va usata
/// [esportaPersonaggio] con la condivisione testuale semplice.
Future<File> creaFileEsportazione(PGBase pg) async {
  final dir = await getTemporaryDirectory();
  final nomeFile = '${_nomeFileSicuro(pg.nome)}$estensioneFileEsportazione';
  final file = File('${dir.path}/$nomeFile');
  return file.writeAsString(esportaPersonaggio(pg));
}

/// Legge un file esportato da [creaFileEsportazione] (es. ricevuto da
/// un'altra app tramite receive_sharing_intent) e ricostruisce il
/// [PGBase]. Lancia [FormatException] se il contenuto non e' un codice
/// valido.
Future<PGBase> importaPersonaggioDaFile(String percorso) async {
  final contenuto = await File(percorso).readAsString();
  return importaPersonaggio(contenuto);
}
