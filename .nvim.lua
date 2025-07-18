require("flutter-tools").setup_project({
	{
		name = "Default",
		dart_define_from_file = "secrets.json",
		dart_define = {
			FORCE_TV_MODE = "true",
		},
	},
	{
		name = "External lib",
		dart_define = {
			FFI_SUPPLIER_LIBS_DIR = "../suppliers/target/release/",
			FFI_SUPPLIER_LIB_NAME = "strumok_suppliers",
			FORCE_TV_MODE = "false",
		},
		dart_define_from_file = "secrets.json",
	},
})
