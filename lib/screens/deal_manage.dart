// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/res/app_constants.dart';
import 'package:deelz/data/model/deal.dart';
import 'package:deelz/data/model/status.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:flutter/scheduler.dart';

class DealManage extends StatefulWidget {
  Deal? deal;
  DealManage({
    Key? key,
    this.deal,
  }) : super(key: key);

  @override
  _DealManageState createState() => _DealManageState();
}

class _DealManageState extends State<DealManage>
    with SingleTickerProviderStateMixin {
  //pageview and tabController syncing
  late TabController _tabController;
  late PageController pageController = PageController();
  final _tabPageIndicator = StreamController<int>.broadcast();
  Stream<int> get getTabPage => _tabPageIndicator.stream;
  late StateSetter internalSetter;
  int tabIndex = 1;
  int pageIndex = 0;
  List<Widget> _pages = [];

//database stuff
  late final Client client;
  final itemsCollection = '620c468c8abb282a6478';
  late final Databases database;
  final User _user = AccountProvider().current!;
  List<Status> statuses = [];

  late RealtimeSubscription? authLiveChanges;
  //form field controllers
  final TextEditingController _ctlCustomerName = TextEditingController();
  final TextEditingController _ctlAddress = TextEditingController();
  final TextEditingController _ctlPhone = TextEditingController();
  final TextEditingController _ctlClaimNo = TextEditingController();
  //these require more than a textfield.
  final TextEditingController _ctlSignedDate = TextEditingController();
  TextEditingController _ctlPaDate = TextEditingController();
  final TextEditingController _ctlAdjustersDate = TextEditingController();

  get _percent => 1; //todo: use value from API object
  //GUI control
  bool _editMode = false;
  @override
  void initState() {
    super.initState();

    initFields();
    /*  _pages = [
      SizedBox(height: 50, child: Container()),
      SizedBox(height: 50, child: Container()),
      // SpinKitChasingDots(color: Colors.white, duration: Duration(seconds: 1)),
      buildInsurancePage(),
      // builPaymentsPage(),
    ]; */
    _pages = [
      buildGeneralPage(),
      buildInsurancePage(),
      builPaymentsPage(),
    ];
    _tabController = TabController(length: _pages.length, vsync: this);
    Future.delayed(Duration(milliseconds: 326), (() {
      _tabPageIndicator.sink.add(_tabController.index + 1);
    }));

    // WidgetsBinding.instance!.addPostFrameCallback((_) => onLoad(context));
    // SchedulerBinding.instance!.addPostFrameCallback((_) => onLoad(context));
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(widget);
    if (oldWidget != widget.deal) {
      initFields();
    }
  }

  onLoad(BuildContext context) async {
    print('widgetsbinding called: onLoad');
    // _tabPageIndicator.sink.add(_tabController.index + 1);

    Future.delayed(Duration(milliseconds: 100), (() async {
      _tabController.animateTo(1);
      navigation(true);
    })).then((value) => Future.delayed(Duration(milliseconds: 300), (() async {
          subscribe();
          _tabController.animateTo(0);
          navigation(true);
          setState(() {
            _pages = [
              buildGeneralPage(),
              buildInsurancePage(),
              builPaymentsPage(),
            ];
          });
          // await _updateDeal();
        })));
    /* internalSetter.call(
      () {
        _tabPageIndicator.sink.add(_tabController.index + 1);
      },
    ); */
  }

  Future initFields() async {
    print('calling initfields');
    final lookupStatus =
        await database.listDocuments(collectionId: '6228257b71958b88af7c');
    statuses = List<Document>.from(lookupStatus.documents)
        .map((e) => Status.fromMap(e.data))
        .toList();
    try {
      if (widget.deal!.id != null) {
        _ctlCustomerName.text = widget.deal!.customerName;
        _ctlAddress.text = widget.deal!.address;
        _ctlPhone.text = widget.deal!.phone;
        _ctlSignedDate.text = widget.deal!.signedDate.toString();
        _ctlPaDate.text = widget.deal!.paDate.toString();

        // print("signed on epoch ${widget.deal!.signedDate.toString()}");
        //declared as List<Status>=[];
        //set the status for the loaded deal.

        widget.deal!.statusId = statuses
            .firstWhere((item) => item.id!.contains(widget.deal!.statusId.id!));
      }
      //let the pages know we good
    } on Exception catch (e) {
      // TODO
    }
  }

  void subscribe() async {
    final realtime = Realtime(client);

    authLiveChanges =
        realtime.subscribe(['collections.$itemsCollection.documents']);
    authLiveChanges!.stream.listen((data) {
      if (data.payload.isNotEmpty) {
        for (var i = 0; i < data.events.length; i++) {
          if (data.events.contains("database.documents.create")) {
          } else if (data.events.contains("database.documents.delete")) {
          } else if (data.events.contains("database.documents.update")) {
            var item = data.payload;
            // print(item['ststus']);
            //!atempting to update list item
            //TODO! set permission here too
            widget.deal = Deal(
              id: item['\$id'],
              statusId: statuses
                  .firstWhere((lstItem) => lstItem.id == item['ststus']),

              /* statusId: statuses.firstWhere(
                    (element) => data.payload['ststus'] == element.id), */
              customerName: item['cust_name'],
              address: item['address'],
              phone: item['phone'],
              signedDate: int.parse(item['signed_date']!.toString()),
              paDate: item['pa_date']!,
              adjusterDate: item['adjusters_date'],
              claimNo: item['claim_no'],
              carrierId: item['carrier_id'],
              salesRepId: item['sales_rep_id'],
            );
            widget.deal = Deal.fromJson(item);
          }
        }

        //end swithc
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    pageController.dispose();
    _tabPageIndicator.close();
    authLiveChanges!.close();
    super.dispose();
  }

  //page scroll controls tabController
  onPageChange(int index) {
    debugPrint("page num $index");
    _tabController.animateTo(
      index % 3,
      duration: const Duration(milliseconds: 400),
      curve: Curves.ease,
    );

    _tabPageIndicator.sink.add(_tabController.index + 1);
    setState(() {});
  }

  void navigation(bool isTopController) {
    //skip 1st build
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      int mainTabBarIndex = _tabController.index;
      int pageIndex = pageController.page!.toInt();

      debugPrint("main $mainTabBarIndex top $pageIndex");

      pageController.animateToPage(
        mainTabBarIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
      setState(() {});
    });
  }

  final _formKeyGeneral = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final TextStyle moneyHeader1 = TextStyle(fontWeight: FontWeight.bold);
    final TextStyle moneyHeader2 = TextStyle(fontSize: 16);

    return SafeArea(
        child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          onPressed: () {
            switch (_tabController.index) {
              case 0:
                print("save tab 0 info");
                _updateDeal();
                setState(() {
                  _editMode = false;
                });

                break;
              default:
            }
          },
        ),
        // backgroundColor: Colors.grey[200],
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Future.delayed(Duration(seconds: 1), () {
                  setState(() {});
                  Navigator.pop(context);
                });
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('Async progress'),
                          content: Column(
                            children: [
                              LinearProgressIndicator(),
                              Text(
                                DateFormat.yMMMEd().format(
                                  DateTime.fromMillisecondsSinceEpoch(int.parse(
                                      "${widget.deal!.paDate.toString()}")),
                                ),
                              ),
                            ],
                          ),
                        ));
              },
              icon: Icon(Icons.replay_outlined),
            ),
            IconButton(
                onPressed: () => AccountProvider().logout(),
                icon: Icon(Icons.logout)),
          ],
          title: Text((widget.deal != null ? widget.deal!.customerName : 'n/a'),
              style: TextStyle(
                  fontFamily: GoogleFonts.aleo().toString(), fontSize: 17)),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildMoneyTracker(moneyHeader1, moneyHeader2),
            const SizedBox(height: 13),
            TabBar(
              labelColor: Colors.yellow,
              unselectedLabelColor: Colors.white,
              controller: _tabController,
              onTap: (_) {
                navigation(true);
              },
              tabs: [
                Tab(
                    icon: Text(
                  'General',
                  style: TextStyle(fontSize: 17),
                )),
                Tab(
                    icon: Text(
                  'Insurance',
                  style: TextStyle(fontSize: 17),
                )),
                Tab(
                    icon: Text(
                  'Payments',
                  style: TextStyle(fontSize: 17),
                )),
              ],
            ),
            /*  Expanded(
              child: IndexedStack(index: currentTabIndex, children: _pages),
            ), */
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: onPageChange,
                children: _pages,
              ),
            )
          ],
        ),
      ),
    ));
  }

  Wrap buildNotesList() {
    return Wrap(
      children: List.generate(
        1,
        (index) => Card(
            elevation: 7,
            child: ListTile(
              dense: true,
              leading: Icon(Icons.person_outline),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              // tileColor: Colors.indigo,

              title: Text(
                'User Name',
                // style: Theme.of(context).textTheme.caption,
              ),
              subtitle: Text(
                'New Message ${index + 1}',
                //  style: TextStyle(color: Colors.black),
              ),
              trailing: Column(children: [
                Text(
                  '25 days ago',
                  //style: Theme.of(context).textTheme.bodySmall,
                ),
                Icon(Icons.reply)
              ]),
            )
            // topShadowColor: Colors.indigo,
            // bottomShadowColor: Colors.indigo.shade300),
            ),
      ).toList(),
    );
  }

  Container buildMoneyTracker(TextStyle moneyHeader1, TextStyle moneyHeader2) {
    return Container(
      padding: EdgeInsets.all(8),
      height: 100.0,
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(blurRadius: 12)],
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(29), bottomRight: Radius.circular(29)),
        color: AppConstants.kcSecondary,
      ),
      child: Row(children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Contract Amount', style: moneyHeader1),
              const SizedBox(height: 9),
              Text(
                '\$14,000.00',
                style: moneyHeader2,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // progress
                Expanded(
                    // flex: 23,
                    child: ClipRRect(
                  child: Container(
                    padding: EdgeInsets.all(3),
                    // color: Colors.white,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(0)),
                    // borderRadius: BorderRadius.circular(22.0),
                    clipBehavior: Clip.antiAlias,
                    child: LinearPercentIndicator(
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      animationDuration: 200,
                      center: _percent == 1
                          ? Icon(Icons.money)
                          : Icon(Icons.hourglass_bottom_outlined,
                              color: Colors.white),
                      width: 124.0,
                      lineHeight: 23.0,
                      percent: 1,
                      backgroundColor: Colors.white,
                      progressColor: Colors.teal[400],
                    ),
                  ),
                )),
                Text(
                  'Deductible',
                  style: Theme.of(context)
                      .textTheme
                      .caption!
                      .copyWith(color: Colors.black, fontSize: 14),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '\$1,000.00',
                      style: moneyHeader2,
                    ),
                    Icon(Icons.check_circle, color: Colors.white),
                  ],
                ),
                widget.deal != null
                    ? Text(widget.deal!.statusId.status!, style: moneyHeader1)
                    : Container()
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Received', style: moneyHeader1),
              const SizedBox(height: 9),
              Text('\$6,000.00', style: moneyHeader2),
            ],
          ),
        ),
      ]),
    );
  }

  Widget buildGeneralPage() {
    return StreamBuilder<int>(
        stream: getTabPage,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            tabIndex = snapshot.data!;
          }

          return StatefulBuilder(builder: (context, setter) {
            internalSetter = setter;
            getTabPage.listen((event) {
              print("${event} was added to the stream");
            });

            print(snapshot.connectionState.name);
            return Container(
              height: double.infinity,
              color: Colors.white,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 7, right: 7),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKeyGeneral,
                      child: Column(
                        children: [
                          TextFormField(
                              decoration: InputDecoration(
                                label: Text('Customer Name'),
                                enabled: _editMode,
                              ),
                              controller: _ctlCustomerName,
                              validator: (value) {
                                if (value!.length <= 3) {
                                  return 'Enter a name';
                                }
                              }),
                          TextFormField(
                              controller: _ctlAddress,
                              keyboardType: TextInputType.streetAddress,
                              enabled: _editMode,
                              decoration: InputDecoration(
                                label: Text('Address'),
                              ),
                              validator: (value) {
                                if (value!.length <= 5) {
                                  return 'Enter a valid address';
                                }
                              }),
                          TextFormField(
                              controller: _ctlPhone,
                              keyboardType: TextInputType.phone,
                              enabled: _editMode,
                              decoration: InputDecoration(
                                label: Text('Phone'),
                              ),
                              validator: (value) {
                                if (value!.length <= 5) {
                                  return 'Enter a valid phone number';
                                }
                              }),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Pa Signed'),
                              Text(widget.deal!.paDate == null
                                  ? ''
                                  : '${widget.deal!.paDate}'),
                              Text('Adjustment'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // -------------------------------------------- Date when PA signed
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await pickDate(context, _ctlPaDate);
                                  setState;
                                },
                                icon: Icon(Icons.support_agent),
                                label: _ctlPaDate.text.isNotEmpty
                                    ? Text(
                                        DateFormat.yMMMd().format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(_ctlPaDate.text),
                                          ),
                                        ),
                                        style: TextStyle(fontSize: 13))
                                    : Text('N/A'),
                              ),
                              TextButton(
                                  onPressed: () {
                                    print("Pa Date is ${_ctlPaDate.text}");
                                    setState;
                                    setState(() {});
                                  },
                                  child: Text('pa date is?'))
                              /* ElevatedButton.icon(
                                onPressed: () async {
                                  pickDate(context);
                                  setState(() {
                                    _pages[0] = buildGeneralPage();
                                  });
                                },
                                icon: Icon(Icons.calendar_month_outlined),
                                label: Text(
                                    DateFormat.yMMMd().format(
                                      DateTime.fromMillisecondsSinceEpoch(int.parse(
                                          "${widget.deal!.signedDate.toString()}")),
                                    ),
                                    style: TextStyle(fontSize: 13)),
                              ), */
                            ],
                          ),
                          /* ElevatedButton.icon(
                            onPressed: () async {
                              pickDate(context);
                              setState(() {
                                _pages[0] = buildGeneralPage();
                              });
                            },
                            icon: Icon(Icons.calendar_month_outlined),
                            label: Text(
                              DateFormat.yMMMd().format(
                                DateTime.fromMillisecondsSinceEpoch(int.parse(
                                    "${widget.deal!.signedDate.toString()}")),
                              ),
                            ),
                          ), */
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(9),
                      alignment: Alignment.topLeft,
                      decoration: BoxDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Customer Info',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),

                                  /*  Text(widget.deal.customerName),
                                  Text(widget.deal.address),
                                  Text(widget.deal.phone), */
                                  // Text('Phone 1'),
                                ],
                              ),
                              Spacer(),
                              Column(
                                // mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _editMode
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            if (_editMode) {
                                              //validate
                                              if (_formKeyGeneral.currentState!
                                                  .validate()) {
                                                await _updateDeal();

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text('Saved')),
                                                );
                                              }
                                            }
                                          },
                                          child: Text('save'),
                                        )
                                      : Container(),
                                  Text(
                                    _editMode.toString(),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      setState(() {
                                        _editMode = !_editMode;
                                        _tabPageIndicator.sink
                                            .add(_tabController.index + 1);

                                        print("Edit mode is ${_editMode}");
                                      });
                                    },
                                    icon: Icon(
                                      _editMode
                                          ? Icons.lock_open_outlined
                                          : Icons.lock_outline,
                                      color:
                                          _editMode ? Colors.white : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text('Activity'), buildNotesList()],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  Widget buildInsurancePage() {
    return StatefulBuilder(
      builder: (context, setState) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Carrier',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text('Claim No.'),
                        Text('Deductible'),
                        Text('Date of Loss'),
                        Text('Adjustment Date'),
                      ],
                    ),
                    Spacer(),
                    Column(
                      children: [
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ))
                      ],
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [buildNotesList()],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget builPaymentsPage() {
    return Container(
      color: Colors.white,
    );
  }

  //db functions
  Future _updateDeal() async {
    // authLiveChanges!.close();
    try {
      await database.updateDocument(
        documentId: widget.deal!.id!,
        collectionId: itemsCollection,
        data: {
          'cust_name': _ctlCustomerName.text.trim(),
          'address': _ctlAddress.text.trim(),
          'phone': _ctlPhone.text.trim(),

          'signed_date': int.parse(
              _ctlSignedDate.text), // DateTime.now().millisecondsSinceEpoch,
          'pa_date': int.parse(_ctlPaDate.text)
          // 'ststus': currentItemStatus
        },
        read: [
          ///! use this when payload create
          'user:${_user.$id}',
          'team:620c6e12b9278e4aa747'
          // 'team:' + teams.list().
        ],
        write: ['user:${_user.$id}'],
        // documentId: 'unique()',
      );
      _tabPageIndicator.sink.add(_tabController.index + 1);

      setState(() {
        _editMode = false;
      });

      // widget.deal = null;
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  Future pickDate(
      BuildContext context, TextEditingController controller) async {
    DateTime initialDate =
        DateTime.fromMillisecondsSinceEpoch(int.parse(controller.text));

    if (controller.text.isEmpty) {
      initialDate = DateTime.now();
    }
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (newDate == null) return;

    setState(() {
      controller.text = newDate.millisecondsSinceEpoch.toString();
    });

    /* return database.updateDocument(
        collectionId: itemsCollection,
        documentId: widget.deal!.id!,
        data: {'signed_date': newDate.millisecondsSinceEpoch}); */

    print(_ctlSignedDate.text);
  }
}
