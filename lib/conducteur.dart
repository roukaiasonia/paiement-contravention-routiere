import 'package:app_contravention/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_contravention/payement.dart';
import 'package:app_contravention/recours.dart';

class ConducteurDetail extends StatelessWidget {
  final String conducteurId;

  const ConducteurDetail({super.key, required this.conducteurId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 58, 34, 238),
        title: const Text(
          'Profil du Conducteur',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirmation"),
                    content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                        },
                        child: const Text(
                          "Annuler",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Color.fromARGB(255, 58, 34, 238),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>  const MyApp(),
                            ),
                          );
                        },
                        child: const Text(
                          "Confirmer",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Color.fromARGB(255, 58, 34, 238),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            iconSize: 30,
            color: Colors.white,
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('conducteurs').doc(conducteurId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Erreur lors de la récupération des données : ${snapshot.error}"),
            );
          }

          if ( !snapshot.hasData||!snapshot.data!.exists) {
            return const Center(child: Text("Aucune donnée disponible"));
          }

          var data = snapshot.data!;
          String nom = data['nom'];
          String numeroPermis = data['numéro de permis'];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  margin: const EdgeInsets.all(4),
                  child: ListTile(
                    title: const Text(
                      'Nom du conducteur :',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      nom,
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.all(4),
                  child: ListTile(
                    title: const Text(
                      'Numéro de permis:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      numeroPermis,
                      style: const TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Listes des contraventions",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26.0,
                    color: Color.fromARGB(255, 58, 34, 238),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("contraventions")
                        .where("conducteurRef", isEqualTo: FirebaseFirestore.instance.collection('conducteurs').doc(conducteurId))
                        .snapshots(),
                    builder: (context, contraventionSnapshot) {
                      if (contraventionSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (contraventionSnapshot.hasError) {
                        return Center(
                          child: Text("Erreur : ${contraventionSnapshot.error}"),
                        );
                      }

                      if (contraventionSnapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("Aucune contravention trouvée"));
                      }

                      var contraventions = contraventionSnapshot.data!.docs;
                     
                      return ListView.builder(
                        itemCount: contraventions.length,
                        itemBuilder: (context, index) {
                          var contravention = contraventions[index];
                          Timestamp dateTimestamp = contravention['date'] as Timestamp;
                          DateTime date = dateTimestamp.toDate();

                          return Card(
                            child: ListTile(
                              title: Text(
                                "Numéro de contravention: ${contravention['numéro contravention']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ),
                              ),
                              subtitle: FutureBuilder<DocumentSnapshot>(
                                future: (contravention['véhiculeRef'] as DocumentReference).get(),
                                builder: (context, vehicleSnapshot) {
                                  if (vehicleSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Text("Chargement du véhicule...");
                                  }
                                  if (vehicleSnapshot.hasError) {
                                    return Text("Erreur: ${vehicleSnapshot.error}");
                                  }
                                  if (!vehicleSnapshot.hasData || !vehicleSnapshot.data!.exists) {
                                    return const Text("Véhicule non trouvé");
                                  }

                                  var vehicleData = vehicleSnapshot.data!;
                                  String matricule = vehicleData['matricule'];

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "La Contravention: ${contravention['contravention']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "Date : ${date.day}/${date.month}/${date.year}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "Lieu : ${contravention['lieu']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "Matricule de véhicule : $matricule",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        "Montant : ${contravention['montant']}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (!(contravention['payee'] as bool))
                                            TextButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => PaymentPage(
                                                      numeroContravention: contravention['numéro contravention'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.payment),
                                              label: const Text(
                                                "Payer",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.0,
                                                  color: Color.fromARGB(255, 58, 34, 238),
                                                ),
                                              ),
                                            ),
                                          if (!(contravention['payee'] as bool))
                                            TextButton.icon(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => RecoursPage(
                                                      numeroContravention: contravention['numéro contravention'],
                                                      nomdeeconducteur: data['nom'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.gavel),
                                              label: const Text(
                                                "Recours",
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  color: Color.fromARGB(255, 58, 34, 238),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if ((contravention['payee'] as bool))
                                    const Text(
                                      "Payée",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 22.0,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}