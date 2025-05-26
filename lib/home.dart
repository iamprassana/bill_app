import 'package:bill_app/formViewPage.dart';
import 'package:bill_app/login.dart';
import 'package:bill_app/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'formPage.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<dynamic>> bills = Database().getBills();

  Color color = Color(0xff5f615f);

  final List pages = [HomePage(), FormPage()];

  int _selectedIndex = 0;

  void onPageChange(int index) {
    setState(() {
      _selectedIndex = index;
      //Closing the navigation drawer
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => pages[_selectedIndex],
        ),
      );
    });
  }

  void resetBillsAfterDelete() {
    setState(() {
      bills = Database().getBills();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: color,
        title: Text(
          "Home",
          style: TextStyle(color: Colors.white, fontSize: 29),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Bills",
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              FutureBuilder<List<dynamic>>(
                future: bills,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: Text(
                        "You do not have any uploaded bills",
                        style: TextStyle(color: Colors.white, fontSize: 30),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final bill = snapshot.data![index];

                      return Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            bill['fName'],
                            style: TextStyle(color: Colors.black),
                          ),
                          subtitle: Text(
                            bill['vName'],
                            style: TextStyle(color: Colors.black87),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              Database().deleteBill(bill['id']);
                              resetBillsAfterDelete();
                            },
                            icon: Icon(Icons.delete),
                          ),
                          onTap: () {
                            //Show the form details along with the image.
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    Formviewpage(snapshot.data!)));
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      drawer: Padding(
        padding: const EdgeInsets.all(8.0),
        child: NavigationDrawer(
          backgroundColor: Colors.white,
          indicatorColor: Colors.grey,
          selectedIndex: _selectedIndex,
          onDestinationSelected: onPageChange,
          children: [
            SizedBox(height: 20),
            NavigationDrawerDestination(
              icon: Icon(
                Icons.home,
                color: Colors.deepPurple,
              ),
              label: Text(
                "Home",
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
            SizedBox(height: 20),
            NavigationDrawerDestination(
              icon: Icon(Icons.pageview, color: Colors.deepPurple),
              label: Text("Form", style: TextStyle(color: Colors.deepPurple)),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        enableFeedback: false,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => FormPage()));
          bills = Database().getBills();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
