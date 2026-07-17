// lib/utils/character_share.dart
//
// Serializza/deserializza un PGBase in un codice testuale condivisibile
// (es. tramite WhatsApp), cosi' un giocatore puo' mandare il proprio
// personaggio al Master perche' lo carichi tra "I Miei Personaggi".

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

import '../factory_pg_base.dart';

/// Prefisso dei codici generati dalla v1 dell'app: JSON -> base64, senza
/// compressione. Non piu' prodotto da [esportaPersonaggio], ma ancora
/// riconosciuto in importazione per non rompere i codici gia' condivisi
/// prima dell'introduzione della compressione.
const String _prefissoCodiceV1 = 'DNDMA1:';

/// Prefisso dei codici correnti: JSON -> deflate (zlib) -> base64. La
/// compressione riduce sensibilmente la lunghezza del codice (il JSON di
/// una scheda ha molte chiavi ripetute e campi vuoti/di default), rendendolo
/// piu' comodo da incollare in chat.
const String _prefissoCodiceV2 = 'DNDMA2:';

/// Estensione del file esportato: registrata in AndroidManifest.xml cosi'
/// che, ricevuto ad es. da WhatsApp, un tap sul file apra direttamente
/// questa app invece di un visualizzatore generico.
const String estensioneFileEsportazione = '.dnd';

/// Codifica [pg] in un codice testuale compatto da condividere (es. via il
/// pannello di condivisione nativo). Il JSON viene compresso (zlib) prima
/// del base64, per restare leggibile/incollabile in qualunque app di
/// messaggistica senza andare in conflitto con virgolette o a-capo, ma il
/// piu' corto possibile.
String esportaPersonaggio(PGBase pg) {
  final jsonBytes = utf8.encode(jsonEncode(pg.toJson()));
  final compresso = const ZLibEncoder().encodeBytes(jsonBytes);
  return _prefissoCodiceV2 + base64Encode(compresso);
}

/// Decodifica un codice prodotto da [esportaPersonaggio] (o da una versione
/// precedente dell'app) e ricostruisce il [PGBase]. Lancia [FormatException]
/// se il codice non e' valido.
PGBase importaPersonaggio(String codice) {
  final pulito = codice.trim();
  final Map<String, dynamic> json;
  try {
    if (pulito.startsWith(_prefissoCodiceV2)) {
      final compresso = base64Decode(
        pulito.substring(_prefissoCodiceV2.length),
      );
      final jsonBytes = const ZLibDecoder().decodeBytes(compresso);
      json = jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;
    } else if (pulito.startsWith(_prefissoCodiceV1)) {
      final jsonString = utf8.decode(
        base64Decode(pulito.substring(_prefissoCodiceV1.length)),
      );
      json = jsonDecode(jsonString) as Map<String, dynamic>;
    } else {
      throw const FormatException(
        'Codice non riconosciuto: assicurati di aver incollato l\'intero '
        'codice ricevuto.',
      );
    }
  } on FormatException {
    rethrow;
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
