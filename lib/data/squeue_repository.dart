import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'package:flutter/services.dart' show rootBundle;

var log = Logger();

class SqueueDataProvider {
  final bool staticTest = true;
  Future<String> getSqueueOutputRaw() async {
    if (staticTest) {
      return rootBundle.loadString('assets/squeue.json');   
    } else {
      final url = Uri.http('localhost:12420', '/squeue');    
      return http.read(url);
    }
  }
}

class SqueueJob {
  final String name;
  final DateTime submitTime;

  SqueueJob(this.name, this.submitTime);

  SqueueJob.fromJson(dynamic json) : name = json['name'] as String,
    submitTime = DateTime.fromMillisecondsSinceEpoch(json['submit_time']['number'] * 1000);
  
  
  @override
  String toString() {
    return 'SqueueJob: {name: $name}';
  }
}

class SqueueRepository {
  final SqueueDataProvider squeue = SqueueDataProvider();

  Future<List<SqueueJob>> getSqueueJobs() async {
    final squeueRaw = await squeue.getSqueueOutputRaw();
    final jobs = jsonDecode(squeueRaw)['jobs'] as List<dynamic>;
    return jobs.map(SqueueJob.fromJson).toList();
  }
}
