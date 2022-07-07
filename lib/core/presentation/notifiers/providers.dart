import 'package:deelz/core/presentation/notifiers/auth_state.dart';
import 'package:deelz/core/presentation/notifiers/status_controller.dart';
import 'package:deelz/core/presentation/notifiers/transaction_state.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(
    create: (context) => AccountProvider(),
    lazy: false,
  ),
  ChangeNotifierProvider(
    create: (context) => TransactionState(),
    lazy: false,
  ),
  ChangeNotifierProvider(
    create: (context) => StatusController(),
    lazy: false,
  ),
];
