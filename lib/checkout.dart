import 'package:bookstore/Pages/cart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  CheckoutPage({Key? key}) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double totalPrice = 0;

  // Function to send email using Twilio SendGrid
  Future<void> sendEmail(String paymentMethod) async {
    const url = 'https://api.sendgrid.com/v3/mail/send';

    final headers = {
      'Authorization': 'Bearer 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', // Your SendGrid API Key here
      'Content-Type': 'application/json',
    };

    final emailData = {
      "personalizations": [
        {
          "to": [{"email": "youssefamin87654@gmail.com"}], // Replace with actual recipient email
          "subject": "New Bookstore Purchase"
        }
      ],
      "from": {"email": "automatedresponse.10@gmail.com"}, // Replace with your email
      "content": [
        {
          "type": "text/plain",
          "value": "A purchase has been made with payment method: $paymentMethod. Total Price: \$${totalPrice.toStringAsFixed(2)}."
        }
      ]
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(emailData),
    );

    if (response.statusCode == 202) {
      print("Email sent successfully.");
    } else {
      print("Failed to send email: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Cart').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final books = snapshot.data!.docs;

          totalPrice = 0; // reset the total price
          for (final book in books) {
            final data = book.data() as Map<String, dynamic>;
            final price = data['Price'] as num?;
            totalPrice += price ?? 0;
          }

          return Column(
            children: [
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 20,
                    left: 20,
                  ),
                  child: ListView.builder(
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index].data() as Map<String, dynamic>;
                      final name = book['Name'] as String?;
                      final price = book['Price'] as num?;
                      return Card(
                        margin: EdgeInsets.only(
                          top: 10,
                        ),
                        color: Colors.grey[800],
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name ?? 'Unknown Book',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                              Text(
                                price != null
                                    ? '\$$price'
                                    : 'Price not available',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      'Total Price: \$${totalPrice.toStringAsFixed(2)}',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  scrollable: true,
                                  title: Text('Payment Method'),
                                  content: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            FirebaseFirestore.instance
                                                .collection('Cart')
                                                .snapshots()
                                                .forEach((querySnapshot) {
                                              for (QueryDocumentSnapshot docSnapshot
                                              in querySnapshot.docs) {
                                                docSnapshot.reference.delete();
                                              }
                                            });
                                            await sendEmail("Credit Card");
                                          },
                                          child: Text("Credit Card"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            FirebaseFirestore.instance
                                                .collection('Cart')
                                                .snapshots()
                                                .forEach((querySnapshot) {
                                              for (QueryDocumentSnapshot docSnapshot
                                              in querySnapshot.docs) {
                                                docSnapshot.reference.delete();
                                              }
                                            });
                                            await sendEmail("Debit Card");
                                          },
                                          child: Text("Debit Card"),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Icon(Icons.payment)),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
