// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:push_notification/demand_dto.dart';

class DemandPage extends StatefulWidget {
  final String? userUUID;
  final String? token;
  const DemandPage({this.userUUID, this.token, super.key});

  @override
  State<DemandPage> createState() => _DemandPageState();
}

class _DemandPageState extends State<DemandPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore database = FirebaseFirestore.instance;
  List<DemandDto> demands = [];

  void init() async {
    // database.collection('users').doc(auth.currentUser!.uid);

    final userDB = await database
        .collection('users')
        .doc(widget.userUUID)
        .collection('demand')
        .where('viewed', isEqualTo: false)
        .get();

    final docs = userDB.docs;
    docs.map((json) => demands.add(DemandDto.fromJson(json.data()))).toList();
    setState(() {});
    print(widget.token);
    print(demands);
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () => init(), icon: const Icon(Icons.refresh))
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SizedBox(
          child: ListView.builder(
            itemCount: demands.length,
            itemBuilder: (context, index) => MyCard(
              demand: demands[index],
              onTap: () async {
                await database
                    .collection('users')
                    .doc(auth.currentUser!.uid)
                    .collection('demand')
                    .doc(demands[index].id)
                    .update({'viewed': true});
                setState(() {
                  demands.removeWhere(
                      (element) => element.id == demands[index].id);
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MyCard extends StatelessWidget {
  final void Function()? onTap;
  final DemandDto? demand;
  const MyCard({this.onTap, this.demand, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            children: [
              Text('Pedido numero ${demand!.id} em aberto'),
              const Text('Clique para encerrar a notificacao'),
            ],
          ),
        ),
      ),
    );
  }
}
