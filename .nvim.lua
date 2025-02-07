require("flutter-tools").setup_project({
	{
		name = "Default",
	},
	{
		name = "External lib",
		dart_define = {
			FFI_SUPPLIER_LIBS_DIR = "../suppliers/target/release/",
			FFI_SUPPLIER_LIB_NAME = "strumok_suppliers",
		},
	},
})
