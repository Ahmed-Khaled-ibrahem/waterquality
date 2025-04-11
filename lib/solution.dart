import 'package:flutter/material.dart';

class Solution extends StatefulWidget {
  Solution(this.sensors, {super.key});

  List sensors = [];

  @override
  State<Solution> createState() => _SolutionState();
}

class _SolutionState extends State<Solution> {
  double pH = 0;
  double tds = 0;
  double turbidity = 0;
  double temp = 0;

  @override
  void initState() {
    super.initState();
    pH = widget.sensors[0];
    tds = widget.sensors[1];
    turbidity = widget.sensors[2];
    temp = widget.sensors[3];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Builder(builder: (context) {
              if (pH > 8) {
                return const Column(children: [
                  Icon(
                    Icons.warning,
                    size: 80,
                    color: Colors.pink,
                  ),
                  Text('Possible Issue'),
                  Text(
                    'Water is too basic',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    height: 20,
                    thickness: 2,
                  ),
                  Text('Suggested Solution'),
                  Text(
                    'Use a PH adjuster',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  // Text('(lime for low pH, vinegar for high pH)'),
                  Text('Vinegar can be a good solution'),
                ]);
              }
              if (pH < 4) {
                return const Column(children: [
                  Icon(
                    Icons.warning,
                    size: 80,
                    color: Colors.pink,
                  ),
                  Text('Possible Issue'),
                  Text(
                    'Water is too acidic',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    height: 20,
                    thickness: 2,
                  ),
                  Text('Suggested Solution'),
                  Text(
                    'Use a PH adjuster',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  Text('Lime can be a good solution'),
                ]);
              }
              if(tds > 500){
                return const Column(
                    children: [
                  Icon(
                    Icons.warning,
                    size: 80,
                    color: Colors.pink,
                  ),
                  Text('Possible Issue'),
                  Text(
                    'Too many dissolved solids',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Divider(
                    height: 20,
                    thickness: 2,
                  ),
                  Text('Suggested Solution'),
                  Text(
                    'Use a water Filter ',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ]);
              }
              if(turbidity > 2){
                return const Column(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 80,
                        color: Colors.pink,
                      ),
                      Text('Possible Issue'),
                      Text(
                        'Water is too cloudy',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Divider(
                        height: 20,
                        thickness: 2,
                      ),
                      Text('Suggested Solution'),
                      Text(
                        'Use a sediment filter',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ]);
              }
              if(temp > 35){
                return const Column(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 80,
                        color: Colors.pink,
                      ),
                      Text('Possible Issue'),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Temperature may affect water quality',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(
                        height: 20,
                        thickness: 2,
                      ),
                      Text('Suggested Solution'),
                      Text(
                        'Use a water colder',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ]);
              }
              if(temp < 10){
                return const Column(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 80,
                        color: Colors.pink,
                      ),
                      Text('Possible Issue'),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Temperature may affect water quality',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(
                        height: 20,
                        thickness: 2,
                      ),
                      Text('Suggested Solution'),
                      Text(
                        'Use a water heater',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ]);
              }
              return const Center(
                child: Text(
                  'No issues detected',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
