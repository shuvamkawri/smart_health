import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;



class BloodPressureData {
  final String ageRange;
  final int systolicValue;
  final int diastolicValue;

  BloodPressureData({
    required this.ageRange,
    required this.systolicValue,
    required this.diastolicValue,
  });
}class BloodPressureGraphPage extends StatelessWidget {
  final List<BloodPressureData> data;

  BloodPressureGraphPage({required this.data});

  @override
  Widget build(BuildContext context) {
    List<charts.Series<BloodPressureData, String>> series = [
      charts.Series(
        id: "Systolic",
        data: data,
        domainFn: (BloodPressureData bpData, _) => bpData.ageRange,
        measureFn: (BloodPressureData bpData, _) => bpData.systolicValue,
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
      ),
      charts.Series(
        id: "Diastolic",
        data: data,
        domainFn: (BloodPressureData bpData, _) => bpData.ageRange,
        measureFn: (BloodPressureData bpData, _) => bpData.diastolicValue,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Pressure Graph'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SizedBox(
            height: 200, // Adjust the height of the graph
            child: charts.BarChart(
              series,
              animate: true,
              barGroupingType: charts.BarGroupingType.grouped, // Add this line for small gap between bars
              domainAxis: charts.OrdinalAxisSpec(
                renderSpec: charts.SmallTickRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 12,
                    color: charts.MaterialPalette.black,
                  ),
                ),
              ),
              primaryMeasureAxis: charts.NumericAxisSpec(
                renderSpec: charts.GridlineRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 12,
                    color: charts.MaterialPalette.black,
                  ),
                ),
              ),
              behaviors: [
                charts.SeriesLegend(
                  position: charts.BehaviorPosition.bottom,
                  desiredMaxColumns: 2,
                  entryTextStyle: charts.TextStyleSpec(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class StandardDataPage extends StatefulWidget {
  @override
  _StandardDataPageState createState() => _StandardDataPageState();
}

class _StandardDataPageState extends State<StandardDataPage> {
  String enteredAge = '';
  int enteredSystolic = 0;
  int enteredDiastolic = 0;
  final List<BloodPressureData> bloodPressureData = [
    BloodPressureData(
      ageRange: '0-6m_',
      systolicValue: 90,
      diastolicValue: 65,
    ),
    BloodPressureData(
      ageRange: '_6m-2y',
      systolicValue: 100,
      diastolicValue: 70,
    ),
    BloodPressureData(
      ageRange: '2-13',
      systolicValue: 120,
      diastolicValue: 70,
    ),
    BloodPressureData(
      ageRange: '14-18',
      systolicValue: 125,
      diastolicValue: 75,
    ),
    BloodPressureData(
      ageRange: '19-40',
      systolicValue: 135,
      diastolicValue: 80,
    ),
    BloodPressureData(
      ageRange: '41-60',
      systolicValue: 140,
      diastolicValue: 85,
    ),
    BloodPressureData(
      ageRange: '61-80',
      systolicValue: 145,
      diastolicValue: 90,
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Standard Blood Pressure'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Text(
                'Blood Pressure Chart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Age',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Systolic (mmHg)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Diastolic (mmHg)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  rows: bloodPressureData.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BloodPressureGraphPage(
                                    data: [data],
                                  ),
                                ),
                              );
                            },
                            child: Text(data.ageRange),
                          ),
                        ),
                        DataCell(Text(data.systolicValue.toString())),
                        DataCell(Text(data.diastolicValue.toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Blood Pressure Graph',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BloodPressureGraphPage(
                          data: bloodPressureData,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple,
                  ),
                  child: Text(
                    'Show me Graph',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Enter Your Blood Pressure'),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            enteredSystolic = int.tryParse(value) ?? 0;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Systolic'),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            enteredDiastolic = int.tryParse(value) ?? 0;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Diastolic'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          BloodPressureData newData = BloodPressureData(
                            ageRange: enteredAge,
                            systolicValue: enteredSystolic,
                            diastolicValue: enteredDiastolic,
                          );
                          setState(() {
                            bloodPressureData.add(newData);
                          });
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              AgeEntryWidget(
                onAgeEntered: (age) {
                  setState(() {
                    enteredAge = age;
                  });
                },
              ),
              Text('User Age: $enteredAge'),
              Text('User Systolic: $enteredSystolic'),
              Text('User Diastolic: $enteredDiastolic'),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class AgeEntryWidget extends StatefulWidget {
  final ValueChanged<String> onAgeEntered;

  AgeEntryWidget({required this.onAgeEntered});

  @override
  _AgeEntryWidgetState createState() => _AgeEntryWidgetState();
}

class _AgeEntryWidgetState extends State<AgeEntryWidget> {
  late TextEditingController ageController;

  @override
  void initState() {
    super.initState();
    ageController = TextEditingController();
  }

  @override
  void dispose() {
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('User Age:'),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                onChanged: widget.onAgeEntered,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onAgeEntered(ageController.text);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ],
    );
  }
}
