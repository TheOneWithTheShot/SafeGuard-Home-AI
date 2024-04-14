import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class UserCenterPage extends StatefulWidget {
  const UserCenterPage({super.key});

  @override
  _UserCenterPageState createState() => _UserCenterPageState();
}

class _UserCenterPageState extends State<UserCenterPage> {
  final TextEditingController cameraIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // Aligns the column to the top
            crossAxisAlignment: CrossAxisAlignment.center,
            // Centers the column horizontally
            children: [
              const Text(
                'User Center',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser?.uid)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text("Error");
                  } else {
                    Map<String, dynamic> data =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Container(
                      alignment: Alignment.topLeft,
                      // Aligns the user's info to the left
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Aligns the column's children to the left
                        children: [
                          if (isEditing)
                            TextField(
                              controller: usernameController
                                ..text = data['username'],
                              decoration: const InputDecoration(
                                labelText: 'Username',
                              ),
                            )
                          else
                            RichText(
                              text: TextSpan(
                                text: 'Username: ',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${data['username']}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          if (isEditing)
                            TextField(
                              controller: emailController..text = data['email'],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                              ),
                            )
                          else
                            RichText(
                              text: TextSpan(
                                text: 'Email: ',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${data['email']}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          if (isEditing)
                            TextField(
                              controller: phoneController..text = data['phone'],
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                              ),
                            )
                          else
                            RichText(
                              text: TextSpan(
                                text: 'Phone: ',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: '${data['phone']}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 20),
                          if (isEditing)
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isEditing = false;
                                        });
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(currentUser?.uid)
                                              .update({
                                            'username': usernameController.text,
                                            'email': emailController.text,
                                            'phone': phoneController.text,
                                          });
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.success,
                                            text: 'Information updated successfully!',
                                            showConfirmBtn: true,
                                          );
                                          setState(() {
                                            isEditing = false;
                                          });
                                        } catch (e) {
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.error,
                                            text: 'Error updating information!\n$e',
                                            showConfirmBtn: true,
                                          );
                                        }
                                      },
                                      child: const Text('Update'),
                                    ),
                                  ],
                                )
                              ],
                            )
                          else
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = true;
                                });
                              },
                              child: const Text('Edit'),
                            ),
                        ],
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text('Add Cameras', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: cameraIdController,
                      decoration: const InputDecoration(
                        labelText: 'Camera ID',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        if (cameraIdController.text.isEmpty) {
                          QuickAlert.show(
                            context: context,
                            type: QuickAlertType.error,
                            text: 'Camera ID cannot be empty!',
                            showConfirmBtn: true,
                          );
                          return;
                        }

                        await FirebaseFirestore.instance.collection('userCamera').add({
                          'cameraID': cameraIdController.text,
                          'UID': currentUser?.uid,
                        });
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.success,
                          text: 'Camera added successfully!',
                          showConfirmBtn: true,
                        );
                        cameraIdController.clear();
                      } catch (e) {
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          text: 'Error adding camera!\n$e',
                          showConfirmBtn: true,
                        );
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
