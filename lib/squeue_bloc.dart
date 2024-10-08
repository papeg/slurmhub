import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'data/squeue_repository.dart';

var log = Logger();

class SqueueCubit extends Cubit<List<SqueueJob>> {
  final SqueueRepository repo;
  SqueueCubit(this.repo) : super(List.empty());
  
  void fetch() async => emit(await repo.getSqueueJobs());
  
  void cancel(int id) async {
    await repo.cancelJob(id);
    emit(await repo.getSqueueJobs());
  }
  
  @override
  void onChange(Change<List<SqueueJob>> change) {
    super.onChange(change);
    log.d(change);
  }
  
  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    log.e('$error, $stackTrace');
  }
}

class JobCubit extends Cubit<SqueueJob> {
  final SqueueRepository repo;
  final SqueueJob job; 
  JobCubit(this.repo, this.job) : super(job);
}