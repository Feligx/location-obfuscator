import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_tests/utils/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Obfuscator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        )
      ),
      home: const MyHomePage(title: 'Location Obfuscator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? ogPosition;
  String? newCoords;
  String? distance;
  final _formKey = GlobalKey<FormState>();
  final textFormController = TextEditingController();

  @override
  void dispose() {
    textFormController.dispose();
    super.dispose();
  }

  Future<dynamic> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.denied) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      return [position.latitude, position.longitude];
    } else {
      return 'permission denied';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter a max error value & push the button to get your location:',
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                child: TextFormField(
                  controller: textFormController,
                  decoration: const InputDecoration(
                    hintText: 'Max error',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a max error value';
                    }

                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }

                    if (int.parse(value) < 1) {
                      return 'Please enter a number greater than 0';
                    }

                    if (int.parse(value) > 100) {
                      return 'Please enter a number less than 100';
                    }

                    return null;
                  },
                )
            ),
            if (ogPosition != null)
              Text(
                'Original Position: $ogPosition',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (newCoords != null)
              Text(
                'Obfuscated Position: $newCoords',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if (distance != null)
              Text(
                'Distance between positions: $distance',
                style: Theme.of(context).textTheme.bodyMedium
              ),
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          final pos = await getLocation();
          final int maxErr = int.parse(textFormController.text);

          if (pos == 'permission denied') {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Permission denied')));
            return;
          }

          List obf = getCoords(pos, maxErr);

          setState(() {
            ogPosition = '(${pos[0]}, ${pos[1]})';
            newCoords = '(${obf[0][0]}, ${obf[0][1]})';
            distance = '${obf[1]}';
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.location_pin),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
