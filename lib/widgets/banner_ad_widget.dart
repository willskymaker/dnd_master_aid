import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Ad unit ID di TEST forniti da Google (mostrano annunci finti, nessun
/// rischio di violare le policy usando per errore ID reali in sviluppo).
/// Sostituire con gli ad unit ID reali del proprio account AdMob prima
/// della pubblicazione.
const String _androidBannerTestId = 'ca-app-pub-3940256099942544/6300978111';

/// True solo sulle piattaforme dove google_mobile_ads e' supportato
/// (Android/iOS). L'SDK non esiste per web/desktop.
bool get adsSupportedPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Banner pubblicitario da mostrare in punti non invasivi dell'app (mai
/// durante il combattimento o la scheda live di un personaggio). Non
/// disegna nulla se la piattaforma non e' supportata o l'annuncio non
/// carica.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _caricato = false;

  @override
  void initState() {
    super.initState();
    if (adsSupportedPlatform) _caricaBanner();
  }

  void _caricaBanner() {
    final banner = BannerAd(
      adUnitId: _androidBannerTestId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _caricato = true);
        },
        onAdFailedToLoad: (ad, error) => ad.dispose(),
      ),
    );
    banner.load();
    _bannerAd = banner;
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _bannerAd;
    if (!adsSupportedPlatform || !_caricato || banner == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: banner.size.width.toDouble(),
      height: banner.size.height.toDouble(),
      child: AdWidget(ad: banner),
    );
  }
}
