import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/student.dart';
import '../../providers/gatepass_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/injectable.dart';

class ConfirmGatePassPage extends StatefulWidget {
  const ConfirmGatePassPage({
    super.key,
    required this.student,
    required this.personType,
  });

  final String personType;
  final StudentData student;

  @override
  State<ConfirmGatePassPage> createState() => _ConfirmGatePassPageState();
}

class _ConfirmGatePassPageState extends State<ConfirmGatePassPage> {
  String? gatePassType;
  bool issued = false;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'confirm-gate-pass-page',
      parameters: {
        'studentId': widget.student.id,
        'personType': widget.personType,
      },
    );
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Provider.of<GatePassProvider>(context, listen: false).getGatePassTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GatePassProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Issue Gate Pass')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0XFFDEDEDE)),
              ),
              leading: Image.asset('assets/profile.png'),
              title: Text(
                widget.student.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Admission No ${widget.student.admissionNumber}',
                style: const TextStyle(fontSize: 14, color: Color(0XFF4C4A5A)),
              ),
            ),
            const SizedBox(height: 20),
            ...(!issued
                ? [
                    DropdownButtonFormField(
                      hint: const Text(
                        'Gate Pass Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      initialValue: gatePassType,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0XFF2D7FBB),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0XFF2D7FBB),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color(0XFF2D7FBB),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          gatePassType = newValue;
                        });
                      },
                      items: provider.gatepassTypes.map((data) {
                        return DropdownMenuItem(
                          value: data.category,
                          child: Text(data.displayName),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: gatePassType == null
                          ? null
                          : () async {
                              issued = await provider.issueGatePass(
                                context,
                                widget.student,
                                gatePassType!,
                                widget.personType,
                              );
                              setState(() {});
                            },
                      child: const Text('Issue Gate Pass'),
                    ),
                  ]
                : []),
            const Spacer(),
            ...(issued
                ? [
                    const Icon(
                      Icons.verified,
                      color: Color(0XFF12967E),
                      size: 90,
                    ),
                    const Text(
                      'GATE PASS ISSUED\nSUCCESSFULLY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0XFF12967E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Issue Another'),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        context.go('/');
                      },
                      child: const Text('Home'),
                    ),
                  ]
                : []),
          ],
        ),
      ),
    );
  }
}
