import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

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
              ? _MessagesListView(
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
              debugPrint('sms inbox messages: ${messages.length}');

              setState(() => _messages = messages);
            } else {
              await Permission.sms.request();
            }
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

class _MessagesListView extends StatelessWidget {
  _MessagesListView({
    Key? key,
    required this.messages,
  }) : super(key: key);

  final List<SmsMessage> messages;

  final RegExp acPattern = RegExp(r'A/c \*', caseSensitive: false);
  final RegExp upiPattern = RegExp(r'UPI', caseSensitive: false);
  final RegExp creditCardPattern = RegExp(r'credit card', caseSensitive: false);
  final RegExp netBankingPattern = RegExp(r'net banking', caseSensitive: false);
  final RegExp bankPattern = RegExp(r'bank', caseSensitive: false);
  final RegExp debitAmount = RegExp(r'(\d+\.\d*d*)', caseSensitive: false);
  final RegExp creditAmount = RegExp(r'(\d+\.\d*d*)', caseSensitive: false);
  final RegExp credit = RegExp(r'credited', caseSensitive: false);
  final RegExp debit = RegExp(r'debited', caseSensitive: false);

  Widget build(BuildContext context) {
    final List<String> CreditAmount = [];
    final List<String> debitAmount = [];

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      if (bankPattern.hasMatch(message.body!) &&
          acPattern.hasMatch(message.body!)) {
        final transactionType = extractAmount(message.body!);
        if (credit.hasMatch(message.body!)) {
          CreditAmount.add(transactionType);
        } else if (debit.hasMatch(message.body!)) {
          debitAmount.add(transactionType);
        }
      }
    }

    final double CreditSum = sumList(CreditAmount);
    final double debitSum = sumList(debitAmount);
    final double difference = CreditSum - debitSum;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              buildDate(),
              const SizedBox(height: 20),
              buildSummary(CreditSum, debitSum, difference),
              const SizedBox(height: 20),
              const Text(
                "Debit list",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              for (var type in debitAmount) buildDebitTransaction(type),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDate() {
    final date = DateTime.now();
    return Text(
      DateFormat('yMMMM').format(date).toString(),
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
    );
  }

  Widget buildSummary(double creditSum, double debitSum, double difference) {

    arrow() {
      if (difference.isNegative) {
        return const arrowIndicatemin();
      } else {
        return const arrowIndicatemax();
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 30,
      shadowColor: Colors.black,
      color: Colors.deepPurple,
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Row(
            children: [
              Column(
                children: [
                  buildSummaryDetails("Credited", creditSum),
                  const SizedBox(height: 1),
                  buildSummaryDetails("Debited", debitSum),
                ],
              ),
              const SizedBox(
                width: 90,
              ),
              Text(
                difference.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                child: arrow(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryDetails(String title, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title : ${amount.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildDebitTransaction(String type) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        shadowColor: Colors.black,
        color: Colors.grey.shade200,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(" Rs. $type"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String extractAmount(String body) {
    final match = debitAmount.firstMatch(body) ?? creditAmount.firstMatch(body);
    return match?.group(0) ?? '0.00';
  }

  double sumList(List<String> items) {
    final List<double> doubleList =
        items.map((str) => double.parse(str)).toList();
    return doubleList.reduce((value, element) => value + element);
  }
}

class arrowIndicatemin extends StatelessWidget {
  const arrowIndicatemin({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.arrow_downward_rounded,
      color: Colors.red,
    );
  }
}

class arrowIndicatemax extends StatelessWidget {
  const arrowIndicatemax({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.arrow_upward_rounded,
      color: Colors.green,
    );
  }
}
