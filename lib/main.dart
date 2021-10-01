import 'dart:async';
import 'package:flutter/material.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
import 'package:splashscreen/splashscreen.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FanApp());
}

//start Firebase Auth
FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Image.asset(
      'assets/myface.jpg',
    )));
  }
}

//loading screen that transitions to main app
class SplashTransition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //splashscreen using package
    return new SplashScreen(
        seconds: 5, //10,
        //navigateAfterSeconds: new LoginPage(),
        navigateAfterSeconds: new authChoice(),
        title: new Text('Welcome to FandomApp'),
        image: new Image.asset('assets/myface.jpg'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        loaderColor: Colors.red);
  }
}

class authChoice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
          Text("Select a sign-in Method"),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: Colors.black,
              //textStyle: const TextStyle(Fontweight.bold),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text('Email and Password'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: Colors.black,
              //textStyle: const TextStyle(Fontweight.bold),
            ),
            onPressed: () {
              signInWithGoogle();
              Navigator.push(
                context,
                //navigate to google sign in
                MaterialPageRoute(builder: (context) => new ContentPage()),
              );
            },
            child: const Text('Sign in with Google'),
          )
        ])));
  }
}

//google sign in authentication method
Future<UserCredential> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Once signed in, return the UserCredential
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

//core of the app. Loads the login screen after Firebase is initialized
class FanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter login UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //splash loads
      home: SplashTransition(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var UController = TextEditingController();
  var PController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    PController.dispose();
    UController.dispose();
    super.dispose();
  }

//login logic
  Future<void> EmailSignIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      showDialog<String>(
        //if password and username match database, allow login and navigate to mainpage (pictures, etc)
        //Otherwise send a popup that the login credentials were incorrect
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Login Status'),
          content: const Text('Login Successful'),
          actions: <Widget>[
            TextButton(
              //This is where it would navigate to the actual app's content
              onPressed: () => {Navigator.pop(context, 'OK')},
              child: const Text('OK'),
            ),
          ],
        ),
      );
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ContentPage()));
    } on FirebaseAuthException catch (e) {
      showDialog<String>(
        //if password and username match database, allow login and navigate to mainpage (pictures, etc)
        //Otherwise send a popup that the login credentials were incorrect
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Login Status'),
          content:
              const Text('The login credentials you submitted were not found'),
          actions: <Widget>[
            TextButton(
              onPressed: () => {Navigator.pop(context, 'OK')},
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

//custom code for logging in user. Will comment for now to test Auth Login/Registration
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Center(
              //padding: EdgeInsets.fromLTRB(3.0, 20.0, 3.0, 0.0,),
              child: new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
            TextField(
              controller: UController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: 'Email'),
            ),
            TextField(
                obscureText: true,
                controller: PController,
                decoration: const InputDecoration(
                    /*prefixText: 'prefix',*/
                    border: OutlineInputBorder(),
                    hintText: 'Password')),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.black,
                textStyle: const TextStyle(fontSize: 25),
              ),
              onPressed: () => {
                if (UController.text == "" || PController.text == "")
                  {
                    showDialog<String>(
                      //if password and username match database, allow login and navigate to mainpage (pictures, etc)
                      //Otherwise send a popup that the login credentials were incorrect
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Login Status'),
                        content:
                            const Text('Please enter your login information.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              UController.clear();
                              PController.clear();
                              Navigator.pop(context, 'OK');
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    )
                  }
                else
                  {
                    EmailSignIn(UController.text, PController.text),
                    /*Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ContentPage())),*/
                  }
                //if logic for proper vs improper credentials
                /*else{
                    showDialog<String>(
                      //if password and username match database, allow login and navigate to mainpage (pictures, etc)
                      //Otherwise send a popup that the login credentials were incorrect
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Login Status'),
                        content: const Text('The login credentials you submitted were not found'),
                        actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                          ),
                        ],
                      ),
                    )}*/
              },
              child: const Text('Login'),
              //onPressed: () =>{attemptLogin()}
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(16.0),
                primary: Colors.black,
                //textStyle: const TextStyle(Fontweight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationForm()),
                );
              },
              child: const Text('Create New Account'),
            ),
          ]))),
    );
  }
//Once received, check backend to see if the records exist
//if they don't, tell user that the account doesn't exist and that they should register, instead

//if it does, log them in and load the fanpage
}

//Android implementation of Firestore starts here...
//Login method. Grab input data from username and password fields. Print them on screen to verify I am grabbing them.

