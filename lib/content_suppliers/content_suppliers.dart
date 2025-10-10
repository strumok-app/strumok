import 'dart:io';

import 'package:content_suppliers_rust/bundle.dart';
import 'package:strumok/app_preferences.dart';
import 'package:strumok/content_suppliers/ffi_suppliers_bundle_storage.dart';
import 'package:strumok/utils/logger.dart';
import 'package:content_suppliers_api/model.dart';
import 'package:strumok/utils/trace.dart';

class ContentSuppliers {
  List<ContentSupplier> _suppliers = [];
  List<ContentSupplierBundle> _bundles = [];
  Map<String, ContentSupplier> _suppliersByName = {};

  ContentSuppliers._();

  Set<String> get suppliersName => _suppliersByName.keys.toSet();
  List<ContentSupplier> get suppliers => _suppliersByName.values.toList();

  ContentSupplier? getSupplier(String supplierName) {
    return _suppliersByName[supplierName];
  }

  Future<void> load() async {
    return reload(await _getDefaultFFIBundle());
  }

  Future<void> reload(List<ContentSupplierBundle> bundles) async {
    List<ContentSupplier> suppliers = [];

    for (final bundle in _bundles) {
      bundle.unload();
    }

    _bundles = bundles;

    for (final bundle in _bundles) {
      try {
        await bundle.load();
        suppliers += await bundle.suppliers;
      } catch (e, stackTrace) {
        traceError(
          error: e,
          stackTrace: stackTrace,
          message: "fail to load bundle: $bundle",
        );
      }
    }
    _suppliers = suppliers;
    _suppliersByName = {for (var s in suppliers) s.name: s};
  }

  Future<List<ContentInfo>> search(
    String supplierName,
    String query,
    int page,
  ) async {
    final supplier = _suppliersByName[supplierName];

    if (supplier == null) {
      return [];
    }

    return supplier.search(query, page: page);
  }

  Future<List<ContentInfo>> loadRecommendationsChannel(
    String supplierName,
    String channel, {
    page = 1,
  }) async {
    logger.info(
      "Loading content supplier: $supplierName recommendations channel: $channel",
    );

    final supplier = getSupplier(supplierName);

    if (supplier == null) {
      return [];
    }

    return supplier.loadChannel(channel, page: page);
  }

  Future<ContentDetails> detailsById(
    String supplierName,
    String id,
    Set<ContentLanguage> langs,
  ) async {
    logger.info("Load content details supplier: $supplierName id: $id");

    final supplier = _suppliers
        .where((e) => e.name == supplierName)
        .firstOrNull;

    if (supplier == null) {
      throw Exception("No supplier $supplierName found");
    }

    ContentDetails? details;
    try {
      details = await supplier.detailsById(id, langs);
    } catch (error, stackTrace) {
      traceError(
        error: error,
        stackTrace: stackTrace,
        message: "Supplier $supplier fail with $id",
      );
      rethrow;
    }

    if (details == null) {
      throw Exception("Details not found by supplier: $supplier and id: $id");
    }

    return details;
  }

  static final ContentSuppliers _instance = ContentSuppliers._();

  factory ContentSuppliers() {
    return _instance;
  }

  static Future<List<ContentSupplierBundle>> _getDefaultFFIBundle() async {
    var libName = const String.fromEnvironment("FFI_SUPPLIER_LIB_NAME");

    if (libName.isEmpty) {
      final bundleInfo = AppPreferences.ffiSupplierBundleInfo;

      if (bundleInfo != null) {
        final installed = await FFISuppliersBundleStorage().isInstalled(
          bundleInfo,
        );

        if (!installed) {
          return [];
        }

        // check api version compatablity
        if (!RustContentSuppliersBundle.isCompatible(
          bundleInfo.version.major,
        )) {
          return [];
        }

        libName = bundleInfo.libName;
      } else {
        return [];
      }
    }

    //const required
    var libDirectory = const String.fromEnvironment("FFI_SUPPLIER_LIBS_DIR");
    if (libDirectory.isNotEmpty) {
      libDirectory = Directory.current.uri.resolve(libDirectory).path;
    } else {
      libDirectory = FFISuppliersBundleStorage().libsDir;
    }

    logger.info("FFI libs directory: $libDirectory");

    return [
      RustContentSuppliersBundle(directory: libDirectory, libName: libName),
    ];
  }
}
