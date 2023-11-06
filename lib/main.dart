import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Widget/MainUi.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SmsQuery _query = SmsQuery();
  List<SmsMessage> _messages = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter SMS Inbox App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.only(top: 70),
          padding: const EdgeInsets.all(10.0),
          child: _messages.isNotEmpty
              ? MessagesListView(
                  messages: _messages,
                )
              : Center(
                  child: Text(
                    'Tap refresh button..\n Allow all permision and coutinue',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            var permission = await Permission.sms.status;
            if (permission.isGranted) {
              final messages = await _query.querySms(
                kinds: [
                  SmsQueryKind.inbox,
                  SmsQueryKind.sent,
                ],
              );
              setState(() => _messages = messages);
            } else {
              await Permission.sms.request();
              if(permission.isGranted){
                _messages.isNotEmpty
              ? MessagesListView(
                  messages: _messages,
                )
              : const Center(
                child: Text("do give permission"),
              );
              }
            }
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}


