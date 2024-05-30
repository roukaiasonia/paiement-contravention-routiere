import 'package:app_contravention/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_contravention/conducteur.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String phoneNumber;
  late String verificationId;
  late String smsCode;

  @override
  void initState() {
    super.initState();
    phoneNumber = '';
    smsCode = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Connexion:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 58, 34, 238),
              ),
            ),
            const SizedBox(height: 10),
           IntlPhoneField( 
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: "Entrer votre numéro télephonique",
                
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              initialCountryCode: 'DZ',
              onChanged: (phone) {
                setState(() {
                  phoneNumber = phone.completeNumber;
                });
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                if (phoneNumber.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Veuillez entrer un numéro de téléphone")),
                  );
                  return;
                }
                _verifyPhone();
              },
              child: const Text(
                "Envoyer le code de vérification",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color.fromARGB(255, 58, 34, 238),
                ),
              ),
            ),
            const SizedBox(height: 10),
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (value) {
                smsCode = value;
              },
              onCompleted: (value) {
                smsCode = value;
              },
              keyboardType: TextInputType.number,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 60,
                activeFillColor: Colors.white,
              ),
            ),
            const SizedBox(height:10),
            TextButton(
              onPressed: () {
                if (smsCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Veuillez entrer le code de vérification")),
                  );
                  return;
                }
                _signInWithPhone();
              },
              child: const Text(
                "Se connecter",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Color.fromARGB(255, 58, 34, 238),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Vous n'avez pas de compte ?",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUppage(),
                      ),
                    );
                  },
                  child: const Text(
                    "Inscrivez-vous",
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 58, 34, 238),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    
    );
  }

  void _verifyPhone() {
    _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential); 
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.message}")),
        );
      },
      codeSent: (String id, int? resendToken) {
        verificationId = id; 
      },
      codeAutoRetrievalTimeout: (String id) {
        verificationId = id; 
      },
    );
  }

  void _signInWithPhone() async {
  try {
    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un numéro de téléphone")),
      );
      return;
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    User? user = userCredential.user;

    
    String? phone = user?.phoneNumber;
   
    var conducteurDoc = await FirebaseFirestore.instance
        .collection('conducteurs')
        .where('numéro de téléphone', isEqualTo: phone) 
        .get();

    String conducteurId = conducteurDoc.docs.isNotEmpty
        ? conducteurDoc.docs.first.id 
        : '';


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConducteurDetail(conducteurId: conducteurId), 
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur lors de la connexion : ${e.toString()}")),
    );
  }
}
}