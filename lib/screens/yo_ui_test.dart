import 'package:flutter/material.dart';
import 'package:yo_ui/yo_ui.dart';

class YoUiTest extends StatefulWidget {
  YoUiTest({Key? key}) : super(key: key);

  @override
  State<YoUiTest> createState() => _YoUiTestState();
}

class _YoUiTestState extends State<YoUiTest> {
  TextEditingController controller = TextEditingController();

  late bool _ispasswordField;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ispasswordField = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff366CF6),
        appBar: AppBar(
          title: const YoText.headingThree('Yo UI Widget Showcase'),
        ),
        body: ListView(
          children: [
            YoText.headingOne('Design System'),
            const VerticalSpaceSmall(),
            Divider(),
            const VerticalSpaceSmall(),
            ...inputFields,
            ...buttonWidgets,
          ],
        ));
  }

// this is outside of main widget build
  List<Widget> get inputFields => [
        YoText.headline('Input Fields'),
        YoInputField(
          controller: controller,
          placeholder: 'Enter Password',
        ),
        YoInputField(
          controller: controller,
          trailing: Icon(Icons.lock),
          placeholder: 'Enter Password',
          password: _ispasswordField,
          trailingTapped: () {
            setState(() {
              _ispasswordField != _ispasswordField;
              print(_ispasswordField);
            });
          },
        ),
      ];

  List<Widget> get buttonWidgets => [
        YoText.headline('Buttons'),
        VerticalSpaceSmall(),
        YoText.body('Normal', color: kcLightGreyColor),
        VerticalSpaceSmall(),
        YoButton(
          title: 'SIGN IN',
        ),
        VerticalSpaceSmall(),
        YoText.body('Disabled', color: kcLightGreyColor),
        VerticalSpaceSmall(),
        YoButton(
          title: 'SIGN IN',
          disabled: true,
        ),
        VerticalSpaceSmall(),
        YoText.body('Busy', color: kcLightGreyColor),
        VerticalSpaceSmall(),
        YoButton(
          title: 'SIGN IN',
          busy: true,
        ),
        VerticalSpaceSmall(),
        YoText.body('Outline', color: kcLightGreyColor),
        VerticalSpaceSmall(),
        YoButton.outline(
          title: 'Select location',
          leading: Icon(
            Icons.send,
            color: kcPrimaryColor,
          ),
        ),
        VerticalSpaceSmall(),
      ];
}
