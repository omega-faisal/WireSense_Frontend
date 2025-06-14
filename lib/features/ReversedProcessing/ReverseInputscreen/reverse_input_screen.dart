import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wiresense_frontend/main.dart';
import '../../../common/utils/image_res.dart';

class ControlCenterPage extends ConsumerStatefulWidget {
  const ControlCenterPage({super.key});

  @override
  ConsumerState<ControlCenterPage> createState() => _ControlCenterPageState();
}

class _ControlCenterPageState extends ConsumerState<ControlCenterPage> {
  final TextEditingController utsController = TextEditingController();

  final TextEditingController elongationController = TextEditingController();

  final TextEditingController conductivityController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: formKey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      ImageRes.letterW,
                      height: screenHeight * 0.1,
                    ),
                    const Text(
                      "ireSense",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2074f2),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                const Text(
                  'Aluminium Wire Rod Physical Properties',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Set your desired parameters to begin the process',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildInputField(
                  screenWidth: screenWidth,
                  controller: utsController,
                  label: 'UTS (MPa)',
                  icon: Icons.handyman,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    RegExp regex = RegExp(r'^(8\.(2[7-9]|[3-9][0-9])|9\.\d{1,2}|1[0-2](\.\d{1,2})?|12\.(0[0-9]|1[0-9]|2[0-9]|3[0-9]|4[0-1]))$');
                    if (!regex.hasMatch(value!)) {
                      return "Please enter UTS in the range of [8-12]";
                    }
                    return null;
                  },
                  validateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  screenWidth: screenWidth,
                  controller: elongationController,
                  label: 'Elongation (%)',
                  icon: Icons.straighten,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    RegExp regex = RegExp(r'^(10\.(7[2-9]|[89]\d)|1[1-5](\.\d{1,2})?|16\.(0[0-8]))$');
                    if (!regex.hasMatch(value!)) {
                      return "Please enter Elongation in the range of [10-16]";
                    }
                    return null;
                  },
                  validateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  screenWidth: screenWidth,
                  controller: conductivityController,
                  label: 'Conductivity (S/M)',
                  icon: Icons.bolt,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    RegExp regex = RegExp(r'^(49\.(0[2-9]|[1-9][0-9])|5\d(\.\d{1,2})?|6\d(\.\d{1,2})?|7[0-2](\.\d{1,2})?|73\.(0[0-9]|1[0-9]|2[0-9]|3[0-9]|4[0-9]|5[0-2]))$');
                    if (!regex.hasMatch(value!)) {
                      return "Please enter Conductivity in the range of [50-70]";
                    }
                    return null;
                  },
                  validateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      navKey.currentState
                          ?.pushNamed('/reverse_output', arguments: {
                        'UTS': utsController.text,
                        'Elongation': elongationController.text,
                        'Conductivity': conductivityController.text
                      });
                    }
                    else {
                      showDialog(
                          context: context,
                          builder: (context) => const Center(
                              child: Text('Please enter valid values')));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Get Initial Parameters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

  Widget _buildInputField(
      {required TextEditingController controller,
      required String label,
      TextInputType? keyboardType = TextInputType.multiline,
      required IconData icon,
      required double screenWidth,
      void Function(String value)? func,
      String? Function(String? value)? validator,
      AutovalidateMode? validateMode}) {
    return SizedBox(
      width: screenWidth * 0.3,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
        autovalidateMode: validateMode,
      ),
    );
  }
}

