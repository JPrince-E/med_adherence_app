import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:med_adherence_app/features/controllers/schedule_controller.dart';

class EditSchedule extends StatefulWidget {

  const EditSchedule({Key? key}) : super(key: key);

  @override
  State<EditSchedule> createState() => _EditScheduleState();
}

class _EditScheduleState extends State<EditSchedule> {
  final ScheduleController controller = Get.put(ScheduleController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Schedule'),
        automaticallyImplyLeading: true,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {

            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Medication Name"),
              _buildRoundedTextField('Medication Name',
                  controller.medicationNameController, Icons.local_hospital),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Amount"),
                        _buildDropdown(
                            'Amount',
                            controller.selectedAmount.value,
                            ['1 pill', '2 pills', '3 pills', 'other'], (value) {
                          controller.selectedAmount.value = value!;
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Dose"),
                        _buildDropdown('Dose', controller.selectedDose.value,
                            ['250 mg', '500 mg', '1000 mg', 'other'], (value) {
                              controller.selectedDose.value = value!;
                            }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("How many days?"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                controller.decrementNofOfDays();
                              },
                            ),
                            SizedBox(
                              width: 50,
                              child: Obx(
                                    () => TextField(
                                  readOnly: true,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(
                                      text: '${controller.noOfDays}'),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                controller.incrementNoOfDays();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("How many times per day?"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                controller.decrementNofOfTimes();
                              },
                            ),
                            SizedBox(
                              width: 50,
                              child: Obx(
                                    () => TextField(
                                  readOnly: true,
                                  textAlign: TextAlign.center,
                                  controller: TextEditingController(
                                      text: '${controller.noOfTimes}'),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                controller.incrementNoOfTimes();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              const Text("Specify Time"),
              Obx(
                    () => _buildTimeFields(controller.noOfTimes.value, context),
              ),
              const SizedBox(height: 16.0),
              Obx(
                    () => ElevatedButton(
                  onPressed: () {
                    _showColorPicker(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        controller.getColor(controller.selectedColor.value)),
                  ),
                  child: const Text(
                    'Choose Color',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (controller.medicationNameController.text
                      .trim()
                      .isNotEmpty) {
                    setState(() {
                      controller.showProgressBar = true;
                    });
                    await controller.addSchedule(
                    );

                  } else {
                    Get.snackbar("A Field is Empty",
                        "Please fill out all fields in text fields.");
                  }
                  setState(() {
                    controller.showProgressBar = false;
                  });
                },
                child: controller.showProgressBar == true
                    ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                )
                    : const Text('Add Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedTextField(
      String label, TextEditingController controller, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: label,
            border: InputBorder.none,
            prefixIcon: Icon(
              icon,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          decoration: InputDecoration(
            hintText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  String _getDoseSuffix(int doseNumber) {
    if (doseNumber % 10 == 1 && doseNumber % 100 != 11) {
      return 'st';
    } else if (doseNumber % 10 == 2 && doseNumber % 100 != 12) {
      return 'nd';
    } else if (doseNumber % 10 == 3 && doseNumber % 100 != 13) {
      return 'rd';
    } else {
      return 'th';
    }
  }

  Widget _buildTimeFields(int noOfTimes, BuildContext context) {
    List<Widget> timeFields = [];
    // controller.selectedTime.add(TimeOfDay.now().obs);
    for (int i = 0; i < noOfTimes; i++) {
      timeFields.add(
        Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 8.0),
                Text(
                  'Time of ${i + 1}${_getDoseSuffix(i + 1)} dose:     ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      // onTap: () async {
                      //   await
                      //   // controller.pickTime(context, i);
                      //   // setState(() {
                      //   //
                      //   // });
                      // },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 16.0),
                              child: Icon(
                                Icons.notifications,
                                color: Colors.blue,
                              ),
                            ),
                            // Obx(
                            //         () {
                            //       return Text(
                            //         // controller.selectedTime[i].value.format(context),
                            //         textAlign: TextAlign.center,
                            //       );
                            //     }
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      );
    }
    return Column(
      children: timeFields,
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a Color'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildColorDropdown(), // Use the color dropdown
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButtonFormField<String>(
          value: controller.selectedColor.value,
          onChanged: (String? value) {
            if (value != null) {
              controller.selectedColor.value = value;
            }
          },
          items: controller.colour
              .map<DropdownMenuItem<String>>(
                (Rx<String> color) => DropdownMenuItem<String>(
              value: color.value,
              child: Container(
                width: 30,
                height: 30,
                color: controller.getColor(color.value),
              ),
            ),
          )
              .toList(),
          decoration: const InputDecoration(
            hintText: 'Color',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
