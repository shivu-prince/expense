import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class MessagesListView extends StatelessWidget {
  MessagesListView({
    Key? key,
    required this.messages,
  }) : super(key: key);

  final List<SmsMessage> messages;
  

  final PageController controller = PageController();

  final RegExp acPattern = RegExp(r'A/c \*|account', caseSensitive: false);
  final RegExp upiPattern = RegExp(r'UPI', caseSensitive: false);
  final RegExp creditCardPattern = RegExp(r'credit card', caseSensitive: false);
  final RegExp netBankingPattern = RegExp(r'net banking', caseSensitive: false);
  final RegExp bankPattern = RegExp(r'bank', caseSensitive: false);
  final RegExp debitAmount = RegExp(r'(\d+\.\d*d*)', caseSensitive: false);
  final RegExp creditAmount = RegExp(r'(\d+\.\d*d*)', caseSensitive: false);
  final RegExp credit = RegExp(r'credited|recived', caseSensitive: false);
  final RegExp debit = RegExp(r'debited|paid|sent', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final List<String> CreditAmount = [];
    final List<String> debitAmount = [];

//adding credit and debit amount to list
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

    final double? CreditSum = sumList(CreditAmount);
    final double? debitSum = sumList(debitAmount);
    final double difference = CreditSum! - debitSum!;

    // Main ui
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildDate(),
            const SizedBox(height: 10),
            buildSummary(CreditSum, debitSum, difference),
            const SizedBox(height: 30),
            const Text(
              "Analysis",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 10,),
            for (var type in debitAmount)
                buildDebitTransaction(type),
           ],
        ),
      ),
    );
  }

//gets current in month year formate
  Widget buildDate() {
    final date = DateTime.now();
    return Text(
      DateFormat('yMMMM').format(date).toString(),
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
    );
  }

// card UI for credit debit and differnece amount
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
      elevation: 20,
      shadowColor: Colors.grey.shade200,
      color: Colors.deepPurple,
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(120, 10, 10, 10),
                    child: Text(
                      difference.roundToDouble().toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                    child: arrow(),
                  ),
                ],
              ),
              const SizedBox(
                width: 10,
              ),
              buildSummaryDetails("Credited", creditSum),
              const SizedBox(height: 10),
              buildSummaryDetails("Debited", debitSum),
            ],
          ),
        ),
      ),
    );
  }

//retruns the text for the above card view
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
      ],
    );
  }

//debit list view
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

//maching Regexp to find credit and debit amount
  String extractAmount(String body) {
    final match = debitAmount.firstMatch(body) ?? creditAmount.firstMatch(body);
    return match?.group(0) ?? '0.00';
  }

//passing credit / debit get the sum for the list
  double? sumList(List<String> items) {
    final List<double> doubleList =
        items.map((str) => double.parse(str)).toList();
        if(doubleList.isNotEmpty){
          return doubleList.reduce((value, element) => value + element);
        }
    return 0.00;
  }
}

//to change the arrow in card view
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

