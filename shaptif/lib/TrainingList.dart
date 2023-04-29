import 'package:flutter/material.dart';
import 'package:shaptif/db/training.dart';
import 'package:shaptif/db/database_manager.dart';
import 'package:shaptif/db/set.dart';

class TrainingListView extends StatefulWidget {
  const TrainingListView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TrainingListViewState();
}

class TrainingListViewState extends State<TrainingListView> {

  late List<Training> trainings;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }
  Future _getData() async {
    setState(() => isLoading = true);
    trainings = await DatabaseManger.instance.selectAllTrainings();
    for(Training el in trainings)
    {
      await el.initExerciseMap();
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 31, 31, 33),
      body: isLoading ? notLoaded() :
      loaded(),
      floatingActionButton: FloatingActionButton(
        heroTag: "AddTrainingButton",
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Smack me!"),
              action: SnackBarAction(
                  label: "Fuck",
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  })));
        },
        backgroundColor: const Color.fromARGB(255, 58, 183, 89),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
  ListView loaded()
  {
    return ListView.builder(
      itemCount: trainings.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, List> mapa = trainings[index].exercisesMap;
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainings[index].name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(height: 8),
                Text(trainings[index].description, style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                for (String klucz in mapa.keys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(klucz, style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      for (MySet singleSet in mapa[klucz]!)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Powtórzenia: ${singleSet.repetitions}", style: TextStyle(fontSize: 16)),
                            Text("Ciężar: ${singleSet.weight}", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      SizedBox(height: 16),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
  Text notLoaded()
  {
    return const Text("ładuje sie",
      style: TextStyle(
          fontFamily: 'Audiowide',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20),
    );
  }
}

