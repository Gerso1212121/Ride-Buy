import 'package:ezride/Feature/Home/HOME/home_screen_PRESENTATION.dart';
import 'package:ezride/flutter_flow/flutter_flow_model.dart';
import 'package:flutter/material.dart';

class HomeModel extends FlutterFlowModel<HomeScreen> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}