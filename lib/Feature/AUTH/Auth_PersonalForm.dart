import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalDataForm extends StatefulWidget {
  final VoidCallback onSavePressed;
  final VoidCallback onCancelPressed;

  const PersonalDataForm({
    super.key,
    required this.onSavePressed,
    required this.onCancelPressed,
  });

  @override
  State<PersonalDataForm> createState() => _PersonalDataFormState();
}

class _PersonalDataFormState extends State<PersonalDataForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos de texto
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _duiController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  
  // Focus nodes
  final FocusNode _fullNameFocusNode = FocusNode();
  final FocusNode _duiFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _birthDateFocusNode = FocusNode();
  
  // Variables de validación en tiempo real
  bool _isNameValid = true;
  bool _isDuiValid = true;
  bool _isPhoneValid = true;
  bool _isBirthDateValid = true;
  
  // Formato para el DUI (00000000-0)
  String _formatDUI(String input) {
    // Remover todos los caracteres no numéricos
    String digits = input.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length <= 8) {
      return digits;
    } else if (digits.length == 9) {
      return '${digits.substring(0, 8)}-${digits.substring(8)}';
    } else {
      return '${digits.substring(0, 8)}-${digits.substring(8, 9)}';
    }
  }
  
  // Formato para teléfono (0000-0000)
  String _formatPhone(String input) {
    String digits = input.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length <= 4) {
      return digits;
    } else {
      return '${digits.substring(0, 4)}-${digits.substring(4)}';
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Listeners para validación en tiempo real y formateo
    _duiController.addListener(() {
      final text = _duiController.text;
      final formatted = _formatDUI(text);
      if (text != formatted) {
        _duiController.value = _duiController.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      _validateRealTime();
    });
    
    _phoneController.addListener(() {
      final text = _phoneController.text;
      final formatted = _formatPhone(text);
      if (text != formatted) {
        _phoneController.value = _phoneController.value.copyWith(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
      _validateRealTime();
    });
    
    _fullNameController.addListener(_validateRealTime);
    _birthDateController.addListener(_validateRealTime);
  }

  void _validateRealTime() {
    if (mounted) {
      setState(() {
        _isNameValid = _validateName(_fullNameController.text);
        _isDuiValid = _validateDUI(_duiController.text);
        _isPhoneValid = _validatePhone(_phoneController.text);
        _isBirthDateValid = _validateBirthDate(_birthDateController.text);
      });
    }
  }

  bool _validateName(String value) {
    if (value.isEmpty) return true;
    return value.length >= 3 && value.contains(' ');
  }

  bool _validateDUI(String value) {
    if (value.isEmpty) return true;
    final duiRegex = RegExp(r'^\d{8}-\d{1}$');
    return duiRegex.hasMatch(value);
  }

  bool _validatePhone(String value) {
    if (value.isEmpty) return true;
    final phoneRegex = RegExp(r'^\d{4}-\d{4}$');
    return phoneRegex.hasMatch(value);
  }

  bool _validateBirthDate(String value) {
    if (value.isEmpty) return true;
    try {
      final date = DateFormat('dd/MM/yyyy').parseStrict(value);
      final now = DateTime.now();
      final minDate = DateTime(now.year - 100, now.month, now.day);
      final maxDate = DateTime(now.year - 18, now.month, now.day);
      return date.isAfter(minDate) && date.isBefore(maxDate);
    } catch (e) {
      return false;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      _birthDateController.text = formattedDate;
    }
  }

  Color _getBorderColor(bool isValid, BuildContext context) {
    final theme = Theme.of(context);
    final text = isValid ? _fullNameController.text : '';
    
    if (text.isEmpty) {
      return theme.colorScheme.outline;
    }
    
    return isValid 
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context, 'Información Personal'),
            
            const SizedBox(height: 16),
            
            // Nombre Completo
            _buildTextField(
              context: context,
              controller: _fullNameController,
              focusNode: _fullNameFocusNode,
              label: 'Nombre Completo *',
              hintText: 'Ej: Juan Pérez García',
              icon: Icons.person,
              isValid: _isNameValid,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu nombre completo';
                }
                if (value.length < 3 || !value.contains(' ')) {
                  return 'Ingresa al menos nombre y apellido';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // DUI
            _buildTextField(
              context: context,
              controller: _duiController,
              focusNode: _duiFocusNode,
              label: 'DUI *',
              hintText: '00000000-0',
              icon: Icons.badge,
              isValid: _isDuiValid,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu DUI';
                }
                final duiRegex = RegExp(r'^\d{8}-\d{1}$');
                if (!duiRegex.hasMatch(value)) {
                  return 'Formato de DUI inválido (00000000-0)';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Teléfono
            _buildTextField(
              context: context,
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              label: 'Teléfono *',
              hintText: '0000-0000',
              icon: Icons.phone,
              isValid: _isPhoneValid,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa tu teléfono';
                }
                final phoneRegex = RegExp(r'^\d{4}-\d{4}$');
                if (!phoneRegex.hasMatch(value)) {
                  return 'Formato de teléfono inválido (0000-0000)';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Fecha de Nacimiento
            _buildDateField(context),
            
            const SizedBox(height: 32),
            
            // Botones de acción
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hintText,
    required IconData icon,
    required bool isValid,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _getBorderColor(isValid, context),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de Nacimiento *',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _birthDateController,
          focusNode: _birthDateFocusNode,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'DD/MM/AAAA',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _getBorderColor(_isBirthDateValid, context),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
          ),
          onTap: () => _selectDate(context),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor selecciona tu fecha de nacimiento';
            }
            if (!_validateBirthDate(value)) {
              return 'Debes ser mayor de 18 años y la fecha debe ser válida';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancelPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cancelar',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSavePressed();
              } else {
                _validateRealTime();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Guardar',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _duiController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _fullNameFocusNode.dispose();
    _duiFocusNode.dispose();
    _phoneFocusNode.dispose();
    _birthDateFocusNode.dispose();
    super.dispose();
  }
}