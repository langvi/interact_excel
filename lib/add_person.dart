import 'package:flutter/material.dart';
import 'package:read_excel/person.dart';
import 'package:read_excel/text_input.dart';

class AddPersonPage extends StatefulWidget {
  final Person? person;
  final int maxStt;
  AddPersonPage({Key? key, this.person, required this.maxStt})
      : super(key: key);

  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    if (widget.person != null) {
      nameController.text = widget.person!.name;
      addressController.text = widget.person!.address;
      phoneController.text = widget.person!.phoneNumber;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create person"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    InputText(
                      hintText: "Enter name...",
                      controller: nameController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return "Can't empty";
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InputText(
                        hintText: "Enter address...",
                        controller: addressController,
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Can't empty";
                          }
                          return null;
                        },
                      ),
                    ),
                    InputText(
                      hintText: "Enter phone...",
                      controller: phoneController,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return "Can't empty";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            width: double.infinity,
            height: 80,
            child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    handleAddTable();
                  }
                },
                child: Text("Save")),
          )
        ],
      ),
    );
  }

  void handleAddTable() {
    Person p = Person(
        stt: widget.person != null ? widget.person!.stt : widget.maxStt + 1,
        name: nameController.text,
        address: addressController.text,
        phoneNumber: phoneController.text);
    Navigator.pop(context, p);
  }
}
