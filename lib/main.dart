import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:slurmhub/squeue_bloc.dart';

import 'data/squeue_repository.dart';

var log = Logger();

void main() {
  runApp(const SlurmApp());
}

class SlurmApp extends StatelessWidget {
  const SlurmApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slurm Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SqueuePage(),
    );
  }
}

class SqueuePage extends StatelessWidget {
  const SqueuePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SqueueCubit(SqueueRepository()),
      child: const SqueueView(),
    );
  }
}
  
class SqueueView extends StatelessWidget {
  const SqueueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('squeue'),
      ),
      body: 
           BlocBuilder<SqueueCubit, List<SqueueJob>>(
              builder: (context, state) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(state[index].name),
                      trailing: Text(state[index].submitTime.toString()),
                    );
                  }
                );
              }
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<SqueueCubit>().fetch(),
        tooltip: 'Increment',
        child: const Icon(Icons.replay),
      ),
    );
  }
}