import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bookstore/bookDetails/bookDetailsCart.dart';
import 'package:bookstore/checkout.dart';

class CartPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Cart').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final books = snapshot.data!.docs;

                  return Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.5,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index].data() as Map<String, dynamic>;
                        final author = book['Author'] as String?;
                        final genre = book['Genre'] as String?;
                        final rating = book['Rating'] as num?;
                        final name = book['Name'] as String?;
                        final price = book['Price'] as num?;
                        final image = book['Image'] as String?;
                        final description = book['Description'] as String?;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetailsCartPage(
                                  author: author,
                                  genre: genre,
                                  rating: rating,
                                  name: name,
                                  price: price,
                                  image: image,
                                  description: description,
                                ),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                    child: Image.network(
                                      image ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    name ?? 'Unknown Book',
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  price != null ? '\$$price' : 'Price not available',
                                  style: TextStyle(fontSize: 14),
                                ),
                                IconButton(
                                  icon: Icon(CupertinoIcons.cart_badge_minus),
                                  onPressed: () {
                                    final bookRef = _firestore.collection('Cart').doc(books[index].id);
                                    bookRef.delete().then((_) {
                                      print('Book removed from Cart');
                                    }).catchError((error) {
                                      print('Failed to remove book from Cart: $error');
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CheckoutPage()),
                );
              },
              child: Text('Proceed to Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}
