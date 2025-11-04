import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';

class FormularioEmpresaModel extends FlutterFlowModel {
  // Global form key
  final formKey = GlobalKey<FormState>();

  // Nombre empresa
  TextEditingController? textController1;
  FocusNode? textFieldFocusNode1;

  // NIT
  TextEditingController? textController2;
  FocusNode? textFieldFocusNode2;

  // Dirección
  TextEditingController? textController3;
  FocusNode? textFieldFocusNode3;

  // (No usas textController4 aquí pero lo dejo por si luego agregas algo)
  TextEditingController? textController4;
  FocusNode? textFieldFocusNode4;

  // Teléfono empresa
  TextEditingController? textController5;
  FocusNode? textFieldFocusNode5;

  // Email empresa (opcional)
  TextEditingController? textController6;
  FocusNode? textFieldFocusNode6;

  // Dropdown Tipo Empresa
  String? dropDownValue;
  FormFieldController<String>? dropDownValueController;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textController1?.dispose();
    textFieldFocusNode1?.dispose();

    textController2?.dispose();
    textFieldFocusNode2?.dispose();

    textController3?.dispose();
    textFieldFocusNode3?.dispose();

    textController4?.dispose();
    textFieldFocusNode4?.dispose();

    textController5?.dispose();
    textFieldFocusNode5?.dispose();

    textController6?.dispose();
    textFieldFocusNode6?.dispose();
  }
}
