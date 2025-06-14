import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../../../common/widgets/app_shadow.dart';
import '../../../../../../common/widgets/text_widgets.dart';
import '../../../common/utils/app_colors.dart';
import '../../../common/widgets/app_text_fields.dart';
import 'dart:html' as html;

class _ChartData {
  _ChartData(this.year, this.sales);

  final int year;
  final double sales;
}

class MainDashBoard extends StatefulWidget {
  const MainDashBoard({super.key});

  @override
  State<MainDashBoard> createState() => _MainDashBoardState();
}

class _MainDashBoardState extends State<MainDashBoard> {
  String selectedConductivityValue = '0';
  String selectedUTSValue = '0';
  String selectedElongationValue = '0';
  String selectedEMUL_OIL_L_TEMP_PV_VAL0 = '0';
  String selectedSTAND_OIL_L_TEMP_PV_REAL_VAL0 = '0';
  String selectedGEAR_OIL_L_TEMP_PV_REAL_VAL0 = '0';
  String selectedEMUL_OIL_L_PR_VAL0 = '0';
  String selectedQUENCH_CW_FLOW_EXIT_VAL0 = '0';
  String selectedCAST_WHEEL_RPM_VAL0 = '0';
  String selectedBAR_TEMP_VAL0 = '0';
  String selectedQUENCH_CW_FLOW_ENTRY_VAL0 = '0';
  String selectedGEAR_OIL_L_PR_VAL0 = '0';
  String selectedSTANDS_OIL_L_PR_VAL0 = '0';
  String selectedTUNDISH_TEMP_VAL0 = '0';
  String selectedRM_MOTOR_COOL_WATER__VAL0 = '0';
  String selectedROLL_MILL_AMPS_VAL0 = '0';
  String selectedRM_COOL_WATER_FLOW_VAL0 = '0';
  String selectedEMULSION_LEVEL_ANALO_VAL0 = '0';
  String selectedPercentSI = '0';
  String selectedPercentFE = '0';
  String selectedPercentTI = '0';
  String selectedPercentV = '0';
  String selectedPercentAL = '0';
  String selectedFurnaceTemperature = '0';

  final List<String> chartKeys = [
    'Conductivity', // chart 0
    'UTS', // chart 1
    'Elongation', // chart 2
    'Furnace_Temperature',
    'GEAR_OIL_L_TEMP_PV_REAL_VAL0',
    'EMUL_OIL_L_PR_VAL0',
    'QUENCH_CW_FLOW_EXIT_VAL0',
    'CAST_WHEEL_RPM_VAL0',
    'BAR_TEMP_VAL0',
    'QUENCH_CW_FLOW_ENTRY_VAL0',
    'GEAR_OIL_L_PR_VAL0',
    'STANDS_OIL_L_PR_VAL0',
    'TUNDISH_TEMP_VAL0',
    'RM_MOTOR_COOL_WATER__VAL0',
    'ROLL_MILL_AMPS_VAL0',
    'RM_COOL_WATER_FLOW_VAL0',
    'EMULSION_LEVEL_ANALO_VAL0',
    'EMUL_OIL_L_TEMP_PV_VAL0',
    'STAND_OIL_L_TEMP_PV_REAL_VAL0',
    '%SI', '%FE', '%TI', '%V', '%AL',
  ];

  List<Map<String, dynamic>> _apiData = [];
  int _dataIndex = 0;
  late Timer _timer;
  late List<List<_ChartData>> _allChartData;
  late List<ChartSeriesController?> _controllers;
  late int _numCharts;

  @override
  void initState() {
    super.initState();
    searchFieldController = TextEditingController();
    _numCharts = chartKeys.length;
    _controllers = List<ChartSeriesController?>.filled(chartKeys.length, null);
    _allChartData = List.generate(chartKeys.length, (_) => <_ChartData>[]);
    _fetchDataOnce();
  }

