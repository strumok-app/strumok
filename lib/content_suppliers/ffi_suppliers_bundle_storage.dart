import 'dart:io';
import 'package:strumok/content_suppliers/ffi_supplier_bundle_info.dart';
import 'package:strumok/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

const ffiSupplierBundleDir = "ffi";

class FFISuppliersBundleStorage {
  FFISuppliersBundleStorage._internal();

  static final FFISuppliersBundleStorage _instance =
      FFISuppliersBundleStorage._internal();

  factory FFISuppliersBundleStorage() {
    return _instance;
  }

  late String libsDir;

  Future<void> init() async {
    final basePath = (await getApplicationSupportDirectory()).path;

    libsDir = "$basePath${Platform.pathSeparator}$ffiSupplierBundleDir";

    await Directory(libsDir).create();
  }

  String getLibFilePath(FFISupplierBundleInfo info) {
    final libName = info.libName;
    final libFileName = Platform.isWindows ? "$libName.dll" : "lib$libName.so";

    return "$libsDir${Platform.pathSeparator}$libFileName";
  }

  Future<bool> isInstalled(FFISupplierBundleInfo info) async {
    return File(getLibFilePath(info)).exists();
  }

  Future<void> cleanup(FFISupplierBundleInfo info) async {
    try {
      final files = await Directory(libsDir).list().toList();

      for (var file in files) {
        if (file.path.contains(info.name) &&
            !file.path.contains(info.version.toString())) {
          await file.delete();
        }
      }
    } catch (error) {
      logger.w("Cant remove ffi lib: $error");
    }
  }
}
