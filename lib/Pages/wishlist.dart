import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bookstore/bookDetails/bookDetailsWishlist.dart';

class WishlistPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Wishlist').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final books = snapshot.data!.docs;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.4,
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
                      builder: (context) => BookDetailsWishlistPage(
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
                          child: Image.network(
                            image ?? '',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        name ?? 'Unknown Book',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            price != null ? '\$$price' : 'Price = ?',
                            style: TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: Icon(CupertinoIcons.heart_slash),
                            onPressed: () {
                              final bookRef = _firestore
                                  .collection('Wishlist')
                                  .doc(books[index].id);

                              // Simply remove the book from the Wishlist collection
                              bookRef.delete();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
