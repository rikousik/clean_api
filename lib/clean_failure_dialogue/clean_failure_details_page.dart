import 'package:clean_api/clean_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CleanFailureDetailsPage extends StatelessWidget {
  final CleanFailure failure;
  const CleanFailureDetailsPage({Key? key, required this.failure})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.red[100],
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 40,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Error',
                        style: TextStyle(fontSize: 40),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              visualDensity: VisualDensity.compact),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.arrow_left_circle,
                                  color: Colors.purple[900]),
                              Text('Go back',
                                  style: TextStyle(color: Colors.purple[900])),
                            ],
                          )),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  width: 2, color: Colors.purple[900]!),
                              shape: const StadiumBorder(),
                              visualDensity: VisualDensity.compact),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: failure.error));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Copied to Clipboard')));
                          },
                          child: Text('Copy code',
                              style: TextStyle(color: Colors.purple[900]))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    failure.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ]),
          ),
        ],
      ),
    );
  }
}
