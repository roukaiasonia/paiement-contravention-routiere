import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String numeroContravention;

  const PaymentPage({Key? key, required this.numeroContravention}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedCardType;
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expiryDateController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> processPayment() async {
   
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('contraventions')
          .where('numéro contravention', isEqualTo: widget.numeroContravention)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;

        await _firestore.collection('contraventions').doc(docId).update({
          'payee': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement effectué avec succès.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contravention non trouvée.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du traitement du paiement.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 58, 34, 238),
        title: const Text(
          'Payer En ligne',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Numéro de contravention: ${widget.numeroContravention}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sélectionner le type de carte :',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10,),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCardType = 'd\'or';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedCardType == 'd\'or' ? Colors.blue : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.credit_card),
                          Text('Carte D\'or'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCardType = 'Bancaire';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedCardType == 'Bancaire' ? Colors.blue : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.credit_card),
                          Text('Carte Bancaire'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Numéro de carte:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                maxLength: 16,
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Entrer le numéro de votre carte',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Date d\'expiration :',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                maxLength: 5,
                controller: expiryDateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  hintText: 'MM/AAAA',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'CVV:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                maxLength: 3,
                controller: cvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Entrer le CVV',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    const Color.fromARGB(255, 58, 34, 238),
                  ),
                ),
                onPressed: () {
                  if (selectedCardType != null &&
                      cardNumberController.text.isNotEmpty &&
                      expiryDateController.text.isNotEmpty &&
                      cvvController.text.isNotEmpty) {
                    processPayment();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paiement effectué avec succès!'),
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez remplir tous les champs.'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Payez Maintenant',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


  
  