class RegistrationForm extends StatelessWidget {
  RegistrationForm({Key? key}) : super(key: key);
  //Controllers for first name, last name, etc
  var FNController = TextEditingController();
  var LNController = TextEditingController();
  var EController = TextEditingController();
  var PwController = TextEditingController();
  //flag for checking if an email is already registered
  var AccExists = false;
//important for verifying or creating users
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> createAccount(
      String Email, String Pass, String FName, String LName) async {
    try {
      //sets flag to false. If it's a fresh email, this value will be passed on
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: Email, password: Pass);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        //if email is already used, trip flag
        AccExists = true;
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    addUser(FName, LName);
  }

//constructor, if using UID: (String FName, String LName, String Email, String Pass, String UID)
  Future<void> addUser(String FName, String LName) async {
    // Call the user's CollectionReference to add a new user
    var user = FirebaseAuth.instance.currentUser;
    //check if user exists and the account isn't already in use
    if (user != null && AccExists == false) {
      String uid = user.uid;
      return users
          .add({
            //'Email': Email, // xyz@gmail.com
            'First Name': FName, // Stokes and Sons
            'Last Name': LName, // 42
            'Registration Date/Time': DateTime
                .now(), //insert function to grab time/date, format it, and convert it to string
            'UID': uid,
            'User Role': "Customer",
            //'Password': Pass
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));

      //send popup showing that the user registered successfully. When the user clicks "ok", send them back to login page
    } else {}
  }

  @override
  //wall of textfields...
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Center(
                //padding: EdgeInsets.fromLTRB(3.0, 20.0, 3.0, 0.0,),
                child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
          TextField(
            controller: FNController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'First Name'),
          ),
          TextField(
            controller: LNController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Last Name'),
          ),
          TextField(
            controller: EController,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Email'),
          ),
          TextField(
            controller: PwController,
            obscureText: true,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Password'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              primary: Colors.black,
              //textStyle: const TextStyle(Fontweight.bold),
            ),
            //submit values to firestore
            onPressed: () => {
              //first set values of each of the parameters, then call addUser
              /*FirstName = Text(FNController.text),
                    LastName = Text(LNController.text),
                    UserID = "1",
                    Email = Text(EController.text),
                    Password = Text(PwController.text),*/

              //email/password authentication here

              //constructor String FName, String LName, String Email, String Pass, --String UID--, --String Role--
              //users data here
              createAccount(EController.text, PwController.text,
                  FNController.text, LNController.text),
              //addUser(FNController.text, LNController.text),
              if (AccExists == false)
                {
                  showDialog<String>(
                    //if password and username match database, allow login and navigate to mainpage (pictures, etc)
                    //Otherwise send a popup that the login credentials were incorrect
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Login Status'),
                      content: const Text('Account successfully created'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => {
                            //navigates back to login page
                            Navigator.of(context)..pop()..pop()
                            //Navigator.pop(context, 'OK')
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  )
                }
              else
                {
                  //reset flag
                  AccExists = false,
                  showDialog<String>(
                    //if password and username match database, allow login and navigate to mainpage (pictures, etc)
                    //Otherwise send a popup that the login credentials were incorrect
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Login Status'),
                      content: const Text(
                          'An account is already associated with that email. Please register with a new email address.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  )
                }
            },
            child: const Text('Register'),
          )
        ]))));
  }
}

//content page. Should largely be the same, except for the ability to add messages for ADMIN
class ContentPage extends StatefulWidget {
  const ContentPage({Key? key}) : super(key: key);
  _ContentPageState createState() => _ContentPageState();
}

class _ContentPageState extends State<ContentPage> {
  //allows change and access after role is fetched from firebase
  String userRole = "Customer";

