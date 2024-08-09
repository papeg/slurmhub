import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'package:flutter/services.dart' show rootBundle;

var log = Logger();

class SqueueDataProvider {
  final endpoint = 'localhost:12420';
  Future<String> getSqueueOutputRaw() async {
    return rootBundle.loadString('assets/squeue.json');
    /*
    final url = Uri.http(endpoint, '/squeue');
    return http.read(url);
    */
  }

  Future<http.Response> cancelJob(int id) async {
    final url = Uri.http(endpoint, '/scancel', {'id': id.toString()});
    return http.post(url);
  }
}

class SqueueJob {
  final int jobId;
  final String name;
  final DateTime submitTime;
  final DateTime? startTime;
  final int timeLimit;
  final String standardOutput;
  final String standardError;
  final String features;
  final String nodes;

  SqueueJob(this.jobId, this.name, this.submitTime, this.startTime,
      this.timeLimit, this.standardOutput, this.standardError, this.features, this.nodes);

  SqueueJob.fromJson(dynamic json)
      : jobId = json['job_id'] as int,
        name = json['name'] as String,
        timeLimit = json['time_limit']['number'] as int,
        submitTime = DateTime.fromMillisecondsSinceEpoch(
            json['submit_time']['number'] * 1000),
        startTime = json['start_time']['number'] != 0
            ? DateTime.fromMillisecondsSinceEpoch(
                json['start_time']['number'] * 1000)
            : null,
        standardOutput = json['standard_output'] as String,
        standardError = json['standard_error'] as String,
        features = json['features'] as String,
        nodes = json['nodes'] as String;

  @override
  String toString() {
    return 'SqueueJob: {jobId: $jobId, name: $name, submitTime: $submitTime}';
  }
}

class SqueueRepository {
  final SqueueDataProvider squeue = SqueueDataProvider();

  Future<List<SqueueJob>> getSqueueJobs() async {
    final squeueRaw = await squeue.getSqueueOutputRaw();
    final jobs = jsonDecode(squeueRaw)['jobs'] as List<dynamic>;
    return jobs.map(SqueueJob.fromJson).toList();
  }

  Future<String> cancelJob(int id) async {
    return (await squeue.cancelJob(id)).body;
  }
}
