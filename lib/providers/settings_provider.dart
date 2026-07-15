import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Impostazioni del Master per attivare/disattivare funzionalita' che
/// possono far somigliare Master Aid a un videogioco piu' che a un gdr.
/// Disattivate di default: il Master le attiva solo se le vuole al tavolo.
class SettingsProvider extends ChangeNotifier {
  static const _chiaveRandomizzazionePg = 'settings_randomizzazione_pg';
  static const _chiaveBarraSaluteMostri = 'settings_barra_salute_mostri';

  bool _randomizzazionePgAttiva = false;
  bool _barraSaluteMostriAttiva = false;

  bool get randomizzazionePgAttiva => _randomizzazionePgAttiva;
  bool get barraSaluteMostriAttiva => _barraSaluteMostriAttiva;

  Future<void> carica() async {
    final prefs = await SharedPreferences.getInstance();
    _randomizzazionePgAttiva = prefs.getBool(_chiaveRandomizzazionePg) ?? false;
    _barraSaluteMostriAttiva = prefs.getBool(_chiaveBarraSaluteMostri) ?? false;
    notifyListeners();
  }

  Future<void> setRandomizzazionePg(bool attiva) async {
    _randomizzazionePgAttiva = attiva;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chiaveRandomizzazionePg, attiva);
  }

  Future<void> setBarraSaluteMostri(bool attiva) async {
    _barraSaluteMostriAttiva = attiva;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_chiaveBarraSaluteMostri, attiva);
  }
}
