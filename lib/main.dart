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

class JobPage extends StatelessWidget {
  final SqueueJob job;
  const JobPage(this.job, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JobCubit(SqueueRepository(), job),
      child: const JobView(),
    );
  }
}

class JobView extends StatelessWidget {
  const JobView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobCubit, SqueueJob>(builder: (context, state) {
      return Scaffold(
          appBar: AppBar(
            title: Text(state.name),
          ),
          body: ListView(
            children: <Widget>[
              Card(
                child: Text('Submitted: ${state.submitTime}'),
              ),
              Card(
                child: (state.startTime == null) ? const Text('not started') : Text('Started: ${state.startTime}'),
              ),
              Card(
                child: Text('Time limit: ${state.timeLimit}'),
              ),
              Card(
                child: Text('Nodes: ${state.nodes}'),
              ),
              Card(
                child: Text('Features: ${state.features}'),
              )
            ],
          ));
    });
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
          BlocBuilder<SqueueCubit, List<SqueueJob>>(builder: (context, state) {
        return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(state[index].jobId.toString()),
                onDismissed: (direction) {
                  context.read<SqueueCubit>().cancel(state[index].jobId);
                },
                child: ListTile(
                  title: Text(state[index].name),
                  trailing: Text(state[index].nodes),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => JobPage(state[index]))),
                ),
              );
            });
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<SqueueCubit>().fetch(),
        tooltip: 'Increment',
        child: const Icon(Icons.replay),
      ),
    );
  }
}