  var MController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    MController.dispose();
    super.dispose();
  }

  Future<String> checkAuthority() async {
    // Call the user's CollectionReference to add a new user
    var user = FirebaseAuth.instance.currentUser;
    var authLevel = "";
    //this is the default value.
    if (user != null) {
      String uid = user.uid;
      //return collection of users
      //adapted from https://stackoverflow.com/questions/48937864/firestore-queries-on-flutter
      QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
          .collection('users')
          .where('UID', isEqualTo: uid)
          .get();
      List<QueryDocumentSnapshot> docs = snapshot.docs;
      //should only be one doc associated with each user's ID, so it is equal to checking a single item
      var checkDoc = docs[0].data() as Map<String, dynamic>;
      authLevel = checkDoc['User Role'];
      //print("Alt GETTER " + authLevel);
    }
    //need to search using uid, and then check if they have ADMIN in Roles field
    //firestore.collection("users").where('UID == uid').get();
    //print("VERY IMPORTANT");
    //print(firestore.collection("users").where('UID == uid').get());
    //print(userRef);
    //print(userRole);
    /*firestore.collection("users").get().then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          firestore
              .collection("users")
              .doc(uid)
              .collection("User")
              .get()
              .then((querySnapshot) {
            querySnapshot.docs.forEach((result) {
              print(result.data());

              //authority = awaitresult.data();
              //return authority;
            });
          });
        });
      }*/
    //);
    return authLevel;
  }

  //creates action button on condition
  Widget _createAB() {
    //adapted from https://stackoverflow.com/questions/60069369/flutter-how-to-convert-futurestring-to-string
    checkAuthority().then((String role) {
      setState(() {
        userRole = role;
      });
    });

    if (userRole == ("ADMIN")) {
      return FloatingActionButton(
          onPressed: () => {
                checkAuthority(),
                showDialog<String>(
                  //if password and username match database, allow login and navigate to mainpage (pictures, etc)
                  //Otherwise send a popup that the login credentials were incorrect
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('New Message'),
                    content: TextField(
                      controller: MController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter message here...'),
                    ),
                    actions: <Widget>[
                      //closes window without popping
                      TextButton(
                        onPressed: () => {
                          //navigates back to login page
                          addMessage(MController.text),
                          Navigator.pop(context),
                          MController.clear(),
                        },
                        child: const Text('Post Message'),
                      ),
                      //post message, then close window
                      TextButton(
                        onPressed: () => {
                          //navigates back to login page
                          Navigator.of(context).pop()
                          //Navigator.pop(context, 'OK')
                        },
                        child: const Text('Close Window'),
                      ),
                    ],
                  ),
                )
              },
          tooltip: 'Post Message',
          child: const Icon(Icons.add));
    } else {
      return Container();
    }
  }

  //method for ADMIN to post a new message
  Future<void> addMessage(String content) async {
    // Call the user's CollectionReference to add a new user
    var user = FirebaseAuth.instance.currentUser;
    CollectionReference messages =
        FirebaseFirestore.instance.collection('Messages');
    //check if user exists and the account isn't already in use
    if (user != null) {
      return messages
          .add({
            'Date Time Posted': DateTime
                .now(), //insert function to grab time/date, format it, and convert it to string
            'MessageContent': content,
            //'Password': Pass
          })
          .then((value) => print("Message Added"))
          .catchError((error) => print("Failed to add user: $error"));
    } else {}
  }

  int mCount = 0;
  //unscalable method to track how many messages are in the db
  Future<int> messageCount() async {
    var count;
    FirebaseFirestore.instance
        .collection('Messages')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        count++;
      });
    });
    print("MESSAGE DB SIZE: " + count);
    return count;
  }

  int checkSize() {
    messageCount().then((int size) {
      setState(() {
        mCount = size;
      });
    });
    return mCount;
  }

  //adapted from https://stackoverflow.com/questions/54385713/how-to-display-list-from-firestore-in-an-item-builder
  /*Widget buildMessageList(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        // <2> Pass `Future<QuerySnapshot>` to future
        future: firestore.collection('Messages').get(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<DocumentSnapshot> documents = snapshot.data!.documents;
            return ListView(
                children: documents
                    .map((doc) => Card(
                          child: ListTile(
                            title: Text(doc['text']),
                            subtitle: Text(doc['email']),
                          ),
                        ))
                    .toList());
          } else {
            // Still loading
            return CircularProgressIndicator();
          }
        });
  }*/

  /*return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
                DocumentSnapshot message = snapshot.data.documents[index];

                return ListTile(
                    // Access the fields as defined in FireStore
                    title: Text(message.data['MessageContent']),
                    subtitle: Text(message.data['Date/Time Posted']),
                );
            },
        );
    } else if (snapshot.connectionState == ConnectionState.done && !snapshot.hasData 
    {
        // Handle no data
        return Center(
            child: Text("No Messages found."),
        );
    } else {
        // Still loading
        return CircularProgressIndicator();
    }*/

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('FandomApp'),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              //logout action here. Well... pop up asking if they want to log out. On ok press, logout and return to login screen
              onPressed: () {
                showDialog<String>(
                  //confirm user signout
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        //This is where it would navigate to the actual app's content
                        onPressed: () => {
                          auth.signOut(),
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst)
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: Text("Log Out"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],
        ),
        body: Center(
          child: StreamBuilder(
              stream: firestore
                  .collection('Messages')
                  .orderBy('Date Time Posted')
                  .snapshots(),
              //builder: buildMessageList,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  // <3> Retrieve `List<DocumentSnapshot>` from snapshot
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView(
                      children: documents
                          .map((doc) => Card(
                                child: ListTile(
                                    title: Text(doc['MessageContent']),
                                    subtitle: Text((doc['Date Time Posted']
                                        .toDate()
                                        .toString()))),
                              ))
                          .toList());
                } else {
                  return CircularProgressIndicator();
                }
              }),
        ),
        //),
        //check if user has admin status use function that returns value as String
        //if ( == "ADMIN")
        //{
        floatingActionButton: _createAB()
        //),
        );
  }
}
