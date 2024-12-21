import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../../common/widgets/app_shadow.dart';
import '../../../../../../common/widgets/plotdata.dart';
import '../../../../../../common/widgets/text_widgets.dart';
import '../../../common/Api/api_calling.dart';
import '../../../common/utils/app_colors.dart';
import '../../../common/utils/image_res.dart';
import '../../../common/widgets/app_button_widgets.dart';
import '../../../common/widgets/app_text_fields.dart';
import '../../ReversedProcessing/model/data_model_new.dart';

/// Left side Dashboard drawer
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  String selectedMenu = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          flex: 6,
          child: Drawer(
            backgroundColor: Colors.white70,
            shape: const RoundedRectangleBorder(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          ImageRes.letterW,
                          fit: BoxFit.fill,
                          height: 50,
                          width: 50,
                        ),
                        const textcustomnormal(
                          text: "ireSense",
                          fontWeight: FontWeight.bold,
                          fontfamily: "Inter",
                          fontSize: 30,
                          color: Color(0xff2074F2),
                        )
                      ],
                    ),
                  ),
                ),
                dashLine(
                  height: 0.5,
                  color: Colors.grey.shade200,
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ListTile(
                    minLeadingWidth: 0,
                    dense: true,
                    leading: Icon(
                      Icons.dashboard,
                      color: selectedMenu == 'Dashboard'
                          ? Colors.white
                          : const Color(0xffA3AED0),
                      size: screenHeight * 0.03,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    tileColor: selectedMenu == 'Dashboard'
                        ? const Color(0xff4318FF)
                        : Colors.white70,
                    title: Transform.translate(
                      offset: const Offset(-25, 0),
                      child: textcustomnormal(
                        text: 'Dashboard',
                        fontSize: 16,
                        fontfamily: "Inter",
                        fontWeight: FontWeight.w400,
                        color: selectedMenu == 'Dashboard'
                            ? Colors.white
                            : const Color(0xffA3AED0),
                      ),
                    ),
                    onTap: () {
                      // _key.currentState?.closeDrawer();
                      setState(() {
                        selectedMenu = 'Dashboard';
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ListTile(
                    minLeadingWidth: 0,
                    dense: true,
                    leading: Icon(
                      size: screenHeight * 0.03,
                      Icons.download,
                      color: selectedMenu == 'Predict Physical Prop'
                          ? Colors.white
                          : const Color(0xffA3AED0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    tileColor: selectedMenu == 'Predict Physical Prop'
                        ? const Color(0xff562efd)
                        : Colors.white70,
                    title: textcustomnormal(
                      text: 'Predict Prop',
                      fontSize: 16,
                      fontfamily: "Inter",
                      fontWeight: FontWeight.w400,
                      color: selectedMenu == 'Predict Physical Prop'
                          ? Colors.white
                          : const Color(0xffA3AED0),
                    ),
                    onTap: () {
                      // _key.currentState?.closeDrawer();
                      setState(() {
                        selectedMenu = 'Predict Physical Prop';
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded(
        //     flex: 1,
        //     child: Container(
        //       padding: const EdgeInsets.all(8),
        //       alignment: Alignment.topCenter,
        //       height: screenHeight,
        //       color: Colors.white,
        //       child: IconButton(
        //           onPressed: () {
        //             _key.currentState?.openDrawer();
        //           },
        //           icon: const Icon(
        //             Icons.menu,
        //             color: Colors.black,
        //           )),
        //     )),
        Expanded(
          flex: 25,
          child: getContentWidget(selectedMenu),
        )
      ]),
    );
  }

  Widget getContentWidget(String menu) {
    switch (menu) {
      case 'Predict Physical Prop':
        return const Center(child: Text('Predict Physical Prop'));
      case 'Dashboard':
        return const Center(child: MainDashBoard());
      default:
        return const Center(child: MainDashBoard());
    }
  }
}

class _ChartData {
  _ChartData(this.year, this.sales);

  final int year;
  final int sales;
}

///DashBoard right side section
class MainDashBoard extends StatefulWidget {
  const MainDashBoard({super.key});

  @override
  State<MainDashBoard> createState() => _MainDashBoardState();
}

class _MainDashBoardState extends State<MainDashBoard> {
  List<_ChartData> chartData = [];
  List<_ChartData> tempData = [];
  List<_ChartData> presData = [];
  List<_ChartData> speedData = [];
  Timer? timer;

  ChartSeriesController? _chartSeriesController;
  int count = 01;

  // Random instance
  final Random random = Random();

  void _updateDataSource(Timer timer) {
    if (chartData == null) return; // Ensure chartData is not null

    final propertyValue = getPropertyAndItsValue(selectedProperty);
    if (propertyValue.isEmpty) {
      if (kDebugMode) {
        print('property value is null');
      }
      return;
    }; // Ensure propertyValue is not empty
    chartData.add(_ChartData(count, 60+ random.nextInt(5)));
    tempData.add(_ChartData(count, 400+ random.nextInt(70)));
    presData.add(_ChartData(count, 2+ random.nextInt(4)));
    speedData.add(_ChartData(count, 1+ random.nextInt(5)));
    // final parsedValue = int.tryParse(propertyValue.first);
    // if (parsedValue == null) {
    //   if (kDebugMode) {
    //     print('parsed value is null');
    //   }
    //   return;
    // } // Ensure parsedValue is valid
    // if(parsedValue!=null || propertyValue.isNotEmpty){
    //   chartData.add(_ChartData(count, parsedValue));
    // }
    // else{
    //
    // }
    if (chartData.length >= 20) { // Ensure chartData has enough items to remove
      chartData.removeAt(0);
      tempData.removeAt(0);
      presData.removeAt(0);
      speedData.removeAt(0);

      // Remove the first element to maintain size
      _chartSeriesController?.updateDataSource(
        addedDataIndexes: [chartData.length - 1],
        removedDataIndexes: [0],
      );
    }
    count += 1;
  }


  @override
  void initState() {
    getData();
    searchFieldController = TextEditingController();
    timer = Timer.periodic(const Duration(seconds: 1), _updateDataSource);
    super.initState();
  }

  late List<MeasurementData> dashBoardData;

  Future<void> getData() async {
    dashBoardData = await Api.getDashBoardData();
    _simulateRealTimeData(dashBoardData);
    if (kDebugMode) {
      print('the dashboard has some data as -> ${dashBoardData[0].elongation}');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  List<CastingTemp> temperatureData = [
    CastingTemp('Q1', 3.0),
    CastingTemp('Q2', 4.0),
    CastingTemp('Q3', 2.0),
    CastingTemp('Q4', 3.0),
  ];

  String selectedConductivityValue = '0';
  String selectedUTSValue = '0';
  String selectedElongationValue = '0';

  bool isProceeded = false;

  bool isSelected = false;
  final List<Map<String, dynamic>> options = [
    {"icon": Icons.bolt, "name": "Conductivity s/m", "color": Colors.blue},
    {"icon": Icons.construction, "name": "UTS Mpa", "color": Colors.orange},
    {"icon": Icons.expand, "name": "Elongation %", "color": Colors.green},
  ];
  late TextEditingController searchFieldController;
  bool _switchValue = false;
  String selectedProperty = 'Conductivity';
  String selectedPropertyToChange = 'Conductivity';

  String dropdownvalue = 'Elongation';

  // List of items in our dropdown menu
  var properties = [
    'Elongation',
    'Conductivity',
    'UTS',
  ];

  List<String> getPropertyAndItsValue(String selProp) {
    List<String> ans = [];
    switch (selProp) {
      case 'Conductivity':
        return [selectedConductivityValue, 'Conductivity'];
      case 'UTS':
        return [selectedUTSValue, 'UTS'];
      case 'Elongation':
        return [selectedElongationValue, 'Elongation'];
      default:
        return ['Error', 'No case Found'];
    }
  }

  Widget _buildOptionCard(Map<String, dynamic> option, double screenHeight,
      bool isSelected, double screenWidth,
      {required Function()? click}) {
// todo - CORRECT IT
    return GestureDetector(
      onTap: click!,
      child: !isSelected
          ? Container(
              height: screenHeight * 0.07,
              child: Card(
                color: const Color(0xfff3f0ff),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 7.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      // Icon
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: option['color'].withOpacity(0.2),
                        child: Icon(option['icon'], color: option['color']),
                      ),
                      const SizedBox(width: 16),
                      // Property Name
                      Text(
                        option['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Container(
              height: screenHeight * 0.12,
              child: Card(
                color: const Color(0xfff3f0ff),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      // Icon
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: option['color'].withOpacity(0.2),
                        child: Icon(option['icon'], color: option['color']),
                      ),
                      const SizedBox(width: 16),
                      // Property Name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['name'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                            width: screenWidth * 0.15,
                            height: screenHeight * 0.05,
                            child: TextField(
                              obscureText: false,
                              decoration: InputDecoration(
                                hintText: 'Input Value',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Inter",
                                ),
                                // suffixIcon: IconButton(
                                //   icon: const Icon(
                                //     Icons.input,
                                //     color: Colors.grey,
                                //   ), onPressed: () {  },
                                // ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.white70,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget getResultText(double screenHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const textcustomnormal(
          fontSize: 20,
          text: "Suggestions:",
          color: Color(0xff1B2559),
          fontfamily: "Inter",
          fontWeight: FontWeight.w600,
        ),
        SizedBox(
          height: screenHeight * 0.05,
        ),
        const Center(
          child: textcustomnormal(
            fontSize: 18,
            text: "Casting Temperature",
            color: Color(0xff1B2559),
            fontfamily: "Inter",
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        const Center(
          child: CircleAvatar(
            backgroundColor: AppColors.mainThemeColor,
            radius: 80,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textcustomnormal(
                      fontSize: 16,
                      text: "12 °C",
                      color: Color(0xff1B2559),
                      fontfamily: "Inter",
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(Icons.arrow_downward)
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          alignment: Alignment.bottomRight,
          child: appButtons(
              anyWayDoor: () {},
              width: screenHeight * 0.1,
              height: screenHeight * 0.05,
              buttonColor: AppColors.mainThemeColor.withOpacity(0.9),
              buttonText: 'Approve',
              buttonTextSize: 14,
              buttonTextColor: Colors.white),
        )
      ],
    );
  }

  void _simulateRealTimeData(List<MeasurementData> newData) async {
    int index = 0;
    while (index < newData.length) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        selectedConductivityValue = newData[index].conductivity;
        selectedUTSValue = newData[index].uts;
        selectedElongationValue = newData[index].elongation;
      });
      index++;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: const Color(0xfff4f7fe),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02, vertical: screenHeight * 0.05),
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
                    //todo - have a validation here
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
                      propertyValue: double.tryParse(selectedConductivityValue)!
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
                      propertyValue:
                          double.tryParse(selectedUTSValue)!.toStringAsFixed(2),
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

                ///Selected Property and Alerts Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      height: screenHeight * 0.48,
                      width: screenWidth * 0.50,
                      decoration: appBoxDecoration(
                          radius: 20,
                          borderWidth: 0.0,
                          borderColor: Colors.transparent,
                          color: Colors.white),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textcustomnormal(
                            fontSize: 30,
                            color: Colors.black,
                            fontfamily: "Poppins",
                            fontWeight: FontWeight.w500,
                            text:
                                getPropertyAndItsValue(selectedProperty).first,
                          ),
                          Row(
                            children: [
                              text14normal(
                                fontWeight: FontWeight.w400,
                                fontfamily: "Poppins",
                                color: AppColors.dashBoardSecondaryTextColor,
                                text: getPropertyAndItsValue(selectedProperty)
                                    .last,
                              ),
                              const Icon(
                                Icons.arrow_drop_up_sharp,
                                color: Colors.green,
                              ),
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
                          //todo - to make a real time chart here...
                          SizedBox(
                            height: screenHeight * 0.3,
                            width: screenWidth * 0.4,
                            child: SfCartesianChart(
                              series: <LineSeries<_ChartData, int>>[
                                LineSeries<_ChartData, int>(
                                  onRendererCreated:
                                      (ChartSeriesController controller) {
                                    // Assigning the controller to the _chartSeriesController.
                                    _chartSeriesController = controller;
                                  },
                                  // Binding the chartData to the dataSource of the line series.
                                  dataSource: chartData,
                                  xValueMapper: (_ChartData sales, _) =>
                                      sales.year,
                                  yValueMapper: (_ChartData sales, _) =>
                                      sales.sales,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    ///Alert Container
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      height: screenHeight * 0.48,
                      width: screenWidth * 0.25,
                      decoration: appBoxDecoration(
                          radius: 20,
                          borderColor: Colors.transparent,
                          borderWidth: 0.0,
                          color: Colors.white),
                      child: isProceeded
                          ? getResultText(screenHeight)
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const textcustomnormal(
                                      fontSize: 22,
                                      text: "Select Property",
                                      color: Color(0xff1B2559),
                                      fontfamily: "Inter",
                                      fontWeight: FontWeight.w400,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Transform.scale(
                                        scale: 0.7,
                                        child: CupertinoSwitch(
                                          value: _switchValue,
                                          activeColor: Colors.deepPurpleAccent,
                                          onChanged: (value) {
                                            setState(() {
                                              _switchValue = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: screenHeight * 0.01,
                                ),
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _buildOptionCard(
                                          options[0],
                                          screenHeight,
                                          selectedPropertyToChange ==
                                              'Conductivity',
                                          screenWidth, click: () {
                                        setState(() {
                                          selectedPropertyToChange =
                                              "Conductivity";
                                        });
                                      }),
                                      _buildOptionCard(
                                          options[1],
                                          screenHeight,
                                          selectedPropertyToChange ==
                                              'Elongation',
                                          screenWidth, click: () {
                                        setState(() {
                                          selectedPropertyToChange =
                                              "Elongation";
                                        });
                                      }),
                                      _buildOptionCard(
                                          options[2],
                                          screenHeight,
                                          selectedPropertyToChange == 'UTS',
                                          screenWidth, click: () {
                                        setState(() {
                                          selectedPropertyToChange = "UTS";
                                        });
                                      })
                                    ]),
                                SizedBox(
                                  height: screenHeight * 0.04,
                                ),
                                Container(
                                  alignment: Alignment.bottomRight,
                                  child: appButtons(
                                      anyWayDoor: () {
                                        setState(() {
                                          isProceeded = true;
                                        });
                                      },
                                      width: screenWidth * 0.07,
                                      height: screenHeight * 0.05,
                                      buttonColor: AppColors.mainThemeColor
                                          .withOpacity(0.9),
                                      buttonText: 'Proceed',
                                      buttonTextSize: 14,
                                      buttonTextColor: Colors.white),
                                )
                              ],
                            ),
                    )
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.04,
                ),

                /// Plots Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: screenHeight * 0.48,
                      width: screenWidth * 0.23,
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
                          const textcustomnormal(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            fontfamily: "Inter",
                            color: AppColors.dashBoardSecondaryTextColor,
                            text: "Casting Temperature",
                          ),
                          // SizedBox(height: screenHeight*0.005,),
                          const textcustomnormal(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontfamily: "Poppins",
                            color: AppColors.dashBoardPrimaryTextColor,
                            text: "423 K",
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
                            child: SfCartesianChart(
                              series: <LineSeries<_ChartData, int>>[
                                LineSeries<_ChartData, int>(
                                  onRendererCreated:
                                      (ChartSeriesController controller) {
                                    // Assigning the controller to the _chartSeriesController.
                                    _chartSeriesController = controller;
                                  },
                                  // Binding the chartData to the dataSource of the line series.
                                  dataSource: tempData,
                                  xValueMapper: (_ChartData sales, _) =>
                                      sales.year,
                                  yValueMapper: (_ChartData sales, _) =>
                                      sales.sales,
                                ),
                              ],
                            ),
                          )
                          // Container(
                          //   width: double.maxFinite,
                          //   child: Image.asset(
                          //     'assets/images/demo_plot.png',
                          //     fit: BoxFit.fill,
                          //   ),
                          // )
                        ],
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.48,
                      width: screenWidth * 0.23,
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
                          const textcustomnormal(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            fontfamily: "Inter",
                            color: AppColors.dashBoardSecondaryTextColor,
                            text: "Casting Pressure",
                          ),
                          // SizedBox(height: screenHeight*0.005,),
                          const textcustomnormal(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontfamily: "Poppins",
                            color: AppColors.dashBoardPrimaryTextColor,
                            text: "12 ATM",
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: appBoxDecoration(
                                radius: 5,
                                color: Colors.redAccent.withOpacity(0.2),
                                borderColor: Colors.transparent,
                                borderWidth: 0.0),
                            child: Center(
                              child: textcustomnormal(
                                fontSize: 12,
                                text: '-4 ATM',
                                fontfamily: "Inter",
                                fontWeight: FontWeight.w500,
                                color: Colors.redAccent.shade400,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                          SizedBox(
                            height: screenHeight * 0.3,
                            width: screenWidth * 0.3,
                            child: SfCartesianChart(
                              series: <LineSeries<_ChartData, int>>[
                                LineSeries<_ChartData, int>(
                                  onRendererCreated:
                                      (ChartSeriesController controller) {
                                    // Assigning the controller to the _chartSeriesController.
                                    _chartSeriesController = controller;
                                  },
                                  // Binding the chartData to the dataSource of the line series.
                                  dataSource: presData,
                                  xValueMapper: (_ChartData sales, _) =>
                                      sales.year,
                                  yValueMapper: (_ChartData sales, _) =>
                                      sales.sales,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.48,
                      width: screenWidth * 0.23,
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
                          const textcustomnormal(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            fontfamily: "Inter",
                            color: AppColors.dashBoardSecondaryTextColor,
                            text: "Rolling Speed",
                          ),
                          // SizedBox(height: screenHeight*0.005,),
                          const textcustomnormal(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            fontfamily: "Poppins",
                            color: AppColors.dashBoardPrimaryTextColor,
                            text: "12 m/s",
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
                                text: '+3 m/s',
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
                            child: SfCartesianChart(
                              series: <LineSeries<_ChartData, int>>[
                                LineSeries<_ChartData, int>(
                                  onRendererCreated:
                                      (ChartSeriesController controller) {
                                    // Assigning the controller to the _chartSeriesController.
                                    _chartSeriesController = controller;
                                  },
                                  // Binding the chartData to the dataSource of the line series.
                                  dataSource: chartData,
                                  xValueMapper: (_ChartData sales, _) =>
                                      sales.year,
                                  yValueMapper: (_ChartData sales, _) =>
                                      sales.sales,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
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
                      text20normal(
                        text: propertyName,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                        fontfamily: "Poppins",
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      textcustomnormal(
                        fontSize: 22,
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
                        text20normal(
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
                text20normal(
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
