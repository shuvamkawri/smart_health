import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class BloodPressureGraphPage extends StatelessWidget {
  final List<BloodPressureData> bloodPressureData = [
    BloodPressureData('0 - 6m___', 45, 30),
    BloodPressureData('6m - 2y', 80, 40),
    BloodPressureData('2-13', 80, 40),
    BloodPressureData('14-18', 90, 50),
    BloodPressureData('19-40', 95, 60),
    BloodPressureData('41-60', 110, 70),
    BloodPressureData('60-70', 95, 70),
    BloodPressureData('70-80', 140, 90),
    BloodPressureData('80+', 145, 98),
  ];

  List<charts.Series<BloodPressureData, String>> createBloodPressureSeries() {
    return [
      charts.Series<BloodPressureData, String>(
        id: 'Systolic',
        domainFn: (BloodPressureData data, _) => data.ageRange,
        measureFn: (BloodPressureData data, _) => data.systolic,
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
        data: bloodPressureData,
      ),
      charts.Series<BloodPressureData, String>(
        id: 'Diastolic',
        domainFn: (BloodPressureData data, _) => data.ageRange,
        measureFn: (BloodPressureData data, _) => data.diastolic,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        data: bloodPressureData,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
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
              createBloodPressureSeries(),
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
            ),
          ),
        ),
      ),
    );
  }
}

class BloodPressureData {
  final String ageRange;
  final int systolic;
  final int diastolic;

  BloodPressureData(this.ageRange, this.systolic, this.diastolic);
}
