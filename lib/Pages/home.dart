import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bookstore/bookDetails/bookDetails.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Books').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final books = snapshot.data!.docs;

          final arabicBooks = books.where((doc) {
            final bookData = doc.data() as Map<String, dynamic>;
            return bookData['Language'] == 'Arabic';
          }).toList();

          final englishBooks = books.where((doc) {
            final bookData = doc.data() as Map<String, dynamic>;
            return bookData['Language'] == 'English';
          }).toList();

          final highlyRatedBooks = books.where((doc) {
            final bookData = doc.data() as Map<String, dynamic>;
            final rating = bookData['Rating'] as num?;
            return rating != null && rating > 4;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Highly Rated Books Section
                Container(
                  color: Colors.brown[800], // Thin brown bar behind the title
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.yellow[600]),
                      SizedBox(width: 10),
                      Text(
                        'Highly Rated Books',
                        style: GoogleFonts.sofadiOne(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildBookRow(
                    highlyRatedBooks.sublist(0, highlyRatedBooks.length > 7 ? 7 : highlyRatedBooks.length),
                    context),

                // Arabic Books Section
                Container(
                  color: Colors.brown[800], // Thin brown bar behind the title
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  child: Text(
                    'افضل الكتب العربيــه',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white60,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildBookRow(arabicBooks.sublist(0, arabicBooks.length > 7 ? 7 : arabicBooks.length), context),

                // English Books Section
                Container(
                  color: Colors.brown[800], // Thin brown bar behind the title
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  child: Text(
                    'Best English Books',
                    style: GoogleFonts.sofadiOne(
                      textStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white60,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildBookRow(englishBooks.sublist(0, englishBooks.length > 7 ? 7 : englishBooks.length), context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookRow(List<QueryDocumentSnapshot> books, BuildContext context) {
    return Container(
      height: 325, // Increased height for the book rows
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
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
                  builder: (context) => BookDetailsPage(
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
              margin: EdgeInsets.symmetric(horizontal: 10),
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
                        width: 150,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    name ?? 'Unknown Book',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          price != null ? 'EGP $price' : 'Price not available',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: Icon(CupertinoIcons.heart, color: Colors.red),
                        onPressed: () {
                          final bookData = books[index].data() as Map<String, dynamic>;

                          // Add to Wishlist without checking for duplicates in HomePage
                          _firestore.collection('Wishlist').add(bookData);
                        },
                      ),
                      IconButton(
                        icon: Icon(CupertinoIcons.cart_badge_plus, color: Colors.blueAccent),
                        onPressed: () async {
                          final bookData = books[index].data() as Map<String, dynamic>;

                          // Check if the book is already in the cart
                          QuerySnapshot existingCartItems = await _firestore
                              .collection('Cart')
                              .where('Name', isEqualTo: bookData['Name']) // Assuming 'Name' is unique
                              .get();

                          if (existingCartItems.docs.isNotEmpty) {
                            // If the book is already in the cart, show a message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Book is already in the cart!')),
                            );
                          } else {
                            // If the book is not in the cart, add it
                            _firestore.collection('Cart').add(bookData).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Book added to cart!')),
                              );
                            }).catchError((error) {
                              print('Failed to add book to cart: $error');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to add book to cart')),
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
