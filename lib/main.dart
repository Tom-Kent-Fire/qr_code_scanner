import 'package:flutter/material.dart';
import 'package:dynamsoft_capture_vision_flutter/dynamsoft_capture_vision_flutter.dart';

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
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ScannerPage(),
          HistoryPage(),
          MyCodesPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF5B6FBF),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'My Codes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Scanner Page
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  CaptureVisionRouter? _cvr;
  CameraEnhancer? _camera;
  CapturedResultReceiver? _receiver;
  String _displayString = "";
  bool _isScanning = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initSdk();
  }

  void _initSdk() async {
    try {
      // Initialize license
      await LicenseManager.initLicense(
        "t0090pwAAAGxGt/RhoGa20B78dlyM00z2OGRHiOHHk7EQ1ITiT4awYtHZQaiE2UrN7Hc9aVhHXy3zHYLRm+GIQ0Jx9quWGhiDb/WVPmAsb/Ft3vgrq6i56QloIyKQ",
      );

      // Get instances
      _cvr = CaptureVisionRouter.instance;
      _camera = CameraEnhancer.instance;

      // Set up the camera as input
      _cvr!.setInput(_camera!);

      // Set up result receiver
      _receiver = CapturedResultReceiver()
        ..onDecodedBarcodesReceived = (DecodedBarcodesResult result) async {
          if (result.items?.isNotEmpty ?? false) {
            var barcode = result.items![0];
            if (mounted) {
              setState(() {
                _displayString = "Format: ${barcode.formatString}\nText: ${barcode.text}";
              });
              _stopScanning();
            }
          }
        };

      // Add result receiver
      _cvr!.addResultReceiver(_receiver!);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _displayString = "Initialization error: $e";
        });
      }
    }
  }

  void _startScanning() async {
    if (_isScanning || !_isInitialized || _camera == null || _cvr == null) return;

    try {
      setState(() {
        _isScanning = true;
        _displayString = "";
      });

      // Open camera
      await _camera!.open();

      // Start capturing with preset template
      await _cvr!.startCapturing(EnumPresetTemplate.readBarcodes);
    } catch (e) {
      if (mounted) {
        setState(() {
          _displayString = "Error starting camera: $e";
          _isScanning = false;
        });
      }
    }
  }

  void _stopScanning() async {
    if (!_isScanning || _cvr == null || _camera == null) return;

    try {
      await _cvr!.stopCapturing();
      await _camera!.close();

      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  void dispose() {
    if (_isScanning) {
      _stopScanning();
    }
    if (_cvr != null && _receiver != null) {
      _cvr!.removeResultReceiver(_receiver!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Full screen area above bottom navigation
          if (_isScanning && _camera != null)
            // Camera view when scanning
            Positioned.fill(
              child: CameraView(cameraEnhancer: _camera!),
            )
          else
            // Play button and results when not scanning
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFF8F9FC),
                    ],
                  ),
                ),
                child: Center(
                  child: _isInitialized
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_displayString.isNotEmpty) ...[
                              const Text(
                                'Result:',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                child: Text(
                                  _displayString,
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                            InkWell(
                              onTap: _startScanning,
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF5B6FBF), Color(0xFF4A5FAE)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5B6FBF).withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 56,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Tap to Scan',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      : const CircularProgressIndicator(
                          color: Color(0xFF5B6FBF),
                        ),
                ),
              ),
            ),
          // Stop button overlay when scanning
          if (_isScanning)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: InkWell(
                  onTap: _stopScanning,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE57373), Color(0xFFD32F2F)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE57373).withValues(alpha: 0.6),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.stop,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// History Page
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Center(
        child: Text(
          'History',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// My Codes Page
class MyCodesPage extends StatelessWidget {
  const MyCodesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Center(
        child: Text(
          'My Codes',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Center(
        child: Text(
          'Settings',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}