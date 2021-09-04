import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_remote/remote_config_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late RemoteConfigService remoteService;

  @override
  void initState() {
    super.initState();
    remoteService = RemoteConfigService();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
          future: remoteService.setRemoteConfig(),
          builder: (context, AsyncSnapshot<RemoteConfig> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: CircularProgressIndicator(color: Colors.red),
              );
            }
            if (snapshot.hasData) {
              return HomePage(snapshot.requireData, remoteService);
            }
            return ErrorPage(remoteService.fetchingErrorStream);
          }),
    );
  }
}

class ErrorPage extends StatelessWidget {
  final Stream<dynamic> error;

  ErrorPage(this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Error: ${error.last}')));
  }
}

class HomePage extends StatelessWidget {
  final RemoteConfig remoteConfigData;
  final RemoteConfigService remoteService;

  HomePage(this.remoteConfigData, this.remoteService);

  double get size =>
      jsonDecode(remoteConfigData.getString('mainScreen'))['iconSize']
          .toDouble();

  String get title =>
      jsonDecode(remoteConfigData.getString('mainScreen'))['title'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          'The button will show depends on remote config',
          style: TextStyle(
            fontSize: size,
          ),
        ),
      ),
      floatingActionButton: remoteConfigData.getBool('showModal')
          ? FloatingActionButton(
              onPressed: () async {
                await remoteService.onForceFetched(remoteConfigData);
              },
              child: Icon(Icons.download, size: size),
            )
          : null,
    );
  }
}
