import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..get('/squeue', _squeueHandler)
  ..get('/squeue/<id>/stdout', _stdoutHandler)
  ..post('/scancel', _scancelHandler);

Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

Future<Response> _squeueHandler(Request request) async {
  final squeue = await Process.run('squeue', ['--json']);
  return Response.ok(squeue.stdout);
}

Future<Response> _stdoutHandler(Request request) async {
  final squeue = await Process.run('squeue', ['--json']);
  final List<dynamic> jobs = squeue.stdout['jobs'];
  final path = jobs.firstWhere((job) => job['job_id'] == request.params['id'])['standard_output'];
  final stdOut = await File(path).readAsString();
  return Response.ok(stdOut);
}

Future<Response> _scancelHandler(Request request) async {
  final scancel = await Process.run('scancel', [request.params['id'] ?? '']);
  return Response.ok(scancel.stdout);
}

void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.loopbackIPv4;

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '12420');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
