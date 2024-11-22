import 'dart:io';
import 'package:strumok/content_suppliers/ffi_supplier_bundle_info.dart';
import 'package:strumok/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

const ffiSupplierBundleDir = "ffi";

class FFISuppliersBundleStorage {
  FFISuppliersBundleStorage._();

  static final FFISuppliersBundleStorage instance =
      FFISuppliersBundleStorage._();

  late String libsDir;

  Future<void> setup() async {
    final basePath = (await getApplicationSupportDirectory()).path;

    libsDir = "$basePath${Platform.pathSeparator}$ffiSupplierBundleDir";

    await Directory(libsDir).create();
  }

  String getLibFilePath(FFISupplierBundleInfo info) {
    final libFileName =
        Platform.isWindows ? "${info.libName}.dll" : "lib${info.libName}.so";

    return "$libsDir${Platform.pathSeparator}$libFileName";
  }

  Future<bool> isInstalled(FFISupplierBundleInfo info) =>
      File(getLibFilePath(info)).exists();

  Future<void> cleanup(FFISupplierBundleInfo info) async {
    try {
      final files = await Directory(libsDir).list().toList();

      for (var file in files) {
        if (file.path.contains(info.name) &&
            !file.path.contains(info.version)) {
          await file.delete();
        }
      }
    } catch (error) {
      logger.w("Cant remove ffi lib: $error");
    }
  }
}
