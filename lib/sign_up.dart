import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'conducteur.dart';

class SignUppage extends StatefulWidget {
  const SignUppage({super.key});

  @override
  _Signpagestate createState() => _Signpagestate();
}

class _Signpagestate extends State<SignUppage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String conducteurNom = '';
  String permisNumero = '';
  Timestamp permisCreation = Timestamp.now();
  Timestamp permisFin = Timestamp.now();
  String permisType = '';
  String phoneNumber = '';
  String verificationId = '';
  String smsCode = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inscription:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 58, 34, 238),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nom de Conducteur',
                  hintText: 'Entrer votre nom et prénom',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  conducteurNom = value;
                },
              ),
              const SizedBox(height:10,),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Numéro de permis',
                  hintText: 'Entrer votre numéro de permis',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  permisNumero = value;
                },
              ),
              const SizedBox(height:10,),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _selectDate(context, true); 
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de création du permis',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          permisCreation.toDate().toString(), 
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height:10,),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _selectDate(context, false); 
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de fin du permis',
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          permisFin.toDate().toString(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height:10,),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Type de permis',
                  hintText: 'Entrer le type de permis',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  permisType = value;
                },
              ),
              const SizedBox(height:10,),
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

              TextButton(
                onPressed: () {
                  if (phoneNumber.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Veuillez entrer un numéro de téléphone"),
                      ),
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
                  fieldHeight: 35,
                  fieldWidth: 40,
                  activeFillColor: Colors.white,
                ),
              ),
              TextButton(
                onPressed: _signInWithPhone,
                child: const Text(
                  "S'incrire",
                  style: TextStyle(
                    fontSize: 22.0,
                    color: Color.fromARGB(255, 58, 34, 238),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;
      await FirebaseFirestore.instance.collection('conducteurs').add({
        'nom': conducteurNom,
        'numéro de permis': permisNumero,
        'date de création de permis': permisCreation,
        'date de fin de permis': permisFin,
        'type de permis': permisType,
        'numéro de téléphone': phoneNumber,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enregistrement réussi!")),
      );

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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          permisCreation = Timestamp.fromDate(picked); 
        } else {
          permisFin = Timestamp.fromDate(picked);
        }
      });
    }
  }
}