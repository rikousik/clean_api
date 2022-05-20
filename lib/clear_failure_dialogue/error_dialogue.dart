import 'package:clean_api/clean_api.dart';
import 'package:flutter/material.dart';

import 'error_details_page.dart';

class ErrorDialogue extends StatelessWidget {
  final CleanFailure failure;
  const ErrorDialogue(this.failure, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      contentTextStyle: const TextStyle(color: Colors.black),
      titleTextStyle: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
      title: Row(
        children: [
          const Icon(
            Icons.error_outline_sharp,
            color: Colors.red,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            failure.tag,
            maxLines: 2,
          ),
        ],
      ),
      content: Text(
        failure.error,
        maxLines: 4,
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Ignore')),
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.green, shape: const StadiumBorder()),
            onPressed: () {
              Navigator.of(context).pop();

              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ErrorDetailsPage(failure: failure)));
            },
            child: const Text('View details'))
      ],
    );
  }

  static show(BuildContext context, {required CleanFailure failure}) {
    if (failure != CleanFailure.none()) {
      showDialog(
          context: context, builder: (context) => ErrorDialogue(failure));
    }
  }
}
