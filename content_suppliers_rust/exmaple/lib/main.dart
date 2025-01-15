import 'package:flutter/material.dart';
import 'package:content_suppliers_rust/bundle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = "";
  late RustContentSuppliersBundle bundle;

  @override
  void initState() {
    bundle = RustContentSuppliersBundle(
      directory: null,
      libName: "content_suppliers_rust",
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Result:',
            ),
            Text(
              _result,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await bundle.load();
                  final suppliers = await bundle.suppliers;
                  final sup = suppliers.first;
                  final r = await sup.search("1");
                  setState(() {
                    _result = r.toString();
                  });
                } catch (e) {
                  setState(() {
                    _result = "Error: $e";
                  });
                }
              },
              child: const Text("test"),
            )
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
