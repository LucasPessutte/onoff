import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

// import 'firebase_options.dart';

void main() async {
  runApp(const MyApp());

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: "teste-8ad40",
    options: DefaultFirebaseOptions.currentPlatform,
  ).whenComplete(() => print('Firebase Conectado'));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnOff IOT',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Color.fromRGBO(0, 0, 45, 1)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var mensagem = "";
  var ligado = false;
  var click;

  void toggleOnOff() async {
    FirebaseApp secondaryApp = Firebase.app('teste-8ad40');
    FirebaseDatabase database = FirebaseDatabase.instanceFor(app: secondaryApp);

    DatabaseReference ref = database.ref("lampada");

    DatabaseEvent event = await ref.once();

    if (event.snapshot.value == 1) {
      setState(() {
        click = 0;
      });
    } else {
      setState(() {
        click = 1;
      });
    }

    await ref.set(click);

    getEstado(click);
  }

  void getEstado(click) async {
    var estado;
    while (true) {
      FirebaseApp secondaryApp = Firebase.app('teste-8ad40');
      FirebaseDatabase database =
          FirebaseDatabase.instanceFor(app: secondaryApp);

      DatabaseReference refEst = database.ref("estado");

      DatabaseEvent eventEstado = await refEst.once();

      estado = eventEstado.snapshot.value;

      if (estado != null) {
        setState(() {
          ligado = estado == 1 ? true : false;
        });

        setState(() {
          if (estado == 1 && click == 1) {
            mensagem = "O aparelho está ligado!";
          } else if (estado == 0 && click == 1) {
            mensagem = "O aparelho está sendo ligado!";
          } else if (estado == 1 && click == 0) {
            mensagem = "O aparelho está sendo desligado!";
          } else {
            mensagem = "O aparelho está desligado!";
          }
        });
      }
    }
  }

  // setState(() {
  //   ligado = aux;
  // });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
      //title: Text(widget.title),
      //),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: toggleOnOff,
              child:
                  Icon(CupertinoIcons.power, color: Colors.white, size: 200.0),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(CircleBorder()),
                //padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                backgroundColor: MaterialStateProperty.all(ligado
                    ? Colors.blueAccent
                    : Colors.black38), // <-- Button color
                overlayColor:
                    MaterialStateProperty.resolveWith<Color?>((states) {
                  return states.contains(MaterialState.pressed) && ligado
                      ? Colors.blueAccent
                      : Colors.black38; // <-- Splash color
                }),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 50),
              child: Text(
                mensagem,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
