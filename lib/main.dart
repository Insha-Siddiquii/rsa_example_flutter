import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:pointycastle/asymmetric/api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String decryptedPin = "";
  final String originalPin = "1234";
  String encryptedPin = "";

  late RSAPublicKey publicKey;
  late RSAPrivateKey privateKey;
  late encrypt.Encrypter encrypter;
  late encrypt.Encrypted encrypted;

  @override
  void initState() {
    super.initState();
    encryptStart();
  }

  void encryptStart() async {
    String publicPem =
        await rootBundle.loadString("assets/key/db_public_key.pem");
    publicKey = encrypt.RSAKeyParser().parse(publicPem) as RSAPublicKey;

    String privatePem =
        await rootBundle.loadString("assets/key/db_private_key.pem");
    privateKey = encrypt.RSAKeyParser().parse(privatePem) as RSAPrivateKey;
    encrypter = encrypt.Encrypter(
        encrypt.RSA(publicKey: publicKey, privateKey: privateKey));
  }

  _encrypt() {
    encrypted = encrypter.encrypt(originalPin);
    setState(() {
      encryptedPin = encrypted.base64;
      print(encryptedPin);
    });
  }

  _decrypt() {
    final decrypted = encrypter.decrypt(encrypted);
    setState(() {
      decryptedPin = decrypted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSA Work'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Original PIN is: $originalPin',
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Encrypted PIN is: $encryptedPin',
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Decrypted PIN is: $decryptedPin',
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: _encrypt,
              child: const Text('Encrypt it'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: _decrypt,
              child: const Text('Decrypt it'),
            )
          ],
        ),
      ),
    );
  }
}
