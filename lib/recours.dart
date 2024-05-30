import 'package:flutter/material.dart';

class RecoursPage extends StatelessWidget {
  final String numeroContravention;
  final String nomdeeconducteur;

  RecoursPage({super.key, required this.numeroContravention ,required  this.nomdeeconducteur});


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor:const Color.fromARGB(255, 58, 34, 238),
        title: const Text("Demande de Recours",
        textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),
      ),
      body: SingleChildScrollView(
        child:  Padding(
        padding: const EdgeInsets.all(14.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                  margin: const EdgeInsets.all(0),
                  child: ListTile(
                    title: const Text(
                      'Numéro de contravention :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text("$numeroContravention", style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),),
                  ),
                ),
                const SizedBox(height:16,),
                Card(
                  margin: const EdgeInsets.all(0),
                  child: ListTile(
                    title: const Text(
                      'Nom du conducteur :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text("$nomdeeconducteur", style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),),
                  ),
                ),
              const SizedBox(height:10),
              const Text(
                "Pour contester cette contravention, veuillez compléter le formulaire ci-dessous en fournissant les détails de votre contravention.",
              textAlign:TextAlign.start,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),),
              const SizedBox(height:20),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Inscrire la demande de recours relative à la contravention .",
                  border: OutlineInputBorder(),
                ),
                maxLines:10,
                minLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un motif de recours";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Recours soumis avec succès!")),
                      );
                      Navigator.pop(context); 
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  child: const Text("Envoyer",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}