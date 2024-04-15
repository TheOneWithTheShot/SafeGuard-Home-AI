import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:safeguard_home_ai/screens/user_center_page.dart';

import 'home_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  bool isInitialLoad = true;

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xAA1A1B1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser?.uid)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading");
                } else {
                  if (snapshot.hasError) {
                    return const Text("Error");
                  } else {
                    Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                    return DefaultTextStyle(
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const UserCenterPage()),
                          );
                        },
                        child: Text(data['username']),
                      ),
                    );
                  }
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Icon(Icons.account_circle, color: Colors.white),
            ),
            const Spacer(),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text(
                'Log Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: Opacity(
              opacity: 1,
              child: Card(
                elevation: 5,
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Notification Center',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('notifications')
                            .where('UID', isEqualTo: currentUser?.uid)
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Something went wrong');
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Loading");
                          }

                          // Check if a new document has been added
                          if (!isInitialLoad && snapshot.data!.docChanges.any((docChange) => docChange.type == DocumentChangeType.added)) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              QuickAlert.show(
                                context: context,
                                type: QuickAlertType.warning,
                                text: 'New notification received!',
                                showConfirmBtn: true,
                              );
                            });
                          }

                          if (isInitialLoad && snapshot.data!.docs.isNotEmpty) {
                            isInitialLoad = false;
                          }

                          return SingleChildScrollView(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (BuildContext context, int index) {
                                DocumentSnapshot document =
                                    snapshot.data!.docs[index];
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                Timestamp timestamp = data['time'];
                                DateTime dateTime = timestamp.toDate();
                                String formattedTime =
                                    DateFormat('MMMM d, y H:mm:ss')
                                        .format(dateTime);

                                List<String> images =
                                    List<String>.from(data['images']);

                                return ExpansionTile(
                                  title: Text(
                                    data['subject'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: RichText(
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        const TextSpan(
                                            text: 'Status: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(
                                          text: '${data['status']}\n',
                                          style: TextStyle(
                                            color: data['status'] == 'read'
                                                ? Colors.green
                                                : data['status'] ==
                                                        'emergencies called'
                                                    ? Colors.red
                                                    : null,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const TextSpan(
                                            text: 'Time: ',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        TextSpan(text: formattedTime),
                                      ],
                                    ),
                                  ),
                                  children: [
                                    FutureBuilder(
                                      future: Future.value(images),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<String>>
                                              snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          // Handle the error
                                          return const Text(
                                              'Error loading images');
                                        } else {
                                          return Column(
                                            children: snapshot.data!
                                                .map<Widget>((url) => SizedBox(
                                                      height: 200,
                                                      width: 200,
                                                      child: Image.network(
                                                        url,
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (BuildContext
                                                                    context,
                                                                Object
                                                                    exception,
                                                                StackTrace?
                                                                    stackTrace) {
                                                          return const Icon(
                                                              Icons.error);
                                                        },
                                                      ),
                                                    ))
                                                .toList(),
                                          );
                                        }
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15.0, 0, 15.0, 16.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.blue,
                                            ),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .doc(document.id)
                                                  .delete();
                                            },
                                            child: const Text('Delete'),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.blue,
                                            ),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .doc(document.id)
                                                  .update({'status': 'read'});
                                            },
                                            child: const Text(
                                                'I will take care of it'),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () {
                                              FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .doc(document.id)
                                                  .update({
                                                'status': 'emergencies called'
                                              });
                                            },
                                            child: const Text('Call 911'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
