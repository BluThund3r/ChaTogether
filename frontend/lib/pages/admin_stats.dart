import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/custom_bar_cart.dart';
import 'package:frontend/components/toast.dart';
import 'package:frontend/interfaces/bar_chart_entry.dart';
import 'package:frontend/interfaces/stats.dart';
import 'package:frontend/services/admin_service.dart';
import 'package:provider/provider.dart';

class AdminStats extends StatefulWidget {
  const AdminStats({super.key});

  @override
  State<AdminStats> createState() => _AdminStatsState();
}

class _AdminStatsState extends State<AdminStats> {
  late AdminService adminService;
  bool viewCharts = false;
  List<Stats> stats = [];
  bool loaded = false;
  Map<int, String> monthMapping = <int, String>{
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December"
  };

  Map<int, String> monthShortMapping = <int, String>{
    1: "Jan",
    2: "Feb",
    3: "Mar",
    4: "Apr",
    5: "May",
    6: "Jun",
    7: "Jul",
    8: "Aug",
    9: "Sep",
    10: "Oct",
    11: "Nov",
    12: "Dec",
  };

  void fetchStats() async {
    var statsResponse = await adminService.getStats();

    if (statsResponse is String) {
      initFToast(context);
      showErrorToast("Failed to load statistics");
      return;
    }

    if (statsResponse is List<Stats>) {
      statsResponse.sort((a, b) {
        final yearCompareTo = a.year.compareTo(b.year);
        if (yearCompareTo != 0) {
          return yearCompareTo;
        }
        return a.month.compareTo(b.month);
      });

      setState(() {
        stats = statsResponse;
        loaded = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    adminService = Provider.of<AdminService>(context, listen: false);
    fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Statistics",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26.0,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: loaded
            ? stats.isNotEmpty
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() => viewCharts = false);
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                child: const Text("Data"),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() => viewCharts = true);
                                },
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side:
                                          const BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                child: const Text("Charts"),
                              ),
                            )
                          ],
                        ),
                      ),
                      if (!viewCharts)
                        Expanded(
                          child: ListView.builder(
                            itemCount: stats.length,
                            itemBuilder: (context, index) {
                              bool displayDivider = index != stats.length - 1;
                              final stat = stats[stats.length - index - 1];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        "${monthMapping[stat.month]} ${stat.year}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25.0,
                                        ),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, top: 5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "New Users: ",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    stat.newUsersCount
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  const Text(
                                                    "Video Rooms:",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    stat.videoRoomsCount
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              child: Row(
                                                children: [
                                                  const Text(
                                                    "Group Chats:",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    stat.groupChatsCount
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  const Text(
                                                    "Private Chats:",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    stat.privateChatsCount
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (displayDivider)
                                      const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Divider(
                                          thickness: 0.5,
                                          height: 1.0,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      if (viewCharts)
                        Expanded(
                          child: ListView(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "New users for the last 6 months",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 227, 227, 227),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  width: double.infinity,
                                  height: 400,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomBarChart(
                                      data: stats
                                          .map((stat) {
                                            return BarChartEntry(
                                              monthYear:
                                                  "${monthShortMapping[stat.month]} ${stat.year % 100}",
                                              data: stat.newUsersCount,
                                            );
                                          })
                                          .cast<BarChartEntry>()
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Group chats created in the last 6 months",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 227, 227, 227),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  width: double.infinity,
                                  height: 400,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomBarChart(
                                      data: stats
                                          .map((stat) {
                                            return BarChartEntry(
                                              monthYear:
                                                  "${monthShortMapping[stat.month]} ${stat.year % 100}",
                                              data: stat.groupChatsCount,
                                            );
                                          })
                                          .cast<BarChartEntry>()
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Private chats started in the last 6 months",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 227, 227, 227),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  width: double.infinity,
                                  height: 400,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomBarChart(
                                      data: stats
                                          .map((stat) {
                                            return BarChartEntry(
                                              monthYear:
                                                  "${monthShortMapping[stat.month]} ${stat.year % 100}",
                                              data: stat.privateChatsCount,
                                            );
                                          })
                                          .cast<BarChartEntry>()
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  "Video rooms created in the last 6 months",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 227, 227, 227),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  width: double.infinity,
                                  height: 400,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CustomBarChart(
                                      data: stats
                                          .map((stat) {
                                            return BarChartEntry(
                                              monthYear:
                                                  "${monthShortMapping[stat.month]} ${stat.year % 100}",
                                              data: stat.videoRoomsCount,
                                            );
                                          })
                                          .cast<BarChartEntry>()
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 150,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "No statistics for the last 6 months",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                        SizedBox(
                          height: 80,
                        ),
                      ],
                    ),
                  )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
