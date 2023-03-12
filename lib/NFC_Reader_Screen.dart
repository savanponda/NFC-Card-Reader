import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NFCReaderScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => NFCReaderScreenState();
}
class NFCReaderScreenState extends State<NFCReaderScreen> {
  ValueNotifier<dynamic> result = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('NFC Card Reader')),
        body: SafeArea(
          child: FutureBuilder<bool>(
            future: NfcManager.instance.isAvailable(),
            builder: (context, ss) => ss.data != true
                ? Center(child: Text('NfcManager.isAvailable(): ${ss.data}'))
                : Flex(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.vertical,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    constraints: BoxConstraints.expand(),
                    decoration: BoxDecoration(border: Border.all()),
                    child: SingleChildScrollView(
                      child: ValueListenableBuilder<dynamic>(
                        valueListenable: result,
                        builder: (context, value, _) =>
                            Text('${value ?? ''}'),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: GridView.count(
                    padding: EdgeInsets.all(4),
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                    children: [
                      ElevatedButton(
                          child: Text('Tag Read'), onPressed: _tagRead),
                      // ElevatedButton(
                      //     child: Text('Ndef Write'),
                      //     onPressed: _ndefWrite),
                      // ElevatedButton(
                      //     child: Text('Ndef Write Lock'),
                      //     onPressed: _ndefWriteLock),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // void _tagRead() {
  //   NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
  //     var mytag = tag.data["mifareultralight"]["identifier"].map((e) => e.toRadixString(16).padLeft(2, '0')).join(''); ;
  //     result.value = mytag ;
  //     NfcManager.instance.stopSession();
  //   });
  // }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      NfcManager.instance.stopSession();
      print(tag.data);
    });
  }

  void _ndefWrite() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText('Hello World!'),
        NdefRecord.createUri(Uri.parse('https://flutter.dev')),
        NdefRecord.createMime(
            'text/plain', Uint8List.fromList('Hello'.codeUnits)),
        NdefRecord.createExternal(
            'com.example', 'mytype', Uint8List.fromList('mydata'.codeUnits)),
      ]);

      try {
        await ndef.write(message);
        result.value = 'Success to "Ndef Write"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }

  void _ndefWriteLock() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef';
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }

      try {
        await ndef.writeLock();
        result.value = 'Success to "Ndef Write Lock"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }
}








// import 'dart:html';
// import 'dart:io';
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
//
// class NFCMyApp extends StatefulWidget {
//   @override
//   _NFCMyAppState createState() => _NFCMyAppState();
// }

// class _NFCMyAppState extends State<NFCMyApp> with SingleTickerProviderStateMixin {
//   String _platformVersion = '';
//   NFCAvailability _availability = NFCAvailability.not_supported;
//   NFCTag? _tag;
//   String? _result, _writeResult;
//   late TabController _tabController;
//   // List<ndef.NDEFRecord>? _records;
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     if (!kIsWeb) {
//       // _platformVersion =
//       // '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
//     } else
//       _platformVersion = 'Web';
//     initPlatformState();
//     _tabController =  TabController(length: 2, vsync: this);
//     // _records = [];
//   }
//
//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     NFCAvailability availability;
//     try {
//       availability = await FlutterNfcKit.nfcAvailability;
//     } on PlatformException {
//       availability = NFCAvailability.not_supported;
//     }
//
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//
//     setState(() {
//       // _platformVersion = platformVersion;
//       _availability = availability;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//             title: const Text('NFC Flutter Kit Example App'),
//             bottom: TabBar(
//               tabs: <Widget>[
//                 Tab(text: 'Read'),
//                 // Tab(text: 'Write'),
//               ],
//               controller: _tabController,
//             )),
//         body: new TabBarView(controller: _tabController, children: <Widget>[
//           Scrollbar(
//               child: SingleChildScrollView(
//                   child: Center(
//                       child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             const SizedBox(height: 20),
//                             Text('Running on: $_platformVersion\nNFC: $_availability'),
//                             const SizedBox(height: 10),
//                             ElevatedButton(
//                               onPressed: () async {
//                                 try {
//                                   NFCTag tag = await FlutterNfcKit.poll();
//                                   setState(() {
//                                     _tag = tag;
//                                   });
//                                   await FlutterNfcKit.setIosAlertMessage(
//                                       "Working on it...");
//                                   if (tag.standard == "ISO 14443-4 (Type B)") {
//                                     String result1 =
//                                     await FlutterNfcKit.transceive("00B0950000");
//                                     String result2 = await FlutterNfcKit.transceive(
//                                         "00A4040009A00000000386980701");
//                                     setState(() {
//                                       _result = '1: $result1\n2: $result2\n';
//                                     });
//                                   } else if (tag.type == NFCTagType.iso18092) {
//                                     String result1 =
//                                     await FlutterNfcKit.transceive("060080080100");
//                                     setState(() {
//                                       _result = '1: $result1\n';
//                                     });
//                                   } else if (tag.type == NFCTagType.mifare_ultralight ||
//                                       tag.type == NFCTagType.mifare_classic ||
//                                       tag.type == NFCTagType.iso15693) {
//                                     var ndefRecords = await FlutterNfcKit.readNDEFRecords();
//                                     var ndefString = '';
//                                     for (int i = 0; i < ndefRecords.length; i++) {
//                                       ndefString += '${i + 1}: ${ndefRecords[i]}\n';
//                                     }
//                                     setState(() {
//                                       _result = ndefString;
//                                     });
//                                   } else if (tag.type == NFCTagType.webusb) {
//                                     var r = await FlutterNfcKit.transceive(
//                                         "00A4040006D27600012401");
//                                     print(r);
//                                   }
//                                 } catch (e) {
//                                   setState(() {
//                                     _result = 'error: $e';
//                                   });
//                                 }
//
//                                 // Pretend that we are working
//                                 if (!kIsWeb) sleep(new Duration(seconds: 1));
//                                 await FlutterNfcKit.finish(iosAlertMessage: "Finished!");
//                               },
//                               child: Text('Start polling'),
//                             ),
//                             const SizedBox(height: 10),
//                             Padding(
//                                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                                 child: _tag != null
//                                     ? Text(
//                                     'ID: ${_tag!.id}\nStandard: ${_tag!.standard}\nType: ${_tag!.type}\nATQA: ${_tag!.atqa}\nSAK: ${_tag!.sak}\nHistorical Bytes: ${_tag!.historicalBytes}\nProtocol Info: ${_tag!.protocolInfo}\nApplication Data: ${_tag!.applicationData}\nHigher Layer Response: ${_tag!.hiLayerResponse}\nManufacturer: ${_tag!.manufacturer}\nSystem Code: ${_tag!.systemCode}\nDSF ID: ${_tag!.dsfId}\nNDEF Available: ${_tag!.ndefAvailable}\nNDEF Type: ${_tag!.ndefType}\nNDEF Writable: ${_tag!.ndefWritable}\nNDEF Can Make Read Only: ${_tag!.ndefCanMakeReadOnly}\nNDEF Capacity: ${_tag!.ndefCapacity}\n\n Transceive Result:\n$_result')
//                                     : const Text('No tag polled yet.')),
//                           ])))),
//           // Center(
//           //   child: Column(
//           //       mainAxisAlignment: MainAxisAlignment.start,
//           //       children: <Widget>[
//           //         const SizedBox(height: 20),
//           //         Row(
//           //           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           //           children: <Widget>[
//           //             ElevatedButton(
//           //               onPressed: () async {
//           //                 if (_records!.length != 0) {
//           //                   try {
//           //                     NFCTag tag = await FlutterNfcKit.poll();
//           //                     setState(() {
//           //                       _tag = tag;
//           //                     });
//           //                     if (tag.type == NFCTagType.mifare_ultralight ||
//           //                         tag.type == NFCTagType.mifare_classic ||
//           //                         tag.type == NFCTagType.iso15693) {
//           //                       await FlutterNfcKit.writeNDEFRecords(_records!);
//           //                       setState(() {
//           //                         _writeResult = 'OK';
//           //                       });
//           //                     } else {
//           //                       setState(() {
//           //                         _writeResult =
//           //                             'error: NDEF not supported: ${tag.type}';
//           //                       });
//           //                     }
//           //                   } catch (e, stacktrace) {
//           //                     setState(() {
//           //                       _writeResult = 'error: $e';
//           //                     });
//           //                     print(stacktrace);
//           //                   } finally {
//           //                     await FlutterNfcKit.finish();
//           //                   }
//           //                 } else {
//           //                   setState(() {
//           //                     _writeResult = 'error: No record';
//           //                   });
//           //                 }
//           //               },
//           //               child: Text("Start writing"),
//           //             ),
//           //           ],
//           //         ),
//           //         const SizedBox(height: 10),
//           //         Text('Result: $_writeResult'),
//           //         const SizedBox(height: 10),
//           //       ]),
//           // )
//         ]),
//       ),
//     );
//   }
// }