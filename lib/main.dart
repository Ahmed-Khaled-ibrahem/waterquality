import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:waterquality/solution.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Quality Prediction',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Interpreter _interpreter;
  double pH = 9;
  double tds = 200;
  double turbidity = 1;
  double temp = 24;
  String prediction = '';

  final server = '377c382160b742fdb1606e23ea7b9400.s1.eu.hivemq.cloud';
  final port = 8883;
  final username = 'espuser';
  final password = 'espuser123Aa#';

  @override
  void initState() {
    super.initState();
    _loadModel().then((val) {
      _predict();
      setState(() {});
    });
    connectToMQTT();
  }

  void connectToMQTT() async {

    var mqttClient = MqttServerClient.withPort(
        server,
        'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
        port);
    mqttClient.keepAlivePeriod = 60;
    mqttClient.secure = true;
    mqttClient.securityContext = SecurityContext.defaultContext;
    mqttClient.onDisconnected = () {
      print('MQTT Disconnected');
    };
    await mqttClient.connect(username, password);


    if (mqttClient.connectionStatus?.state == MqttConnectionState.connected) {
      const topic = '#';
      mqttClient.subscribe(topic, MqttQos.exactlyOnce);

      mqttClient.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final topic = messages[0].topic;
        final MqttPublishMessage receivedMessage =
            messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
            receivedMessage.payload.message);
        print('Topic: $topic, Payload: $payload');
        if (topic == 'esp32/pH') {
          pH = double.parse(payload);
          print('ph');
        }
        if (topic == 'esp32/temp') {
          temp = double.parse(payload);
        }
        if (topic == 'esp32/tur') {
          turbidity = double.parse(payload);
        }
        if (topic == 'esp32/tds') {
          tds = double.parse(payload);
        }

        _predict();
        setState(() {});
      });
    } else {
      print('Failed to connect to the MQTT broker');
    }
  }

  // Load the TensorFlow Lite model
  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/model2.tflite');
    setState(() {});
  }

  void _predict() {
    final List<double> mean = [
      6.95397528,
      501.17456851,
      10.28957211,
      21.80392396
    ];
    final List<double> std = [1.43388503, 288.36558177, 5.797017, 13.31132815];

    // Convert input into 2D List and normalize if needed
    var rawTensor = [
      pH,
      tds,
      turbidity,
      temp
    ]; // Example input: [7.0, 200.0, 3.0, 25.0]
    // Normalize input
    List<double> normalizedInput = List.generate(
      rawTensor.length,
      (i) => (rawTensor[i] - mean[i]) / std[i], // Normalization formula
    );
    // Convert input to 2D array
    var inputTensor = [normalizedInput]; // This should be a List<List<double>>
    // var inputTensor = [rawTensor]; // This should be a List<List<double>>
    var outputTensor =
        List.filled(3, 0.0).reshape([1, 3]); // Ensure correct shape
    // Run inference
    _interpreter.run(inputTensor, outputTensor);
    print(outputTensor);

    List<String> labels = ["Good", "Average", "Not Good"];

    List out = outputTensor[0];
    List sortedList = List.from(out);
    sortedList.sort();
    int labelIndex = out.indexWhere((element) => element == sortedList.last);

    setState(() {
      prediction = labels[labelIndex];
    });
    print(prediction);
  }

  @override
  void dispose() {
    _interpreter.close(); // Make sure to release the interpreter when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Quality Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    Card(
                      elevation: 5,
                      color: Colors.teal[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              const Icon(
                                Icons.water_drop,
                                size: 50,
                              ),
                              const Text(
                                'PH',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                pH.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '0-14',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ])
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      color: Colors.orange[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              const Icon(
                                Icons.water,
                                size: 50,
                              ),
                              const Text(
                                'TDS',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                tds.toStringAsFixed(0),
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'ppm',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ])
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      color: Colors.deepPurple[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              const Icon(
                                Icons.blur_on,
                                size: 50,
                              ),
                              const Text(
                                'Turbidity',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                turbidity.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'NTU',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ])
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      color: Colors.pink[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              const Icon(
                                Icons.thermostat,
                                size: 50,
                              ),
                              const Text(
                                'Temperature',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                temp.toStringAsFixed(2),
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                              const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      '°C ',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ])
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
              const SizedBox(height: 20),
              const Divider(thickness: 2),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Model Prediction',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Builder(builder: (context) {
                if (prediction == '') {
                  return const CircularProgressIndicator();
                } else if (prediction == 'Not Good') {
                  return Column(children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Polluted',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          Icons.close,
                          size: 60,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    TextButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  Solution([pH, tds, turbidity, temp])));
                    }, child: const Text('Need help Using AI?', style: TextStyle(color: Colors.red),))
                  ]);
                }
                if (prediction == 'Good') {
                  return const Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Safe',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          Icons.done,
                          size: 60,
                          color: Colors.green,
                        )
                      ],
                    )
                  ]);
                }
                if (prediction == 'Average') {
                  return const Column(children: []);
                }
                return const Column(children: []);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
