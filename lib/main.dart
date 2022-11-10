import 'dart:io';
import 'dart:typed_data';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:excel/excel.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:read_excel/add_person.dart';
import 'package:read_excel/person.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Excel interact',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExcelPage(),
    );
  }
}

class ExcelPage extends StatefulWidget {
  ExcelPage({Key? key}) : super(key: key);

  @override
  State<ExcelPage> createState() => _ExcelPageState();
}

class _ExcelPageState extends State<ExcelPage> {
  // final file = "assets/test.xlsx";
  List<List<Data?>> excelRows = [];
  String pathSave = '';
  Excel? excel;
  int maxCount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Excel"),
      ),
      body: Column(
        children: [
          excel == null
              ? ElevatedButton(
                  onPressed: () async {
                    if (excel == null) {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['xlsx'],
                        allowMultiple: false,
                      );
                      if (result != null) {
                        // await clearCache();

                        pathSave = result.files.single.path!;
                        var bytes = await File(pathSave).readAsBytes();
                        excel = Excel.decodeBytes(bytes);
                        excelRows = excel!.sheets.entries.first.value.rows;
                      }
                    } else {
                      excelRows = excel!.sheets.entries.first.value.rows;
                      // int count = 0;
                      // List<Person> persons = [];
                      // for (var item in excelRows) {
                      //   if (count > 0) {
                      //     Person p = Person.init();
                      //     p.name = item[1]!.value.toString();
                      //     p.address = item[2]!.value.toString();
                      //     p.phoneNumber = item[3]!.value.toString();
                      //     persons.add(p);
                      //   }
                      //   count++;
                      // }
                    }
                    setState(() {});
                    // for (var table in excel.tables.keys) {
                    //   print(table); //sheet Name
                    //   print(excel.tables[table].maxCols);
                    //   print(excel.tables[table].maxRows);
                    //   for (var row in excel.tables[table].rows) {
                    //     print("$row");
                    //   }
                    // }
                    // FilePickerResult? result = await FilePicker.platform.pickFiles(
                    //   type: FileType.custom,
                    //   allowedExtensions: ['xlsx'],
                    //   allowMultiple: false,
                    // );

                    // if (result != null) {
                    //   var bytes = result.files.single.bytes;
                    //   var excel = Excel.decodeBytes(bytes!);
                    //   print(excel.sheets);
                    //   for (var table in excel.tables.keys) {
                    //     print(table); //sheet Name
                    //     print(excel.tables[table]?.maxCols);
                    //     print(excel.tables[table]?.maxRows);
                    //     for (var row in excel.tables[table]!.rows) {
                    //       print("$row");
                    //     }
                    //   }
                    // }
                  },
                  child: Text("Import excel"))
              : Container(),
          _buildTable(),
          ElevatedButton(
              onPressed: () {
                goAddPerson();
                // print("Max count $maxCount");
                // updateExcel();
                // demoSaveFile();
              },
              child: Text("Add person"))
        ],
      ),
    );
  }

  Widget _buildTable() {
    int count = 0;
    List<Person> persons = [];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Table(
        columnWidths: {
          0: FractionColumnWidth(0.2),
          1: FractionColumnWidth(0.2),
          2: FractionColumnWidth(0.3),
          3: FractionColumnWidth(0.3),
        },
        children: List<TableRow>.generate(excelRows.length, (index) {
          if (count > 0) {
            Person p = Person.init();
            p.stt = double.parse(excelRows[index][0]!.value.toString()).toInt();
            p.name = excelRows[index][1]!.value.toString();
            p.address = excelRows[index][2]!.value.toString();
            p.phoneNumber =
                (excelRows[index][3]!.value.toString()).split('.').first;
            persons.add(p);
            if (count == excelRows.length - 1) {
              maxCount = p.stt;
            }
          }
          count++;
          return TableRow(
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black12)),
              children:
                  List<Widget>.generate(excelRows[index].length, (rowIndex) {
                String text = excelRows[index][rowIndex]!.value.toString();
                return GestureDetector(
                  onTap: () {
                    if (index > 0) {
                      goAddPerson(person: persons[index - 1]);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      text.split('.').first,
                    ),
                  ),
                );
              }));
        }),
      ),
    );
  }

  void goAddPerson({Person? person}) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddPersonPage(
                person: person,
                maxStt: maxCount,
              )),
    );
    if (result != null && result is Person) {
      updateExcel(result);
    }
  }

  void updateExcel(Person person) async {
    bool _allowWriteFile = false;
    PermissionStatus permissionStatus = await Permission.storage.request();

    if (permissionStatus == PermissionStatus.granted) {
      setState(() {
        _allowWriteFile = true;
      });
    }
    if (_allowWriteFile) {
      var sheetObj = excel?.sheets['sheet1'];
      if (sheetObj != null) {
        int rowIndex = person.stt + 1;
        List<String> columValues = ['A', 'B', 'C', 'D'];
        for (var item in columValues) {
          var cell = sheetObj.cell(CellIndex.indexByString("$item$rowIndex"));
          switch (item) {
            case "A":
              cell.value = person.stt.toString();
              break;
            case "B":
              cell.value = person.name;
              break;
            case "C":
              cell.value = person.address;
              break;
            default:
              cell.value = person.phoneNumber;
              break;
          }
        }

        var fileBytes = excel!.save();
        var path = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_DOWNLOADS);
        // print(path);
        File("$path/demo1.xlsx")
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes!);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Success")));
        excelRows = excel!.sheets.entries.first.value.rows;
        setState(() {});
        // // print(directory?.path);
        // File(path.join("${directory?.path}/test1.xlsx"))
        //   ..createSync(recursive: true)
        //   ..writeAsBytesSync(fileBytes!);
      }
    }
  }

  void demoSaveFile() async {
    // var directory = await getExternalStorageDirectory();
    // var downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    // print(downloadsDirectory?.path);
    // File('${downloadsDirectory?.path}/my_file.txt')
    //   ..createSync()
    //   ..writeAsString("Hello");
  }
}

Future<void> clearCache() async {
  try {
    await DefaultCacheManager().emptyCache();
  } catch (e) {
    print(e);
  }
}
