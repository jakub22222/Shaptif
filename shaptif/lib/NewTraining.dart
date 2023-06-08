import 'package:flutter/material.dart';
import 'package:shaptif/TrainingBuilder.dart';
import 'package:shaptif/db/database_manager.dart';
import 'package:shaptif/db/exercise.dart';
import 'package:shaptif/db/exercise_set.dart';
import 'package:shaptif/db/training.dart';


class NewTrainingView extends StatefulWidget {
  const NewTrainingView({this.trainings, Key? key}) : super(key: key);

  final List<Training>? trainings;
  @override
  State<StatefulWidget> createState() => NewTrainingViewState();
}

class NewTrainingViewState extends State<NewTrainingView> {

  bool isLoading = false;
  String trainingName = '';
  String descriptionName = '';
  List<Exercise> exercises = [];
  double firstWeight = 50.0;
  int firstSeries = 5;
  int firstRepetitions = 10;
  List<int> series = [];
  List<int> repetitions = [];
  List<double> weight = [];
  int number = 0;//number of series iteration
  late Training newTraining;

  @override
  void initState(){
    super.initState();
  }

  Future loadToDatabase() async{
    setState(() => isLoading = true);

    newTraining = await DatabaseManger.instance.insert(Training(
        name: trainingName,
        description: descriptionName,
        isEmbedded: false)) as Training;


    for(Exercise rm in exercises){
      for(int i=0; i<series[number]; i++){
        await DatabaseManger.instance.insert(ExerciseSet(
            trainingID: newTraining.id!,
            exerciseID: rm.id!,
            repetitions: repetitions[number],
            weight: weight[number]));
      }
      ++number;
    }

    widget.trainings?.add(newTraining);
    setState(() {
      widget.trainings;
    });

    Navigator.pop(context, newTraining.name);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index){
                  return Card(
                    //color: Colors.greenAccent,
                      child:Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text('${exercises.elementAt(index).name}'),
                              trailing: SizedBox(
                                width: 70,
                                height: 100,
                                child: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      exercises.remove(exercises.elementAt(index));
                                    });
                                  },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                Column(
                                  children: [
                                    Text('Serie'),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: (){
                                              setState(() => series[index]++);
                                            },
                                            icon: Icon(Icons.add)),
                                        Text('${series[index]}'),
                                        IconButton(
                                            onPressed: (){
                                              setState(() => series[index]--);
                                            },
                                            icon: Icon(Icons.remove)),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Powtórzenia'),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: (){
                                              setState(() => repetitions[index]++);
                                            },
                                            icon: Icon(Icons.add)),
                                        Text('${repetitions[index]}'),
                                        IconButton(
                                            onPressed: (){
                                              setState(() => repetitions[index]--);
                                            },
                                            icon: Icon(Icons.remove)),
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text('Ciężar'),
                                    Row(
                                      children: [
                                        IconButton(
                                            onPressed: (){
                                              setState(() => weight[index] = weight[index] + 5);
                                            },
                                            icon: Icon(Icons.add)),
                                        Text('${weight[index]}'),
                                        IconButton(
                                            onPressed: (){
                                              setState(() => weight[index] = weight[index] - 1.25);
                                            },
                                            icon: Icon(Icons.remove)),
                                      ],
                                    )
                                  ],
                                )
                            ]
                            ),
                          ],
                        )
                      )
                  );
                }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "AddExercise",
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrainingBuilderView())
              ).then((value){
                bool isSame = false;  //checks if Exercise is already in builder
                List<Exercise> givenValues = value;

                if(value != null){
                  for(Exercise rn in exercises){
                    for(Exercise ex in givenValues){
                      if(rn.name == ex.name){
                        isSame = true;
                      }
                    }
                  }

                  if(isSame == false){
                    setState(() {
                      for(Exercise ex in givenValues){
                        exercises.add(ex);
                        series.add(firstSeries);
                        weight.add(firstWeight);
                        repetitions.add(firstRepetitions);
                      }
                    });
                  }
                }
              });
            },
            shape: CircleBorder(),
            backgroundColor: Colors.green,
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
              heroTag: "SaveTraining",
              onPressed: (){
                if(exercises.length > 0){
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Nadaj nazwe'),
                        content: Wrap(
                          runSpacing: 8.0,
                            children:[
                              TextField(
                                maxLength: 20,
                                onChanged: (value){
                                  setState(() {
                                    trainingName = value;
                                  });
                                },
                                decoration:  InputDecoration(hintText: 'Nazwa treningu'),
                              ),
                              TextField(
                                maxLines : 5,
                                onChanged: (value){
                                  setState(() {
                                    descriptionName = value;
                                  });
                                },
                                decoration:  InputDecoration(
                                    hintText: 'Opis treningu'
                                ),
                              ),
                            ],
                          ),
                        actions: <Widget>[
                          TextButton(
                              onPressed: (){
                                loadToDatabase();
                                Navigator.pop(context);
                              },
                              child: const Text('OK')
                          )
                        ],
                      )
                  );
                }
                else{
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Trening musi mieć chociaż jedo ćwiczenie!'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: const Text('OK')
                          )
                        ],
                      )
                  );
                }
              },                  //onPressed end
            shape: CircleBorder(),
            backgroundColor: Colors.orangeAccent,
            child: Icon(Icons.save),
          )
        ],
      )
  );

  }


  Widget buildProgressIndicator(BuildContext context) {
    return const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(
          Colors.black,) //Color of indicator
    );
  }

}