  Future<void> _fetchDataOnce() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/api/predict/'));
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);

        _apiData = rawData.cast<Map<String, dynamic>>();
        debugPrint('raw api data is -> ${_apiData[0]}');
        // Start updating charts from stored data
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _timer = Timer.periodic(
              const Duration(seconds: 1), (_) => _updateChartsFromStoredData());
        });
      } else {
        if (kDebugMode) {
          print("Error: ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    }
  }

  double verifyValues(double value, double percentage) {
    final random = Random();
    double variation = value * percentage;
    return value + (random.nextDouble() * 2 - 1) * variation;
  }

  void _updateChartsFromStoredData() {
    if (_apiData.isEmpty || _dataIndex >= _apiData.length) return;

    final entry = _apiData[_dataIndex];

    for (int i = 0; i < chartKeys.length; i++) {
      try {
        if (i >= _controllers.length || i >= _allChartData.length) {
          debugPrint(
              'Skipping update for chart index $i: Controller or data not initialized');
          continue;
        }

        final controller = _controllers[i];
        if (controller == null) continue;

        double value = (entry[chartKeys[i]] ?? 0.0).toDouble();
        if (chartKeys[i] == 'UTS' ||
            chartKeys[i] == 'Conductivity' ||
            chartKeys[i] == 'Elongation') {
          value = verifyValues(value, 0.01); //
        }

        final chart = _allChartData[i];

        if (chart.length >= 10) chart.removeAt(0);
        chart.add(_ChartData(_dataIndex, value));

        controller.updateDataSource(
          addedDataIndexes: [chart.length - 1],
          removedDataIndexes: chart.length > 10 ? [0] : [],
        );
        // Update current values for display
        setCurrentParametersAndPropertiesValues(entry);
      } catch (e) {
        debugPrint(
            'Chart update failed at index $i (key: ${chartKeys[i]}): $e');
      }
    }

    _dataIndex++;
    setState(() {});
  }

  void setCurrentParametersAndPropertiesValues(Map<String, dynamic> entry) {
    selectedConductivityValue =
        ((verifyValues(entry['Conductivity'] ?? 1.0, 0.01) as num)
            .toStringAsFixed(4));
    selectedUTSValue =
        ((verifyValues(entry['UTS'] ?? 1.0, 0.01) as num).toStringAsFixed(4));
    selectedElongationValue =
        ((verifyValues(entry['Elongation'] ?? 1.0, 0.01) as num)
            .toStringAsFixed(4));
    selectedEMUL_OIL_L_TEMP_PV_VAL0 =
        ((entry['EMUL_OIL_L_TEMP_PV_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedSTAND_OIL_L_TEMP_PV_REAL_VAL0 =
        ((entry['STAND_OIL_L_TEMP_PV_REAL_VAL0'] ?? 0.0) as num)
            .toStringAsFixed(2);
    selectedGEAR_OIL_L_TEMP_PV_REAL_VAL0 =
        ((entry['GEAR_OIL_L_TEMP_PV_REAL_VAL0'] ?? 0.0) as num)
            .toStringAsFixed(2);
    selectedEMUL_OIL_L_PR_VAL0 =
        ((entry['EMUL_OIL_L_PR_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedQUENCH_CW_FLOW_EXIT_VAL0 =
        ((entry['QUENCH_CW_FLOW_EXIT_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedCAST_WHEEL_RPM_VAL0 =
        ((entry['CAST_WHEEL_RPM_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedBAR_TEMP_VAL0 =
        ((entry['BAR_TEMP_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedQUENCH_CW_FLOW_ENTRY_VAL0 =
        ((entry['QUENCH_CW_FLOW_ENTRY_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedGEAR_OIL_L_PR_VAL0 =
        ((entry['GEAR_OIL_L_PR_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedSTANDS_OIL_L_PR_VAL0 =
        ((entry['STANDS_OIL_L_PR_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedTUNDISH_TEMP_VAL0 =
        ((entry['TUNDISH_TEMP_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedRM_MOTOR_COOL_WATER__VAL0 =
        ((entry['RM_MOTOR_COOL_WATER__VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedROLL_MILL_AMPS_VAL0 =
        ((entry['ROLL_MILL_AMPS_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedRM_COOL_WATER_FLOW_VAL0 =
        ((entry['RM_COOL_WATER_FLOW_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedEMULSION_LEVEL_ANALO_VAL0 =
        ((entry['EMULSION_LEVEL_ANALO_VAL0'] ?? 0.0) as num).toStringAsFixed(2);
    selectedPercentSI = ((entry['%SI'] ?? 0.0) as num).toStringAsFixed(2);
    selectedPercentFE = ((entry['%FE'] ?? 0.0) as num).toStringAsFixed(2);
    selectedPercentTI = ((entry['%TI'] ?? 0.0) as num).toStringAsFixed(4);
    selectedPercentV = ((entry['%V'] ?? 0.0) as num).toStringAsFixed(4);
    selectedPercentAL = ((entry['%AL'] ?? 0.0) as num).toStringAsFixed(2);
    selectedFurnaceTemperature =
        ((entry['Furnace_Temperature'] ?? 0.0) as num).toStringAsFixed(2);
  }

  Widget plotsRowData({
    required double screenHeight,
    required double screenWidth,
    required int plotIndex,
    required String parameterName,
    required String parameterValue,
  }) {
    return Container(
      height: screenHeight * 0.48,
      width: screenWidth * 0.23,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      decoration: appBoxDecoration(
          radius: 20,
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: screenHeight * 0.04,
          ),
          textcustomnormal(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontfamily: "Inter",
            color: AppColors.dashBoardSecondaryTextColor,
            text: parameterName,
          ),
          // SizedBox(height: screenHeight*0.005,),
          textcustomnormal(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontfamily: "Poppins",
            color: AppColors.dashBoardPrimaryTextColor,
            text: parameterValue,
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: appBoxDecoration(
                radius: 5,
                color: Colors.greenAccent.withOpacity(0.2),
                borderColor: Colors.transparent,
                borderWidth: 0.0),
            child: Center(
              child: textcustomnormal(
                fontSize: 12,
                text: '+45K',
                fontfamily: "Inter",
                fontWeight: FontWeight.w500,
                color: Colors.greenAccent.shade400,
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          SizedBox(
              height: screenHeight * 0.3,
              width: screenWidth * 0.3,
              child: _buildChart(plotIndex))
        ],
      ),
    );
  }

  Widget plotsRowDataForChemicalComp({
    required double screenHeight,
    required double screenWidth,
    required int plotIndex,
    required String parameterName,
    required String parameterValue,
  }) {
    return Container(
      height: screenHeight * 0.48,
      width: screenWidth * 0.23,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
      decoration: appBoxDecoration(
          radius: 20,
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: screenHeight * 0.04,
          ),
          textcustomnormal(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontfamily: "Inter",
            color: AppColors.dashBoardSecondaryTextColor,
            text: parameterName,
          ),
          // SizedBox(height: screenHeight*0.005,),
          textcustomnormal(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontfamily: "Poppins",
            color: AppColors.dashBoardPrimaryTextColor,
            text: parameterValue,
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          Center(
            child: Container(
              width: screenWidth * 0.18,
              padding: const EdgeInsets.all(5),
              decoration: appBoxDecoration(
                  radius: 5,
                  color: Colors.greenAccent.withOpacity(0.2),
                  borderColor: Colors.transparent,
                  borderWidth: 0.0),
              child: Center(
                child: textcustomnormal(
                  fontSize: 12,
                  text: '+45K',
                  fontfamily: "Inter",
                  fontWeight: FontWeight.w500,
                  color: Colors.greenAccent.shade400,
                ),
              ),
            ),
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          SizedBox(
              height: screenHeight * 0.3,
              width: screenWidth * 0.3,
              child: _buildChart(plotIndex))
        ],
      ),
    );
  }

  Widget _buildChart(int index) {
    return SfCartesianChart(
      primaryXAxis: const NumericAxis(),
      primaryYAxis: const NumericAxis(),
      series: <LineSeries<_ChartData, int>>[
        LineSeries<_ChartData, int>(
          onRendererCreated: (ChartSeriesController controller) {
            _controllers[index] = controller;
          },
          dataSource: _allChartData[index],
          xValueMapper: (_ChartData data, _) => data.year,
          yValueMapper: (_ChartData data, _) => data.sales,
        ),
      ],
    );
  }

  Widget _buildPropertyChart(int index) {
    return SfCartesianChart(
      primaryXAxis: const NumericAxis(),
      primaryYAxis: const NumericAxis(),
      series: <LineSeries<_ChartData, int>>[
        LineSeries<_ChartData, int>(
          onRendererCreated: (ChartSeriesController controller) {
            _controllers[index] = controller;
          },
          dataSource: _allChartData[index],
          xValueMapper: (_ChartData data, _) => data.year,
          yValueMapper: (_ChartData data, _) => data.sales,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool isProceeded = false;
  final List<Map<String, dynamic>> options = [
    {"icon": Icons.bolt, "name": "Conductivity IACS", "color": Colors.blue},
    {"icon": Icons.construction, "name": "UTS Mpa", "color": Colors.orange},
    {"icon": Icons.expand, "name": "Elongation %", "color": Colors.green},
  ];
  late TextEditingController searchFieldController;
  String selectedProperty = 'Conductivity';
  String selectedPropertyToChange = 'Conductivity';

  List<String> getPropertyAndItsValue(String selProp) {
    switch (selProp) {
      case 'Conductivity':
        return ['$selectedConductivityValue IACS', 'Conductivity', '0'];
      case 'UTS':
        return ['$selectedUTSValue MPa', 'UTS', '1'];
      case 'Elongation':
        return ['$selectedElongationValue %', 'Elongation', '2'];
      default:
        return ['Error', 'No case Found', '-1'];
    }
  }

  List<String> getParameterAndItsValue(int index) {
    switch (index) {
      case 0:
        return ['Furnace Temperature', '$selectedFurnaceTemperature °C'];
      case 1:
        return ['Gear Oil Temp', '$selectedGEAR_OIL_L_TEMP_PV_REAL_VAL0 °C'];
      case 2:
        return ['Emulsion Oil Pressure', '$selectedEMUL_OIL_L_PR_VAL0 Bar'];
      case 3:
        return ['Quench Exit Flow', '$selectedQUENCH_CW_FLOW_EXIT_VAL0 m³/h'];
      case 4:
        return ['Casting Wheel RPM', '$selectedCAST_WHEEL_RPM_VAL0 RPM'];
      case 5:
        return ['Bar Temperature', '$selectedBAR_TEMP_VAL0 °C'];
      case 6:
        return ['Quench Entry Flow', '$selectedQUENCH_CW_FLOW_ENTRY_VAL0 m³/h'];
      case 7:
        return ['Gear Oil Pressure', '$selectedGEAR_OIL_L_PR_VAL0 Bar'];
      case 8:
        return ['Stand Oil Pressure', '$selectedSTANDS_OIL_L_PR_VAL0 Bar'];
      case 9:
        return ['Tundish Temp', '$selectedTUNDISH_TEMP_VAL0 °C'];
      case 10:
        return [
          'Motor Cooling Water',
          '$selectedRM_MOTOR_COOL_WATER__VAL0 L/min'
        ];
      case 11:
        return ['Roll Mill Amps', '$selectedROLL_MILL_AMPS_VAL0 A'];
      case 12:
        return ['Cooling Water Flow', '$selectedRM_COOL_WATER_FLOW_VAL0 m³/h'];
      case 13:
        return ['Emulsion Level', '$selectedEMULSION_LEVEL_ANALO_VAL0 mm'];
      case 14:
        return ['Emulsion Oil Temp', '$selectedEMUL_OIL_L_TEMP_PV_VAL0 °C'];
      case 15:
        return ['Stand Oil Temp', '$selectedSTAND_OIL_L_TEMP_PV_REAL_VAL0 °C'];
      case 16:
        return ['% Silicon', '$selectedPercentSI %'];
      case 17:
        return ['% Iron', '$selectedPercentFE %'];
      case 18:
        return ['% Titanium', '$selectedPercentTI %'];
      case 19:
        return ['% Vanadium', '$selectedPercentV %'];
      case 20:
        return ['% Aluminium', '$selectedPercentAL %'];
      default:
        return ['Unknown', 'N/A'];
    }
  }

  // Widget _buildOptionCard(Map<String, dynamic> option, double screenHeight,
  //     bool isSelected, double screenWidth,
  //     {required Function()? click}) {
  //   return GestureDetector(
  //     onTap: click!,
  //     child: !isSelected
  //         ? SizedBox(
  //             height: screenHeight * 0.07,
  //             width: screenWidth * 0.05,
  //             child: Card(
  //               color: Colors.white70,
  //               elevation: 4,
  //               margin: const EdgeInsets.symmetric(vertical: 7.0),
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16)),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(5.0),
  //                 child: Row(
  //                   children: [
  //                     // Icon
  //                     CircleAvatar(
  //                       radius: 24,
  //                       backgroundColor: option['color'].withOpacity(0.2),
  //                       child: Icon(option['icon'], color: option['color']),
  //                     ),
  //                     SizedBox(width: screenWidth * 0.005),
  //                     // Property Name
  //                     Text(
  //                       option['name'],
  //                       style: const TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.w600,
  //                         color: Colors.black87,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           )
  //         : SizedBox(
  //             height: screenHeight * 0.12,
  //             width: screenWidth * 0.05,
  //             child: Card(
  //               color: const Color(0xfff3f0ff),
  //               elevation: 4,
  //               margin: const EdgeInsets.symmetric(vertical: 5.0),
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(16)),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(5.0),
  //                 child: Row(
  //                   children: [
  //                     // Icon
  //                     CircleAvatar(
  //                       radius: 24,
  //                       backgroundColor: option['color'].withOpacity(0.2),
  //                       child: Icon(option['icon'], color: option['color']),
  //                     ),
  //                     const SizedBox(width: 16),
  //                     // Property Name
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text(
  //                           option['name'],
  //                           style: const TextStyle(
  //                             fontSize: 14,
  //                             fontWeight: FontWeight.w600,
  //                             color: Colors.black87,
  //                           ),
  //                         ),
  //                         const SizedBox(
  //                           height: 5,
  //                         ),
  //                         SizedBox(
  //                           width: screenWidth * 0.13,
  //                           height: screenHeight * 0.05,
  //                           child: TextField(
  //                             obscureText: false,
  //                             decoration: InputDecoration(
  //                               hintText: 'Input Value',
  //                               hintStyle: TextStyle(
  //                                 fontSize: 14,
  //                                 color: Colors.grey.shade500,
  //                                 fontWeight: FontWeight.w400,
  //                                 fontFamily: "Inter",
  //                               ),
  //                               enabledBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(10),
  //                                 borderSide: const BorderSide(
  //                                   color: Colors.white70,
  //                                 ),
  //                               ),
  //                               focusedBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(10),
  //                                 borderSide: const BorderSide(
  //                                   color: Colors.white70,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //   );
  // }

  // Widget getResultText(double screenHeight) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const textcustomnormal(
  //         fontSize: 20,
  //         text: "Suggestions:",
  //         color: Color(0xff1B2559),
  //         fontfamily: "Inter",
  //         fontWeight: FontWeight.w600,
  //       ),
  //       SizedBox(
  //         height: screenHeight * 0.05,
  //       ),
  //       const Center(
  //         child: textcustomnormal(
  //           fontSize: 18,
  //           text: "Casting Temperature",
  //           color: Color(0xff1B2559),
  //           fontfamily: "Inter",
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       SizedBox(
  //         height: screenHeight * 0.02,
  //       ),
  //       const Center(
  //         child: CircleAvatar(
  //           backgroundColor: AppColors.mainThemeColor,
  //           radius: 80,
  //           child: CircleAvatar(
  //             radius: 60,
  //             backgroundColor: Colors.white,
  //             child: Padding(
  //               padding: EdgeInsets.symmetric(horizontal: 10),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   textcustomnormal(
  //                     fontSize: 16,
  //                     text: "12 °C",
  //                     color: Color(0xff1B2559),
  //                     fontfamily: "Inter",
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                   SizedBox(
  //                     width: 5,
  //                   ),
  //                   Icon(Icons.arrow_downward)
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //       Container(
  //         alignment: Alignment.bottomRight,
  //         child: appButtons(
  //             anyWayDoor: () {
  //               setState(() {
  //                 isProceeded = !isProceeded;
  //               });
  //             },
  //             width: screenHeight * 0.1,
  //             height: screenHeight * 0.05,
  //             buttonColor: AppColors.mainThemeColor.withOpacity(0.9),
  //             buttonText: 'Approve',
  //             buttonTextSize: 14,
  //             buttonTextColor: Colors.white),
  //       )
  //     ],
  //   );
  // }

  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          backgroundColor: const Color(0xfff4f7fe),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: screenHeight * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const text14normal(
                    fontfamily: "Inter",
                    fontWeight: FontWeight.w400,
                    text: "Hi User,",
                    color: AppColors.dashBoardSecondaryTextColor,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const text24normal(
                        fontfamily: "Inter",
                        fontWeight: FontWeight.w600,
                        text: "Welcome to Wiresense!",
                        color: AppColors.dashBoardPrimaryTextColor,
                      ),
                      //todo - to implement search here
                      textLoginBoxWithDimensions(
                        width: screenWidth * 0.25,
                        hintText: "Search",
                        icon: Icons.search_rounded,
                        controller: searchFieldController,
                        keyboardType: TextInputType.number,
                        func: (value) {},
                      )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      propertyContainer(
                        propertyName: 'CONDUCTIVITY',
                        propertyValue:
                            double.tryParse(selectedConductivityValue)!
                                .toStringAsFixed(2),
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        icon: Icons.trending_up,
                        isSelected: selectedProperty == 'Conductivity',
                        click: () {
                          setState(() {
                            selectedProperty = 'Conductivity';
                          });
                        },
                      ),
                      SizedBox(
                        width: screenWidth * 0.015,
                      ),
                      propertyContainer(
                        propertyName: 'UTS',
                        propertyValue: double.tryParse(selectedUTSValue)!
                            .toStringAsFixed(2),
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        icon: Icons.trending_down,
                        isSelected: selectedProperty == 'UTS',
                        click: () {
                          setState(() {
                            selectedProperty = 'UTS';
                          });
                        },
                      ),
                      SizedBox(
                        width: screenWidth * 0.015,
                      ),
                      propertyContainer(
                        propertyName: 'ELONGATION',
                        propertyValue: double.tryParse(selectedElongationValue)!
                            .toStringAsFixed(2),
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                        icon: Icons.trending_up,
                        isSelected: selectedProperty == 'Elongation',
                        click: () {
                          setState(() {
                            selectedProperty = 'Elongation';
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.03,
                  ),

                  //todo - to remove this alerts Row and keep chemical parameters separately here.
                  ///Selected Property and Alerts Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        height: screenHeight * 0.50,
                        width: screenWidth * 0.60,
                        decoration: appBoxDecoration(
                            radius: 20,
                            borderWidth: 0.0,
                            borderColor: Colors.transparent,
                            color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            textcustomnormal(
                              fontSize: screenWidth * 0.025,
                              color: Colors.black,
                              fontfamily: "Poppins",
                              fontWeight: FontWeight.w500,
                              text: getPropertyAndItsValue(selectedProperty)
                                  .first,
                            ),
                            Row(
                              children: [
                                text14normal(
                                  fontWeight: FontWeight.w400,
                                  fontfamily: "Poppins",
                                  color: AppColors.dashBoardSecondaryTextColor,
                                  text: getPropertyAndItsValue(
                                      selectedProperty)[1],
                                ),
                                const Icon(
                                  Icons.arrow_drop_up_sharp,
                                  color: Colors.green,
                                ),
                                //todo - to actually last 20 mins average here
                                const textcustomnormal(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  fontfamily: "Poppins",
                                  color: Colors.green,
                                  text: '+2.45 %',
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                                height: screenHeight * 0.3,
                                width: screenWidth * 0.55,
                                child: Stack(
                                  children: List.generate(3, (index) {
                                    return Visibility(
                                      visible: int.parse(getPropertyAndItsValue(
                                                  selectedProperty)
                                              .last) ==
                                          index,
                                      child: _buildPropertyChart(index),
                                    );
                                  }),
                                ))
                          ],
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          height: screenHeight * 0.50,
                          width: screenWidth * 0.27,
                          decoration: appBoxDecoration(
                              radius: 20,
                              borderColor: Colors.transparent,
                              borderWidth: 0.0,
                              color: Colors.white),
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              final parameterIndex = index + 16;
                              return plotsRowDataForChemicalComp(
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth,
                                  plotIndex: 19 + index,
                                  parameterName:
                                      getParameterAndItsValue(parameterIndex)
                                          .first,
                                  parameterValue:
                                      getParameterAndItsValue(parameterIndex)
                                          .last);
                            },
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                          )),

                      ///Alert Container
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 20, vertical: 5),
                      //   height: screenHeight * 0.45,
                      //   width: screenWidth * 0.25,
                      //   decoration: appBoxDecoration(
                      //       radius: 20,
                      //       borderColor: Colors.transparent,
                      //       borderWidth: 0.0,
                      //       color: Colors.white),
                      //   child: isProceeded
                      //       ? getResultText(screenHeight)
                      //       : Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             textcustomnormal(
                      //               fontSize: screenWidth * 0.015,
                      //               text: "Enter Desired Property Value",
                      //               color: const Color(0xff1B2559),
                      //               fontfamily: "Inter",
                      //               fontWeight: FontWeight.w400,
                      //             ),
                      //             SizedBox(
                      //               height: screenHeight * 0.01,
                      //             ),
                      //             Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.stretch,
                      //                 mainAxisAlignment: MainAxisAlignment.start,
                      //                 children: [
                      //                   _buildOptionCard(
                      //                       options[0],
                      //                       screenHeight,
                      //                       selectedPropertyToChange ==
                      //                           'Conductivity',
                      //                       screenWidth, click: () {
                      //                     setState(() {
                      //                       selectedPropertyToChange =
                      //                           "Conductivity";
                      //                     });
                      //                   }),
                      //                   _buildOptionCard(
                      //                       options[1],
                      //                       screenHeight,
                      //                       selectedPropertyToChange ==
                      //                           'Elongation',
                      //                       screenWidth, click: () {
                      //                     setState(() {
                      //                       selectedPropertyToChange =
                      //                           "Elongation";
                      //                     });
                      //                   }),
                      //                   _buildOptionCard(
                      //                       options[2],
                      //                       screenHeight,
                      //                       selectedPropertyToChange == 'UTS',
                      //                       screenWidth, click: () {
                      //                     setState(() {
                      //                       selectedPropertyToChange = "UTS";
                      //                     });
                      //                   })
                      //                 ]),
                      //             SizedBox(
                      //               height: screenHeight * 0.04,
                      //             ),
                      //             Container(
                      //               alignment: Alignment.bottomRight,
                      //               child: appButtons(
                      //                   anyWayDoor: () {
                      //                     setState(() {
                      //                       isProceeded = !isProceeded;
                      //                     });
                      //                   },
                      //                   width: screenWidth * 0.07,
                      //                   height: screenHeight * 0.05,
                      //                   buttonColor: AppColors.mainThemeColor
                      //                       .withOpacity(0.9),
                      //                   buttonText: 'Proceed',
                      //                   buttonTextSize: 14,
                      //                   buttonTextColor: Colors.white),
                      //             )
                      //           ],
                      //         ),
                      // )
                    ],
                  ),
                  SizedBox(
                    height: screenHeight * 0.04,
                  ),

                  /// Plots Row
                  SizedBox(
                    height: screenHeight * 0.50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _numCharts - 8,
                      itemBuilder: (context, index) {
                        int plotsIndex = index + 3;
                        return plotsRowData(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            plotIndex: plotsIndex,
                            parameterName: getParameterAndItsValue(index).first,
                            parameterValue:
                                getParameterAndItsValue(index).last);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Widget propertyContainer(
      {required String propertyName,
      required String propertyValue,
      required double screenHeight,
      required double screenWidth,
      required IconData icon,
      required bool isSelected,
      required Function()? click}) {
    return isSelected
        ? Container(
            width: screenWidth * 0.18,
            height: screenHeight * 0.15,
            padding: const EdgeInsets.all(20),
            decoration: appBoxDecorationWithGradient(
                color: AppColors.mainThemeColor,
                borderColor: Colors.transparent,
                borderWidth: 0.0,
                radius: 20),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textcustomnormal(
                        fontSize: screenWidth * 0.015,
                        text: propertyName,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontfamily: "Poppins",
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      textcustomnormal(
                        fontSize: screenWidth * 0.013,
                        text: propertyValue,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontfamily: "Poppins",
                      )
                    ],
                  ),
                  Icon(
                    icon,
                    size: screenHeight * 0.05,
                  )
                ],
              ),
            ),
          )
        : GestureDetector(
            onTap: click!,
            child: Container(
              width: screenWidth * 0.18,
              height: screenHeight * 0.15,
              padding: const EdgeInsets.all(20),
              decoration: appBoxDecoration(
                  color: Colors.white,
                  borderColor: Colors.transparent,
                  borderWidth: 0.0,
                  radius: 20),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textcustomnormal(
                          fontSize: screenWidth * 0.015,
                          text: propertyName,
                          color: AppColors.dashBoardSecondaryTextColor,
                          fontWeight: FontWeight.w400,
                          fontfamily: "Poppins",
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        textcustomnormal(
                          fontSize: screenWidth * 0.013,
                          text: propertyValue,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontfamily: "Poppins",
                        )
                      ],
                    ),
                    Icon(
                      icon,
                      size: screenHeight * 0.05,
                    )
                  ],
                ),
              ),
            ),
          );
  }

  Widget notSelectedPropertyContainer(
      {required String propertyName,
      required String propertyValue,
      required double screenHeight,
      required double screenWidth,
      required IconData icon}) {
    return Container(
      width: screenWidth * 0.18,
      height: screenHeight * 0.15,
      padding: const EdgeInsets.all(20),
      decoration: appBoxDecoration(
          color: Colors.white,
          borderColor: Colors.transparent,
          borderWidth: 0.0,
          radius: 20),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textcustomnormal(
                  fontSize: screenWidth * 0.015,
                  text: propertyName,
                  color: AppColors.dashBoardSecondaryTextColor,
                  fontWeight: FontWeight.w400,
                  fontfamily: "Poppins",
                ),
                const SizedBox(
                  height: 5,
                ),
                textcustomnormal(
                  fontSize: 22,
                  text: propertyValue,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontfamily: "Poppins",
                )
              ],
            ),
            Icon(
              icon,
              size: screenHeight * 0.05,
            )
          ],
        ),
      ),
    );
  }
}
