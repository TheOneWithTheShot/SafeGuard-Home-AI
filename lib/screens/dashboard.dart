import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  List<bool> _isExpanded = [];

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xAA1A1B1E),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              } else {
                if (snapshot.hasError) {
                  return const Text("Error");
                } else {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  return Text(data['username']);
                }
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            child: Icon(Icons.account_circle),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 5,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Notification Center',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Loading");
                  }

                  _isExpanded = List<bool>.filled(snapshot.data!.docs.length, false);

                  return ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.docs.asMap().map((index, document) {
                      Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                      Timestamp timestamp = data['time'];
                      DateTime dateTime = timestamp.toDate();
                      String formattedTime = DateFormat('MMMM d, y H:mm:ss').format(dateTime);

                      return MapEntry(index, Card(
                        child: ExpansionPanelList(
                          expansionCallback: (int index, bool isExpanded) {
                            setState(() {
                              _isExpanded[index] = !isExpanded;
                            });
                          },
                          children: [
                            ExpansionPanel(
                              headerBuilder: (BuildContext context, bool isExpanded) {
                                return ListTile(
                                  title: Text(data['subject']),
                                  subtitle: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        const TextSpan(text: 'Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: '${data['status']}\n'),
                                        const TextSpan(text: 'Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                                        TextSpan(text: formattedTime),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              body: Column(
                                children: data['images'].map<Widget>((image) {
                                  return FutureBuilder(
                                    future: FirebaseStorage.instance.ref(image).getDownloadURL(),
                                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        // Handle the error
                                        return const Text('Error loading image');
                                      } else {
                                        return Image.network(snapshot.data!);
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              isExpanded: _isExpanded[index],
                            ),
                          ],
                        ),
                      ));
                    }).values.toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}