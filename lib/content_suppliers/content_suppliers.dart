import 'package:strumok/app_preferences.dart';
import 'package:strumok/app_secrets.dart';
import 'package:strumok/content_suppliers/ffi_suppliers_bundle_storage.dart';
import 'package:strumok/utils/logger.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:content_suppliers_dart/bundle.dart';
import 'package:content_suppliers_rust/bundle.dart';

class ContentSuppliers {
  List<ContentSupplier> _suppliers = [];
  List<ContentSupplierBundle> _bundles = [];
  Map<String, ContentSupplier> _suppliersByName = {};

  ContentSuppliers._();

  Set<String> get suppliersName => _suppliersByName.keys.toSet();

  ContentSupplier? getSupplier(String supplierName) {
    return _suppliersByName[supplierName];
  }

  Future<void> load() async {
    return reload(_getDefaultFFILibName());
  }

  Future<void> reload(String? ffiLibName) async {
    List<ContentSupplier> suppliers = [];

    for (final bundle in _bundles) {
      bundle.unload();
    }

    // THIS FLUTTER PIECE OF SHIT NOT WORKS WITHOUT CONST
    var ffiLibsDir = const String.fromEnvironment("FFI_SUPPLIER_LIBS_DIR");
    if (ffiLibsDir.isEmpty) {
      ffiLibsDir = FFISuppliersBundleStorage.instance.libsDir;
    }
    logger.i("FFI libs directory: $ffiLibsDir");

    _bundles = [
      DartContentSupplierBundle(tmdbSecret: AppSecrets.getString("tmdb")),
      if (ffiLibName != null)
        RustContentSuppliersBundle(
          directory: ffiLibsDir,
          libName: ffiLibName,
        ),
    ];

    for (final bundle in _bundles) {
      try {
        await bundle.load();
        suppliers += await bundle.suppliers;
      } catch (e) {
        logger.w("Fail to load suppliers bundle $bundle: $e");
      }
    }
    _suppliers = suppliers;
    _suppliersByName = {for (var s in suppliers) s.name: s};
  }

  Stream<Map<String, List<ContentInfo>>> search(
    String query,
    Set<String> contentSuppliers,
    Set<ContentType> contentTypes,
  ) async* {
    final results = <String, List<ContentInfo>>{};
    for (var supplierName in contentSuppliers) {
      final supplier = getSupplier(supplierName);

      if (supplier == null ||
          supplier.supportedTypes.intersection(contentTypes).isEmpty) {
        continue;
      }

      try {
        final res = await supplier.search(query, contentTypes);
        results[supplier.name] = res;
        yield results;
      } catch (error, stackTrace) {
        logger.e("Supplier ${supplier.name} fail",
            error: error, stackTrace: stackTrace);
      }
    }

    yield results;
  }

  Future<List<ContentInfo>> loadRecommendationsChannel(
      String supplierName, String channel,
      {page = 1}) async {
    logger.i(
        "Loading content supplier: $supplierName recommendations channel: $channel");

    final supplier = getSupplier(supplierName);

    if (supplier == null) {
      return [];
    }

    return supplier.loadChannel(channel, page: page);
  }

  Future<ContentDetails> detailsById(String supplierName, String id) async {
    logger.i("Load content details supplier: $supplierName id: $id");

    final supplier =
        _suppliers.where((e) => e.name == supplierName).firstOrNull;

    if (supplier == null) {
      throw Exception("No supplier $supplierName found");
    }

    ContentDetails? details;
    try {
      details = await supplier.detailsById(id);
    } catch (error, stackTrace) {
      logger.e("Supplier $supplier fail with $id",
          error: error, stackTrace: stackTrace);

      rethrow;
    }

    if (details == null) {
      throw Exception("Details not found by supplier: $supplier and id: $id");
    }

    return details;
  }

  static final ContentSuppliers instance = ContentSuppliers._();

  static String? _getDefaultFFILibName() {
    var libName = const String.fromEnvironment("FFI_SUPPLIER_LIB_NAME");
    if (libName.isEmpty) {
      final bundleInfo = AppPreferences.ffiSupplierBundleInfo;
      if (bundleInfo != null) {
        return bundleInfo.libName;
      } else {
        return null;
      }
    }
    return libName;
  }
}
