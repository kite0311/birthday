import 'package:birthday/add_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'user.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> users = [];

  String firebaseText = '';

  Future<void> _addToFirebase() async {
    final db = FirebaseFirestore.instance;
    _fetchFirebaseData();
    final user = <String, dynamic>{
      "first": "Ada",
      "last": "Lovelace",
      "born": 1815
    };
    await db.collection('users').add(user);
  }

  void _fetchFirebaseData() async {
    final db = FirebaseFirestore.instance;

    final event = await db.collection("users").get();
    final docs = event.docs;
    final users = docs.map((doc) => User.fromFirestore(doc)).toList();

    setState(() {
      this.users = users;
    });
  }

  void _gotoAddPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPage()),
    );
    _fetchFirebaseData();
  }

  void _updateFirestoreData(User user, int bornYear) async {
    final db = FirebaseFirestore.instance;
    await db.collection('users').doc(user.id).update({'born': bornYear});
    _fetchFirebaseData();
  }

  @override
  void initState() {
    super.initState();

    _fetchFirebaseData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView(
        children: users
            .map((user) => ListTile(
                  title: Text(user.first),
                  subtitle: Text(user.last),
                  trailing: Text(user.born.toString()),
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Select Year"),
                            content: Container(
                              // Need to use container to add size constraint.
                              width: 300,
                              height: 300,
                              child: YearPicker(
                                firstDate:
                                    DateTime(DateTime.now().year - 300, 1),
                                lastDate:
                                    DateTime(DateTime.now().year + 100, 1),
                                selectedDate: DateTime(user.born),
                                onChanged: (DateTime dateTime) {
                                  _updateFirestoreData(user, dateTime.year);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        });
                  },
                  onLongPress: () async {
                    final db = FirebaseFirestore.instance;
                    await db.collection('users').doc(user.id).delete();
                    _fetchFirebaseData();
                  },
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _gotoAddPage,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
