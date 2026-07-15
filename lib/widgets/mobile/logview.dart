import 'package:flutter/material.dart';
import 'package:lasertracker/core/api.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: FutureBuilder(
        future: fetchLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            final data = snapshot.data as List<dynamic>;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                DateTime dt = DateTime.fromMillisecondsSinceEpoch(
                  (data[index]["timestamp"] * 1000).round(),
                ).toLocal();
                String action = data[index]["action"];
                String username = data[index]["username"];
                return Text("[$dt] $username $action");
              },
            );
          }
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
    );
  }
}
