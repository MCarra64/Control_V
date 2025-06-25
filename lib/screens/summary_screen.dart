import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_styles.dart';
import '../services/summary_service.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String selectedPeriod = 'Semanal';
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  late Future<SummaryData> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _loadSummary();
  }

  Future<SummaryData> _loadSummary() {
    return SummaryService().fetchSummary(
      selectedPeriod.toLowerCase(),
      year: selectedPeriod == 'Anual' ? selectedYear : null,
      month: selectedPeriod == 'Mensual' ? selectedMonth : null,
    );
  }

  void _refreshSummary() {
    setState(() {
      _summaryFuture = _loadSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.lightBackground,
      appBar: AppBar(
        title: const Text('Resumen de Ventas'),
        backgroundColor: AppStyles.primaryGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 8),
            if (selectedPeriod == 'Mensual') _buildMonthSelector(),
            if (selectedPeriod == 'Anual') _buildYearSelector(),
            const SizedBox(height: 16),
            _buildCurrentData(),
          ],
        ),
      ),
    );
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
              _refreshSummary();
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
          _refreshSummary();
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
          _refreshSummary();
        });
      },
    );
  }

  Widget _buildCurrentData() {
    return FutureBuilder<SummaryData>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('No hay datos');
        }

        final data = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bruto actual: Lps. ${data.bruto.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontSize: 16),
            ),
            Text(
              'Neto actual: Lps. ${data.neto.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.blue, fontSize: 16),
            ),
            Text(
              'Gasto actual: Lps. ${data.gasto.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        );
      },
    );
  }
}