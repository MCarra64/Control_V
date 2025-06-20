import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/app_styles.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String selectedPeriod = 'Semanal';
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  bool showBruto = true;
  bool showNeto = true;
  bool showGasto = true;

  @override
  Widget build(BuildContext context) {
    final spots = _generateSpots();
    final double maxX = (spots.isNotEmpty) ? spots.last.x : 6;

    return Scaffold(
      backgroundColor: AppStyles.lightBackground,
      appBar: AppBar(
        title: const Text('Resumen de Ventas'),
        backgroundColor: AppStyles.primaryGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPeriodSelector(),
            if (selectedPeriod == 'Mensual') _buildMonthSelector(),
            if (selectedPeriod == 'Anual') _buildYearSelector(),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  lineBarsData: _buildLines(spots),
                  minY: 0,
                  maxY: 120,
                  minX: 0,
                  maxX: maxX,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(_getBottomLabel(value.toInt()));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value % 10 == 0 && value >= 10) {
                            return Text('${value.toInt()}');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildCheckboxes(),
            const SizedBox(height: 8),
            _buildCurrentData(),
          ],
        ),
      ),
    );
  }

  List<LineChartBarData> _buildLines(List<FlSpot> data) {
    return [
      if (showBruto)
        LineChartBarData(
          spots: data,
          isCurved: true,
          color: Colors.green,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),
      if (showNeto)
        LineChartBarData(
          spots: data.map((s) => FlSpot(s.x, s.y * 0.7)).toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),
      if (showGasto)
        LineChartBarData(
          spots: data.map((s) => FlSpot(s.x, s.y * 0.5)).toList(),
          isCurved: true,
          color: Colors.red,
          barWidth: 3,
          dotData: FlDotData(show: true),
        ),
    ];
  }

  List<FlSpot> _generateSpots() {
    if (selectedPeriod == 'Semanal') {
      return List.generate(7, (i) => FlSpot(i.toDouble(), (i + 1) * 10.0));
    } else if (selectedPeriod == 'Mensual') {
      int daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
      int step = (daysInMonth / 7).ceil(); 
      return List.generate(
        (daysInMonth / step).ceil(),
        (i) {
          int day = (i * step) + 1;
          if (day > daysInMonth) day = daysInMonth;
          return FlSpot(i.toDouble(), (day) * 5.0);
        },
      );
    } else if (selectedPeriod == 'Anual') {
      return List.generate(12, (i) => FlSpot(i.toDouble(), (i + 1) * 8.0));
    }
    return [];
  }

  String _getBottomLabel(int index) {
    if (selectedPeriod == 'Semanal') {
      final daysES = ['D', 'L', 'M', 'Mi', 'J', 'V', 'S'];
      return daysES[index % 7];
    } else if (selectedPeriod == 'Mensual') {
      int daysInMonth = DateUtils.getDaysInMonth(selectedYear, selectedMonth);
      int step = (daysInMonth / 7).ceil();
      int day = (index * step) + 1;
      if (day > daysInMonth) day = daysInMonth;
      return '$day';
    } else if (selectedPeriod == 'Anual') {
      return '${index + 1}';
    }
    return '';
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Periodo:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textDark),
        ),
        DropdownButton<String>(
          value: selectedPeriod,
          items: const [
            DropdownMenuItem(value: 'Semanal', child: Text('Semanal')),
            DropdownMenuItem(value: 'Mensual', child: Text('Mensual')),
            DropdownMenuItem(value: 'Anual', child: Text('Anual')),
          ],
          onChanged: (value) {
            setState(() {
              selectedPeriod = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return DropdownButton<int>(
      value: selectedMonth,
      items: List.generate(12, (i) {
        return DropdownMenuItem(
          value: i + 1,
          child: Text(DateFormat.MMMM().format(DateTime(0, i + 1))),
        );
      }),
      onChanged: (value) {
        setState(() {
          selectedMonth = value!;
        });
      },
    );
  }

  Widget _buildYearSelector() {
    return DropdownButton<int>(
      value: selectedYear,
      items: List.generate(10, (i) {
        int year = DateTime.now().year - i;
        return DropdownMenuItem(
          value: year,
          child: Text('$year'),
        );
      }),
      onChanged: (value) {
        setState(() {
          selectedYear = value!;
        });
      },
    );
  }

  Widget _buildCheckboxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Checkbox(
              value: showBruto,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  showBruto = value!;
                });
              },
            ),
            const Text('Bruto'),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: showNeto,
              activeColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  showNeto = value!;
                });
              },
            ),
            const Text('Neto'),
          ],
        ),
        Row(
          children: [
            Checkbox(
              value: showGasto,
              activeColor: Colors.red,
              onChanged: (value) {
                setState(() {
                  showGasto = value!;
                });
              },
            ),
            const Text('Gasto'),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentData() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Bruto actual: Lps. 1,200,000', style: TextStyle(color: Colors.green)),
          Text('Neto actual: Lps. 840,000', style: TextStyle(color: Colors.blue)),
          Text('Gasto actual: Lps. 600,000', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }
}
