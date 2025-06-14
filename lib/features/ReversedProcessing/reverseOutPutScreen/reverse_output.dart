import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wiresense_frontend/main.dart';

class ReverseOutput extends StatefulWidget {
  const ReverseOutput({super.key});

  @override
  State<ReverseOutput> createState() => _ReverseOutputState();
}

class _ReverseOutputState extends State<ReverseOutput> {
  Map<String, dynamic>? apiResponse;

  double? uts;
  double? elongation;
  double? conductivity;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && uts == null) {
      uts = double.tryParse(args['UTS'].toString());
      elongation = double.tryParse(args['Elongation'].toString());
      conductivity = double.tryParse(args['Conductivity'].toString());
      callReverseApi(); // only once after getting args
    }
    else{
      uts = 10.85;
      conductivity = 61.27;
      elongation = 13.40;
      callReverseApi();
    }
  }

  Future<void> callReverseApi() async {
    final uri = Uri.parse('http://127.0.0.1:8000/api/reverse/'); // todo - your actual API
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      "UTS": uts,
      "Elongation": elongation,
      "Conductivity": conductivity,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 200) {
        setState(() {
          apiResponse = jsonDecode(response.body);
        });
      } else {
        debugPrint("API error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Exception while calling API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (apiResponse == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final parameters = [
      {
        'name': 'EMUL OIL TEMP',
        'value': '${apiResponse!["EMUL_OIL_L_TEMP_PV_VAL0"]?.toStringAsFixed(2)} °C',
        'progress': _progress(apiResponse!["EMUL_OIL_L_TEMP_PV_VAL0"], 40, 70),
        'color': Colors.blue,
        'lightColor': Colors.blue[100],
      },
      {
        'name': 'STAND OIL TEMP',
        'value': '${apiResponse!["STAND_OIL_L_TEMP_PV_REAL_VAL0"]?.toStringAsFixed(2)} °C',
        'progress': _progress(apiResponse!["STAND_OIL_L_TEMP_PV_REAL_VAL0"], 40, 65),
        'color': Colors.teal,
        'lightColor': Colors.teal[100],
      },
      {
        'name': 'GEAR OIL TEMP',
        'value': '${apiResponse!["GEAR_OIL_L_TEMP_PV_REAL_VAL0"]?.toStringAsFixed(2)} °C',
        'progress': _progress(apiResponse!["GEAR_OIL_L_TEMP_PV_REAL_VAL0"], 40, 65),
        'color': Colors.purple,
        'lightColor': Colors.purple[100],
      },
      {
        'name': 'EMUL OIL PRESSURE',
        'value': '${apiResponse!["EMUL_OIL_L_PR_VAL0"]?.toStringAsFixed(2)} bar',
        'progress': _progress(apiResponse!["EMUL_OIL_L_PR_VAL0"], 1.0, 3.0),
        'color': Colors.orange,
        'lightColor': Colors.yellow[200],
      },
      {
        'name': 'QUENCH FLOW EXIT',
        'value': '${apiResponse!["QUENCH_CW_FLOW_EXIT_VAL0"]?.toStringAsFixed(2)} L/min',
        'progress': _progress(apiResponse!["QUENCH_CW_FLOW_EXIT_VAL0"], 2.0, 10.0),
        'color': Colors.red,
        'lightColor': Colors.red[100],
      },
      {
        'name': 'CAST WHEEL RPM',
        'value': '${apiResponse!["CAST_WHEEL_RPM_VAL0"]?.toStringAsFixed(2)} rpm',
        'progress': _progress(apiResponse!["CAST_WHEEL_RPM_VAL0"], 1.5, 2.5),
        'color': Colors.green,
        'lightColor': Colors.green[100],
      },
      {
        'name': 'BAR TEMPERATURE',
        'value': '${apiResponse!["BAR_TEMP_VAL0"]?.toStringAsFixed(2)} °C',
        'progress': _progress(apiResponse!["BAR_TEMP_VAL0"], 500, 600),
        'color': Colors.indigo,
        'lightColor': Colors.indigo[100],
      },
      {
        'name': 'QUENCH FLOW ENTRY',
        'value': '${apiResponse!["QUENCH_CW_FLOW_ENTRY_VAL0"]?.toStringAsFixed(2)} L/min',
        'progress': _progress(apiResponse!["QUENCH_CW_FLOW_ENTRY_VAL0"], 70, 300),
        'color': Colors.cyan,
        'lightColor': Colors.cyan[100],
      },
      {
        'name': 'GEAR OIL PRESSURE',
        'value': '${apiResponse!["GEAR_OIL_L_PR_VAL0"]?.toStringAsFixed(2)} bar',
        'progress': _progress(apiResponse!["GEAR_OIL_L_PR_VAL0"], 1.5, 3.0),
        'color': Colors.amber,
        'lightColor': Colors.amber[100],
      },
      {
        'name': 'STANDS OIL PRESSURE',
        'value': '${apiResponse!["STANDS_OIL_L_PR_VAL0"]?.toStringAsFixed(2)} bar',
        'progress': _progress(apiResponse!["STANDS_OIL_L_PR_VAL0"], 1.5, 3.0),
        'color': Colors.deepPurple,
        'lightColor': Colors.deepPurple[100],
      },
      {
        'name': 'TUNDISH TEMP',
        'value': '${apiResponse!["TUNDISH_TEMP_VAL0"]?.toStringAsFixed(2)} °C',
        'progress': _progress(apiResponse!["TUNDISH_TEMP_VAL0"], 650, 800),
        'color': Colors.pink,
        'lightColor': Colors.pink[100],
      },
      {
        'name': 'MOTOR COOL WATER',
        'value': '${apiResponse!["RM_MOTOR_COOL_WATER__VAL0"]?.toStringAsFixed(2)} L/min',
        'progress': _progress(apiResponse!["RM_MOTOR_COOL_WATER__VAL0"], 1.0, 2.0),
        'color': Colors.lime,
        'lightColor': Colors.lime[100],
      },
      {
        'name': 'ROLL MILL AMPS',
        'value': '${apiResponse!["ROLL_MILL_AMPS_VAL0"]?.toStringAsFixed(2)} A',
        'progress': _progress(apiResponse!["ROLL_MILL_AMPS_VAL0"], 300, 500),
        'color': Colors.deepOrange,
        'lightColor': Colors.deepOrange[100],
      },
      {
        'name': 'RM COOL FLOW',
        'value': '${apiResponse!["RM_COOL_WATER_FLOW_VAL0"]?.toStringAsFixed(2)} L/min',
        'progress': _progress(apiResponse!["RM_COOL_WATER_FLOW_VAL0"], 200, 250),
        'color': Colors.brown,
        'lightColor': Colors.brown[100],
      },
      {
        'name': 'EMULSION LEVEL',
        'value': '${apiResponse!["EMULSION_LEVEL_ANALO_VAL0"]?.toStringAsFixed(2)} mm',
        'progress': _progress(apiResponse!["EMULSION_LEVEL_ANALO_VAL0"], 1000, 1300),
        'color': Colors.grey,
        'lightColor': Colors.grey[300],
      },
      {
        'name': 'FURNACE TEMP',
        'value': '${apiResponse!["Furnace_Temperature"]?.toStringAsFixed(2)} °C',
        'progress': _progress(apiResponse!["Furnace_Temperature"], 700, 800),
        'color': Colors.black,
        'lightColor': Colors.grey[400],
      },
    ];


    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Input Parameters',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: "Poppins"),
                ),
                SizedBox(height: screenHeight * 0.05),
                const Row(
                  children: [
                    Expanded(flex: 1, child: Text('Sr.', style: headerStyle)),
                    Expanded(flex: 3, child: Text('Parameter', style: headerStyle)),
                    Expanded(flex: 5, child: Text('Initial Graphical Value', style: headerStyle)),
                    Expanded(flex: 2, child: Text('Initial Numeric Value', style: headerStyle)),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                const Divider(thickness: 1.5, color: Color(0xFFE0E0E0)),
                ListView.builder(itemBuilder: (context,index){
                  final param = parameters[index];
                  return Column(
                    children: [
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: Text('0${index + 1}', style: rowTextStyle)),
                          Expanded(flex: 3, child: Text(param['name'] as String, style: rowTextStyle)),
                          Expanded(
                            flex: 5,
                            child: buildProgressBar(
                              progress: param['progress'] as double,
                              color: param['color'] as Color,
                              lightColor: param['lightColor'] as Color,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: (param['color'] as Color).withOpacity(0.6),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: (param['lightColor'] as Color).withOpacity(0.1),
                                ),
                                child: Text(
                                  param['value'] as String,
                                  style: TextStyle(
                                    color: param['color'] as Color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
                    ],
                  );
                },
                  itemCount: parameters.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                                ),
                SizedBox(height: screenHeight*0.08),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      navKey.currentState?.pushNamed('/dashboard');
                    },
                    icon: const Icon(Icons.check_box, color: Colors.white),
                    label: const Text('Proceed'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      backgroundColor: const Color(0xFF3F00FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: const Color(0xFF3F00FF),
                      elevation: 10,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _progress(dynamic value, double min, double max) {
    if (value == null) return 0.0;
    final val = value as double;
    return ((val - min) / (max - min)).clamp(0.0, 1.0);
  }
  Widget buildProgressBar({
    required double progress,
    required Color color,
    required Color lightColor,
  }) {
    return Stack(
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ],
    );
  }
}

const TextStyle headerStyle = TextStyle(
  fontWeight: FontWeight.w600,
  fontSize: 16,
  fontFamily: "Inter",
  color: Colors.black87,
);

const TextStyle rowTextStyle = TextStyle(
  fontSize: 15,
  color: Colors.black87,
  fontFamily: "Inter",
);
