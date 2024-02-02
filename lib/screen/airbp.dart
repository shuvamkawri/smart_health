import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math' as math;
import 'package:smarthealth/screen/standard_data_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class HeartRateData {
  final int time;
  final int heartRate;
  HeartRateData(this.time, this.heartRate);
}

class BloodPressureData {
  final int time;
  final double sysValue;
  final double diaValue;

  BloodPressureData(this.time, this.sysValue, this.diaValue);
}


class _MyHomePageState extends State<MyHomePage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? selectedDevice;
  List<BluetoothDevice> devices = [];
  List<BluetoothDevice> pairedDevices = [];
  List<String> decodedResponses = [];
  List<HeartRateData> heartRateData = [];
  List<BloodPressureData> bloodPressureData = [];

  StreamController<List<HeartRateData>> chartDataController =
  StreamController<List<HeartRateData>>.broadcast();

  StreamController<List<BloodPressureData>> bloodPressureDataController =
  StreamController<List<BloodPressureData>>.broadcast();


  @override
  void initState() {
    super.initState();
    scanAndRetrieveDevices();
  }

  Future<void> scanAndRetrieveDevices() async {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      setState(() {
        devices = results.map((result) => result.device).toList();
      });
    });

    List<BluetoothDevice> retrievedPairedDevices =
    await flutterBlue.connectedDevices;
    setState(() {
      pairedDevices = retrievedPairedDevices;
    });

    flutterBlue.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    if (selectedDevice != null &&
        selectedDevice!.state == BluetoothDeviceState.connected) {
      await selectedDevice!.disconnect();
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pairing'),
          content: Text('Please pair with the device before connecting.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _connectToDevice(device); // Connect to the device
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }


  final desiredServiceUuid = '14839ac4-7d7e-415c-9a42-167340cf2339';

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await device.connect();

    BluetoothCharacteristic? testReadCharacteristic;

    List<BluetoothService> services = await device.discoverServices();

    for (BluetoothService service in services) {
      if (service.uuid.toString() == desiredServiceUuid) {
        for (BluetoothCharacteristic characteristic in service
            .characteristics) {
          if (characteristic.properties.notify) {
            testReadCharacteristic = characteristic;
            setupCharacteristicListeners(testReadCharacteristic);

            // Send the notification command to the device
            final convertedNotificationCommand =
            utf8.encode("NOTIFICATION_COMMAND");
            await characteristic.write(convertedNotificationCommand);

            // Read initial data from the device
            readDataInRealTime(testReadCharacteristic);
          }
        }

        break;
      }
    }

    setState(() {
      selectedDevice = device;
    });
  }

  void readDataInRealTime(BluetoothCharacteristic characteristic) {
    characteristic.value.listen((response) {
      if (response.isNotEmpty) {
        var decodedResponse = utf8.decode(response);
        setState(() {
          // Parse the received data and add it to the decodedResponses list
          decodedResponses.add(decodedResponse);

          // Extract heart rate and time data and add it to the heartRateData list
          final heartRate = extractHeartRate(decodedResponse);
          final time = DateTime
              .now()
              .millisecondsSinceEpoch;
          heartRateData.add(HeartRateData(time, heartRate));

          // Extract blood pressure data and add it to the bloodPressureData list
          final bloodPressureValues = extractBloodPressure(decodedResponse);
          if (bloodPressureValues != null) {
            final sysValue = bloodPressureValues['sys'];
            final diaValue = bloodPressureValues['dia'];
            bloodPressureData.add(
                BloodPressureData(time, sysValue! as double, diaValue!));
          }
          // Emit the updated heartRateData and bloodPressureData to their respective chartDataControllers
          chartDataController.add(heartRateData);
          bloodPressureDataController.add(bloodPressureData);
        });
      }
    });
  }

  Map<String, double>? extractBloodPressure(String decodedResponse) {
    final decodedResponseArray = decodedResponse.split(", ");
    if (decodedResponseArray.length >= 19) {
      final sysValue = double.tryParse(decodedResponseArray[16]) ?? 0.0;
      print(sysValue);
      final diaValue = double.tryParse(decodedResponseArray[18]) ?? 0.0;
      print(diaValue);

      if (sysValue > 0.0 && diaValue > 0.0) {
        return {
          'sys': sysValue,
          'dia': diaValue,
        };

      }
    }

    return null;
  }


  int extractHeartRate(String decodedResponse) {
    final decodedResponseArray = decodedResponse.split(", ");
    final heartRateValue = int.tryParse(decodedResponseArray[2]) ?? 0;
    return heartRateValue > 0 ? heartRateValue : 0;
  }


  void setupCharacteristicListeners(BluetoothCharacteristic characteristic) {
    final testCommand = "TEST_COMMAND";

    characteristic.setNotifyValue(true);
    characteristic.value.listen((response) {
      try {
        final decodedResponse = List<int>.from(response.map((e) =>
            int.parse(e.toRadixString(16).replaceFirst('0x', ''), radix: 16)));

        setState(() {
          decodedResponses.add(decodedResponse.join(", "));

          final heartRate = extractHeartRate(decodedResponse.join(", "));
          final time = DateTime
              .now()
              .millisecondsSinceEpoch;
          heartRateData.add(HeartRateData(time, heartRate));


          final bloodPressureValues = extractBloodPressure(
              decodedResponse.join(", "));
          if (bloodPressureValues != null) {
            final sysValue = bloodPressureValues['sys'];
            final diaValue = bloodPressureValues['dia'];
            bloodPressureData.add(
                BloodPressureData(time, sysValue! as double, diaValue!));
          }
          // Emit the updated heartRateData to the chartDataController
          chartDataController.add(heartRateData);
          bloodPressureDataController.add(bloodPressureData);
        });
      } catch (e) {
        print('Error decoding response: $e');
        // Handle the error gracefully, e.g., display an error message
      }
    });

    final convertedTestCommand = utf8.encode(testCommand);

    // Uncomment the line below if you need to write a command to the device
    // writeData(characteristic, convertedTestCommand);
  }

  Future<void> writeData(BluetoothCharacteristic characteristic,
      List<int> data) async {
    try {
      await characteristic.write(data);
    } catch (e) {
      print('Error writing data: $e');
      // Handle the error here (e.g., display an error message)
    }
  }

  void closeBluetoothConnection() {
    flutterBlue.stopScan();
    chartDataController.close();
    bloodPressureDataController.close();
  }

  @override
  void dispose() {
    closeBluetoothConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          buildScanDevicesButton(),
          buildConnectToDeviceButton(),
          buildDeviceList(),
          buildWriteDataButton(),
          buildReceivedDataList(),
          buildHeartRateGraph(),
          buildBloodPressureGraph(),

        ],
      ),
    );
  }


  Widget buildScanDevicesButton() {
    return ElevatedButton(
      onPressed: scanAndRetrieveDevices,
      child: Text('Scan Devices'),
    );
  }

  Widget buildConnectToDeviceButton() {
    return ElevatedButton(
      onPressed: () {
        if (selectedDevice != null) {
          connectToDevice(selectedDevice!);
        }
      },
      child: Text('Connect to Device'),
    );
  }

  Widget buildDeviceList() {
    return Expanded(
      child: ListView.builder(
        itemCount: devices.length + 1 + pairedDevices.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return buildPairedDevicesHeader();
          } else if (index <= devices.length) {
            final device = devices[index - 1];
            return buildDeviceListItem(device);
          } else {
            final pairedIndex = index - devices.length - 2;
            final device = pairedDevices[pairedIndex];
            return buildDeviceListItem(device);
          }
        },
      ),
    );
  }

  Widget buildPairedDevicesHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paired Devices:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget buildDeviceListItem(BluetoothDevice device) {
    return ListTile(
      title: Text(device.name),
      onTap: () => connectToDevice(device),
    );
  }

  Widget buildWriteDataButton() {
    return ElevatedButton(
      onPressed: () {
        if (selectedDevice != null) {
          // Uncomment the line below to write data to the device
          // writeData(characteristic, "DATA_TO_WRITE");
        }
      },
      child: Text('Received Data'),
    );
  }

  Widget buildReceivedDataList() {
    return Expanded(
      child: ListView.builder(
        reverse: true,
        itemCount: decodedResponses.length,
        itemBuilder: (context, index) {
          final reversedIndex = decodedResponses.length - 1 - index;
          final decodedResponse = decodedResponses[reversedIndex];
          final decodedResponseArray = decodedResponse.split(", ");

          String dataIndexToName(int dataIndex,
              List<String> decodedResponseArray) {
            if (dataIndex == 2 && decodedResponseArray.isNotEmpty &&
                int.tryParse(decodedResponseArray[2])! > 0) {
              return 'heart rate';
            } else if (dataIndex == 16) {
              return 'sys';
            } else if (dataIndex == 18) {
              return 'dia';
              // } else if (dataIndex == 12 && decodedResponseArray[12].isNotEmpty) {
              //   return 'g';
            } else {
              return '[$dataIndex]';
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('Received Data ${reversedIndex + 1}'),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: decodedResponseArray
                    .asMap()
                    .entries
                    .map((entry) {
                  final dataIndex = entry.key;
                  final dataValue = entry.value;
                  final name = dataIndexToName(dataIndex, decodedResponseArray);

                  return Text('$name: $dataValue');
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget buildHeartRateGraph() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          child: charts.LineChart(
            chartData,
            animate: true,
            defaultRenderer: charts.LineRendererConfig(includePoints: true),
            primaryMeasureAxis: charts.NumericAxisSpec(
              tickProviderSpec: charts.BasicNumericTickProviderSpec(
                  zeroBound: false),
            ),
          ),
        ),
      ),
    );
  }

  List<charts.Series<HeartRateData, int>> createDynamicHeartRateData(
      int currentHeartRate, int heartRateIndex) {
    final heartRateData = [
      HeartRateData(1, 72),
      HeartRateData(2, 68),
      HeartRateData(3, currentHeartRate),
      HeartRateData(4, 74),
      HeartRateData(5, 78),
      HeartRateData(6, 80),
      HeartRateData(7, 75),
      HeartRateData(8, 72),
      HeartRateData(9, 70),
      HeartRateData(10, 74),
      HeartRateData(11, 68),
      HeartRateData(12, 72),
    ];

    if (heartRateIndex >= 0 && heartRateIndex < heartRateData.length) {
      heartRateData[heartRateIndex] =
          HeartRateData(heartRateIndex + 1, currentHeartRate);
    }

    final standardHeartRateData = [
      HeartRateData(1, 60),
      HeartRateData(2, 65),
      HeartRateData(3, 70),
      HeartRateData(4, 75),
      HeartRateData(5, 80),
      HeartRateData(6, 85),
      HeartRateData(7, 90),
      HeartRateData(8, 95),
      HeartRateData(9, 100),
      HeartRateData(10, 105),
      HeartRateData(11, 110),
      HeartRateData(12, 115),
    ];

    return [
      charts.Series<HeartRateData, int>(
        id: 'HeartRate',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (HeartRateData data, _) => data.time,
        measureFn: (HeartRateData data, _) => data.heartRate,
        data: heartRateData,
      ),
      charts.Series<HeartRateData, int>(
        id: 'StandardHeartRate',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        dashPatternFn: (_, __) => [2, 2],
        // Add dash pattern for the line
        domainFn: (HeartRateData data, _) => data.time,
        measureFn: (HeartRateData data, _) => data.heartRate,
        data: standardHeartRateData,
      ),
    ];
  }

  List<charts.Series<HeartRateData, int>> get chartData {
    final currentHeartRate = heartRateData.isNotEmpty ? heartRateData.last
        .heartRate : 0;
    final heartRateIndex = heartRateData.length - 1;

    return createDynamicHeartRateData(currentHeartRate, heartRateIndex);
  }

  List<charts.Series<BloodPressureData, int>> generateBloodPressureChartData(
      List<BloodPressureData> dynamicData,
      List<BloodPressureData> standardData) {
    return [
      charts.Series<BloodPressureData, int>(
        id: 'Systolic',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (BloodPressureData data, _) => data.time,
        measureFn: (BloodPressureData data, _) => data.sysValue,
        data: dynamicData,

      ),
      charts.Series<BloodPressureData, int>(
        id: 'Diastolic',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        dashPatternFn: (_, __) => [2, 2],
        domainFn: (BloodPressureData data, _) => data.time,
        measureFn: (BloodPressureData data, _) => data.diaValue,
        data: dynamicData,
      ),
    ];
  }

  Widget buildBloodPressureGraph() {
    final dynamicBloodPressureData = List.generate(100, (index) {
      final x = index / 10.0;
      return BloodPressureData(
        index,
        120 + math.sin(x) * 20, // Generate systolic blood pressure values
        80 + math.cos(x) * 10, // Generate diastolic blood pressure values
      );
    });

    final staticTickSpecs = List.generate(12, (index) {
      final tickValue = (index + 1) * 10;
      final label = (index + 1).toString();
      return charts.TickSpec<num>(tickValue, label: label);
    });

    final standardBloodPressureData = List.generate(100, (index) {
      return BloodPressureData(
        index,
        120, // Set standard systolic blood pressure value
        80,  // Set standard diastolic blood pressure value
      );
    });

    bool useStandardData = false; // Track whether to use dynamic or standard blood pressure data

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          child: Column(
            children: [
              // Display the extracted systolic and diastolic values
              StreamBuilder<List<BloodPressureData>>(
                stream: bloodPressureDataController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final latestData = snapshot.data!.last;
                    return Column(
                      children: [
                        Text('Systolic: ${latestData.sysValue}'),
                        Text('Diastolic: ${latestData.diaValue}'),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              // Display the blood pressure line chart
              Expanded(
                child: charts.LineChart(
                  generateBloodPressureChartData(
                    dynamicBloodPressureData,
                    useStandardData ? standardBloodPressureData : dynamicBloodPressureData,
                  ),
                  animate: true,
                  defaultRenderer: charts.LineRendererConfig(
                    includePoints: true,
                    includeArea: true,
                  ),
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    tickProviderSpec: charts.BasicNumericTickProviderSpec(
                      zeroBound: false,
                    ),
                  ),
                  domainAxis: charts.NumericAxisSpec(
                    tickProviderSpec: charts.StaticNumericTickProviderSpec(
                      staticTickSpecs,
                    ),
                  ),
                ),
              ),
              // Button to toggle between dynamic and standard blood pressure data
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    useStandardData = !useStandardData;
                  });
                  if (useStandardData) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StandardDataPage(),
                      ),
                    );
                  }
                },
                child: Text(
                  useStandardData ? 'Use Dynamic Data' : 'Use Standard Data',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

