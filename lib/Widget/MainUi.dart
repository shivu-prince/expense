import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class MessagesListView extends StatelessWidget {
  MessagesListView({
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

    final double CreditSum = sumList(CreditAmount);
    final double debitSum = sumList(debitAmount);
    final double difference = CreditSum - debitSum;

    // month year and card view 

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              buildDate(),
              const SizedBox(height: 10),
              buildSummary(CreditSum, debitSum, difference),
              const SizedBox(height: 30),
              const Text(
                "Debit list",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              for (var type in debitAmount) buildDebitTransaction(type),
            ],
          ),
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
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildSummaryDetails("Credited", creditSum),
                   const SizedBox(height: 10),
                  buildSummaryDetails("Debited", debitSum),
                ],
              ),
              const SizedBox(
                width: 90,
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  difference.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: arrow(),
              ),
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
  double sumList(List<String> items) {
    final List<double> doubleList =
        items.map((str) => double.parse(str)).toList();
    return doubleList.reduce((value, element) => value + element);
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