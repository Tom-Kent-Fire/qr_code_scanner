import 'package:flutter/material.dart';
import 'package:dynamsoft_barcode_reader_bundle_flutter/dynamsoft_barcode_reader_bundle_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _displayString = ""; // used to show the barcode result


  void _launchBarcodeScanner(EnumScanningMode scanningMode) async {
    var config = BarcodeScannerConfig(license: "t0090pwAAAGxGt/RhoGa20B78dlyM00z2OGRHiOHHk7EQ1ITiT4awYtHZQaiE2UrN7Hc9aVhHXy3zHYLRm+GIQ0Jx9quWGhiDb/WVPmAsb/Ft3vgrq6i56QloIyKQ", scanningMode: scanningMode);
    BarcodeScanResult barcodeScanResult = await BarcodeScanner.launch(config);

    setState(() {
      if (barcodeScanResult.status == EnumResultStatus.canceled) {
        _displayString = "Scan canceled";
      } else if (barcodeScanResult.status == EnumResultStatus.exception) {
        _displayString = "ErrorCode: ${barcodeScanResult.errorCode}\n\nErrorString: ${barcodeScanResult.errorMessage}";
      } else {
        //EnumResultStatus.finished
        if (scanningMode == EnumScanningMode.single) {
          var barcode = barcodeScanResult.barcodes![0];
          _displayString = "Format: ${barcode!.formatString}\nText: ${barcode.text}";
        } else {
          // EnumScanningMode.multiple
          _displayString =
              "Barcodes count: ${barcodeScanResult.barcodes!.length}\n\n"
              "${barcodeScanResult.barcodes!.map((barcode) {
                return "Format: ${barcode!.formatString}\nText: ${barcode.text}";
              }).join("\n\n")}";
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Result:'),
            Text(
              _displayString,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _launchBarcodeScanner(EnumScanningMode.single),
        tooltip: 'Scan Barcodes',
        child: const Icon(Icons.qr_code_scanner),
      ), // This trailing comma makes auto-formatting nicer for build methods.
          
    );
  }
}