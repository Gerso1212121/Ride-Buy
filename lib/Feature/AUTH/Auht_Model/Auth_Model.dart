import 'package:flutter/material.dart';

class AuthModel extends ChangeNotifier {
// Agregar estas propiedades a tu AuthModel
  final otpTextControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> otpFocusNodes =
      List.generate(6, (index) => FocusNode());
  final otpFormKey = GlobalKey<FormState>();

  // State field(s) for TabBar widget.
  TabController? tabBarController;

  // State field(s) for emailAddress widget.
  late FocusNode emailAddressFocusNode;
  late TextEditingController emailAddressTextController;
  String? Function(String?)? emailAddressTextControllerValidator;

  // State field(s) for password widget.
  late FocusNode passwordFocusNode;
  late TextEditingController passwordTextController;
  late bool passwordVisibility;
  String? Function(String?)? passwordTextControllerValidator;

  // State field(s) for emailAddress_Create widget.
  late FocusNode emailAddressCreateFocusNode;
  late TextEditingController emailAddressCreateTextController;
  String? Function(String?)? emailAddressCreateTextControllerValidator;

  // State field(s) for password_Create widget.
  late FocusNode passwordCreateFocusNode;
  late TextEditingController passwordCreateTextController;
  late bool passwordCreateVisibility;
  String? Function(String?)? passwordCreateTextControllerValidator;

  // State field(s) for passwordConfirm widget.
  late FocusNode passwordConfirmFocusNode;
  late TextEditingController passwordConfirmTextController;
  late bool passwordConfirmVisibility;
  String? Function(String?)? passwordConfirmTextControllerValidator;

  AuthModel() {
    // Inicializar en el constructor
    passwordVisibility = false;
    passwordCreateVisibility = false;
    passwordConfirmVisibility = false;

    // Inicializar controllers y focus nodes
    _initializeControllers();
  }

  void _initializeControllers() {
    //Controladores de login
    emailAddressTextController = TextEditingController();
    emailAddressFocusNode = FocusNode();

    passwordTextController = TextEditingController();
    passwordFocusNode = FocusNode();

    //Controlador de registro.
    emailAddressCreateTextController = TextEditingController();
    emailAddressCreateFocusNode = FocusNode();

    passwordCreateTextController = TextEditingController();
    passwordCreateFocusNode = FocusNode();

    passwordConfirmTextController = TextEditingController();
    passwordConfirmFocusNode = FocusNode();
  }

  // Métodos para cambiar visibilidad
  void togglePasswordVisibility() {
    passwordVisibility = !passwordVisibility;
    notifyListeners();
  }

  void togglePasswordCreateVisibility() {
    passwordCreateVisibility = !passwordCreateVisibility;
    notifyListeners();
  }

  void togglePasswordConfirmVisibility() {
    passwordConfirmVisibility = !passwordConfirmVisibility;
    notifyListeners();
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    emailAddressFocusNode.dispose();
    emailAddressTextController.dispose();

    passwordFocusNode.dispose();
    passwordTextController.dispose();

    emailAddressCreateFocusNode.dispose();
    emailAddressCreateTextController.dispose();

    passwordCreateFocusNode.dispose();
    passwordCreateTextController.dispose();

    passwordConfirmFocusNode.dispose();
    passwordConfirmTextController.dispose();

    super.dispose();
  }
}
