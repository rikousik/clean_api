import 'package:flutter/material.dart';

import 'package:clean_api/clean_api.dart';
import 'package:fpdart/src/either.dart';

void main() {
  CleanApi.instance().setBaseUrl('https://catfact.ninja/');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Clean Api Example',
      home: MyHomePage(title: 'Clean Api Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = 'Press the button to load fact';
  final cleanApi = CleanApi.instance();
  void getCatFacts() async {
    setState(() {
      text = 'Loading';
    });
    final Either<ApiFailure, CatModel> response = await cleanApi.get(
        fromJson: (json) => CatModel.fromJson(json), endPoint: 'fact');

    setState(() {
      text = response.fold((l) => l.toString(), (r) => r.fact);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.green),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: getCatFacts,
          tooltip: 'Fetch api',
          child: const Icon(Icons
              .next_plan)), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class CatModel {
  final String fact;
  final int length;
  CatModel({
    required this.fact,
    required this.length,
  });

  CatModel copyWith({
    String? fact,
    int? length,
  }) {
    return CatModel(
      fact: fact ?? this.fact,
      length: length ?? this.length,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fact': fact,
      'length': length,
    };
  }

  factory CatModel.fromJson(Map<String, dynamic> map) {
    return CatModel(
      fact: map['fact'] ?? '',
      length: map['length']?.toInt() ?? 0,
    );
  }

  @override
  String toString() => 'CatModel(fact: $fact, length: $length)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CatModel && other.fact == fact && other.length == length;
  }

  @override
  int get hashCode => fact.hashCode ^ length.hashCode;
}
