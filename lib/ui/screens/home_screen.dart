import 'dart:async';
import 'dart:convert';
import 'package:timeago/timeago.dart' as timeago;

import 'package:rastreamento_encomendas/models/item_model.dart';
import 'package:rastreamento_encomendas/utils/datetime_utils.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:correiostracking/correios.dart';
import 'package:correiostracking/correiostracking.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../components/item_details_component.dart';
import '../components/new_item_component.dart';

import 'package:http/http.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ItemModel> data = [];
  final box = GetStorage();

  @override
  void initState() {
    super.initState();

    final packagesCache = box.read('packages');

    if (packagesCache != null) {
      final map = jsonDecode(packagesCache);

      map.forEach((element) {
        data.add(ItemModel.fromMap(element));
      });
    }

    if (data.isNotEmpty) {
      fetch();
    }
  }

  fetch() async {
    data.forEach((element) {
      CorreiosTracking.track(element.code).then((info) {
        if (info != null) {
          element.info = info;
          setState(() {});

          if (info.isEmpty) forceFetch(element);
        }
      });
    });
  }

  Future<void> singleFetch(ItemModel item) async {
    final info = await CorreiosTracking.track(item.code);

    if (info == null || info.isEmpty) {
      forceFetch(item);
    } else {
      item.info = info;
      setState(() {});
    }
  }

  forceFetch(ItemModel item) async {
    int tries = 0;

    Future.doWhile(() async {
      print("forceFetch(${item.title})");
      final info = await CorreiosTracking.track(item.code);

      if (info != null && info.isNotEmpty) {
        item.info = info;
        setState(() {});
      }

      if (item.info.isNotEmpty) {
        return false;
      }

      if (tries >= 3) {
        return false;
      }

      tries++;

      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      bottomSheet: GestureDetector(
        onTap: () {
          showFlexibleBottomSheet(
            minHeight: 0,
            initHeight: 0.5,
            maxHeight: 0.75,
            context: context,
            builder: (context, _, __) {
              return buildNewItemComponent(context, _, __, (ItemModel newItem) {
                data.add(newItem);
                setState(() {});
                singleFetch(newItem);
                final packages =
                    jsonEncode(data.map((e) => e.toMap()).toList());

                box.write('packages', packages);
              });
            },
            anchors: [0, 0.65, 1],
          );
        },

        child: Container(
          margin: const EdgeInsets.all(6).copyWith(bottom: 0),
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.black26,
                Colors.white38,
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.add_circle_outline,
              color: Color(0xFFC9E5FF),
            ),
          ),
        ),
      ),

      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child:Container(
            decoration: const BoxDecoration(
            image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover),
        ),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: fetch,
              child: Container(
                margin: const EdgeInsets.all(6).copyWith(top: 0),
                width: double.infinity,
                padding: const EdgeInsets.only(top: 35),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.white38,
                        Colors.black54,
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    )),
                child: Stack(children: [
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Image.asset(
                      "assets/truck.png",
                      width: 200,
                      color: Color(0xFFC9E5FF).withAlpha(35),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 80, left: 20),
                        child: Text(
                          "Rastreamento de encomendas",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w700),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, bottom: 40),
                        child: Text(
                          "Meus rastreamentos",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .textTheme
                                  .overline!
                                  .color!
                                  .withOpacity(.6)),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),

            RefreshIndicator(
              onRefresh: () async {
                await fetch();
              },
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              child: Container(
                margin: const EdgeInsets.all(6),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Color(0xFF242526),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    ...data
                        .map(
                          (e) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            onLongPress: () {
                              data.removeWhere(
                                  (element) => element.code == e.code);
                              final packages = jsonEncode(
                                  data.map((e) => e.toMap()).toList());

                              box.write('packages', packages);
                              setState(() {});
                            },
                            onTap: () {
                              showFlexibleBottomSheet(
                                minHeight: 0,
                                initHeight: 0.65,
                                maxHeight: 0.75,
                                context: context,
                                builder: (context, _, __) {
                                  return buildItemDetailsComponent(context, e);
                                },
                                anchors: [0, 0.65, 1],
                              );
                            },
                            visualDensity: VisualDensity.compact,
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFFC9E5FF),
                              foregroundColor: Color(0XFF6697c1),
                              child: Icon(Icons.earbuds_outlined),
                            ),
                            title: Text(
                              e.title,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              e.info.isEmpty
                                  ? "Obtendo informações, aguarde..."
                                  : "${e.info.first.location} - ${e.info.first.status}",
                              style: TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              e.info.isEmpty
                                  ? " "
                                  : timeago.format(
                                      parseDateTime(
                                          e.info.first.date, e.info.first.time),
                                      locale: 'pt_br'),
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList()
                  ],
                ),
              ),
            ),
            SizedBox(height: 5)
          ],
        ),
      ),
    ),
    );
  }
}
