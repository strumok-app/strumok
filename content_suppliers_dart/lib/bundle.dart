import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/suppliers/tmdb/tmdb.dart';

class DartContentSupplierBundle extends ContentSupplierBundle {
  final String tmdbSecret;

  DartContentSupplierBundle({
    required this.tmdbSecret,
  });

  @override
  Future<List<ContentSupplier>> get suppliers => Future.value([
        TmdbSupplier(secret: tmdbSecret),
        // Anitaku(),
        // HianimeSupplier(),
        // MangaDexSupllier(),
        // UASerialSupplier(),
        // UAKinoClubSupplier(),
        // AniTubeSupplier(),
        // AnimeUASupplier(),
        // UAFilmsSupplier(),
        // UFDubSupplier(),
      ]);
}
