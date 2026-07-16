import 'package:flutter/material.dart';
import 'package:lasertracker/core/api.dart';

class DesktopLogView extends StatefulWidget {
  const DesktopLogView({super.key});

  @override
  State<DesktopLogView> createState() => _DesktopLogViewState();
}

class _DesktopLogViewState extends State<DesktopLogView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: getLogs(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error fetching logs"));
              }
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                final data = snapshot.data as List<dynamic>;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    DateTime dt = DateTime.fromMillisecondsSinceEpoch((data[index]["timestamp"] * 1000).round()).toLocal();
                    String action = data[index]["action"];
                    String username = data[index]["username"];
                    return Text("[$dt] $username $action");
                  },
                );
              }
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
