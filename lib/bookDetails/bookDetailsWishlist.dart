import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookDetailsWishlistPage extends StatelessWidget {
  final String? author, genre, name, image, description;
  final num? price, rating;

  BookDetailsWishlistPage({
    this.name,
    this.price,
    this.image,
    this.description,
    this.author,
    this.genre,
    this.rating,
  });

  final _reviewController = TextEditingController();
  Future<void> addReview() async {
    final review = _reviewController.text;
    final bookQuery =
        _firestore.collection('Wishlist').where('Name', isEqualTo: name);
    final bookSnapshot = await bookQuery.get();

    if (bookSnapshot.docs.isNotEmpty) {
      final bookDoc = bookSnapshot.docs.first;
      await bookDoc.reference.update({
        'Reviews': FieldValue.arrayUnion([review])
      });
      _reviewController.clear();
    } else {
      print('Book not found');
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _reviewController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name != null ? '$name' : 'Unknown Book',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              price != null ? 'EGP $price' : 'Price not available',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  author != null ? 'by $author' : 'Unknown Author',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      side: MaterialStateProperty.all(
                          BorderSide(color: Colors.black, width: 1.0)),
                      elevation: MaterialStateProperty.all(0.0.toDouble()),
                    ),
                    onPressed: () async {
                      // get a query reference to the document you want to move based on some field value
                      final bookQuery = _firestore
                          .collection('Wishlist')
                          .where('Name', isEqualTo: name);
                      // get the query snapshot
                      final bookSnapshot = await bookQuery.get();
                      // check if the query returned any documents
                      if (bookSnapshot.size > 0) {
                        // get the first document from the query snapshot
                        final bookDoc = bookSnapshot.docs.first;
                        // get the data from the document
                        final bookData = bookDoc.data();
                        // create a new document in the target collection
                        await _firestore.collection('Cart').add(bookData);
                        // delete the document from the source collection
                        await bookDoc.reference.delete();

                        Navigator.pop(context);
                      } else {
                        print('couldn\'t add item to cart');
                      }
                    },
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add to cart",
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(
                            CupertinoIcons.cart_badge_plus,
                            color: Colors.blue[900],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Image.network(
              image ?? '',
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 15),
            const Text(
              "Rating",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(rating != null ? '$rating' : 'Rating not available'),
            const SizedBox(height: 15),
            const Text(
              "Genre",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(genre != null ? '$genre' : 'Genre not available'),
            const SizedBox(height: 15),
            const Text(
              "Description",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(description != null
                ? '$description'
                : 'Description not available'),
            const SizedBox(height: 15),

            //Reviews
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                padding: EdgeInsets.all(15),
                color: Colors.grey[300],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Reviews",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _reviewController,
                            decoration: const InputDecoration(
                                hintText: 'Add a review',
                                border: InputBorder.none),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.transparent),
                              side: MaterialStateProperty.all(
                                  BorderSide(color: Colors.black, width: 1.0)),
                              elevation:
                                  MaterialStateProperty.all(0.0.toDouble()),
                            ),
                            onPressed: addReview,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Submit",
                                  style: TextStyle(color: Colors.black),
                                ),
                                Icon(
                                  CupertinoIcons.add_circled,
                                  color: Colors.blue[900],
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: _firestore
                            .collection('Wishlist')
                            .where('Name', isEqualTo: name)
                            .snapshots()
                            .map((querySnapshot) => querySnapshot.docs.first),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text(
                                'Something went wrong: ${snapshot.error}');
                          }
                          if (!snapshot.data!.exists) {
                            return Text('No book with this name found');
                          }
                          final reviews = snapshot.data!.get('Reviews') ?? [];
                          if (reviews.isEmpty) {
                            return Text('No reviews');
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final review in reviews)
                                Container(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Text('• $review'),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15)
          ],
        ),
      ),
    );
  }
}
