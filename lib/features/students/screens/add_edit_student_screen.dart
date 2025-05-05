import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_class_tracker/core/models/student.dart';
import 'package:dance_class_tracker/core/utils/validators.dart'; // Validation logic
import 'package:dance_class_tracker/features/students/providers/student_providers.dart'; // Student providers
import 'package:dance_class_tracker/features/students/widgets/batch_select_dropdown.dart';

import '../../../core/utils/date_formatter.dart';

class AddEditStudentScreen extends ConsumerStatefulWidget {
  final bool isEditMode;
  const AddEditStudentScreen({super.key, this.isEditMode = false});
  @override
  ConsumerState<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends ConsumerState<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();

  // Date picker logic (unchanged)
  Future<void> _selectDate(BuildContext context) async {
    final currentDob = ref.read(studentDobProvider);
    final DateTime? picked = await showDatePicker( context: context, initialDate: currentDob ?? DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime.now(), helpText: 'Select Date of Birth');
    if (picked != null && picked != currentDob) { ref.read(studentDobProvider.notifier).state = picked; }
    else { print("--- AddEditStudentScreen: Date picker cancelled or date unchanged."); }
  }

  // Save logic (unchanged from previous full file, uses studentListProvider notifier)
  Future<void> _saveStudent() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      print("--- AddEditStudentScreen: Form validation successful. Proceeding with save...");
      final originalEditingStudent = ref.read(editingStudentProvider);
      final name = ref.read(studentNameControllerProvider).text.trim();
      final parentName = ref.read(studentParentNameControllerProvider).text.trim();
      final mobile1 = ref.read(studentMobile1ControllerProvider).text.trim();
      final mobile2 = ref.read(studentMobile2ControllerProvider).text.trim();
      final dob = ref.read(studentDobProvider);
      final isWhatsappSame = ref.read(studentIsWhatsappSameProvider);
      final whatsappNumFromField = ref.read(studentWhatsappControllerProvider).text.trim();
      // Read the final selected batch ID from its provider
      final selectedBatchId = ref.read(studentSelectedBatchIdProvider);
      final String? finalWhatsappNumber = isWhatsappSame ? (mobile1.isNotEmpty ? mobile1 : null) : (whatsappNumFromField.isNotEmpty ? whatsappNumFromField : null);

      try {
        final studentListNotifier = ref.read(studentListProvider.notifier);

        // UPDATE Logic
        if (widget.isEditMode && originalEditingStudent != null) {
          print("--- AddEditStudentScreen: UPDATING Student ID: ${originalEditingStudent.id}");
          final updatedStudentData = originalEditingStudent.copyWith( name: name, dob: dob, parentName: parentName, mobile1: mobile1, mobile2: mobile2, setMobile2Null: mobile2.isEmpty, whatsappNumber: finalWhatsappNumber, setWhatsappNumberNull: finalWhatsappNumber == null, batchId: selectedBatchId, setBatchIdNull: selectedBatchId == null, );
          print("--- AddEditStudentScreen: Calling notifier.updateStudent ID=${updatedStudentData.id}, Name=${updatedStudentData.name}, BatchID=${updatedStudentData.batchId}");
          await studentListNotifier.updateStudent(updatedStudentData);
          if (mounted) { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Student "${updatedStudentData.name}" updated.')),); }
        }
        // ADD Logic
        else {
          print("--- AddEditStudentScreen: ADDING New Student");
          final newStudent = Student( name: name, dob: dob, parentName: parentName, mobile1: mobile1, mobile2: mobile2.isEmpty ? null : mobile2, whatsappNumber: finalWhatsappNumber, batchId: selectedBatchId, );
          print("--- AddEditStudentScreen: Calling notifier.addStudent ID=${newStudent.id}, Name=${newStudent.name}, BatchID=${newStudent.batchId}");
          await studentListNotifier.addStudent(newStudent);
          if (mounted) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Student "${newStudent.name}" added.')),); }
        }
        // Post-save actions
        if (mounted) { print("--- AddEditStudentScreen: Save successful, resetting state and popping."); ref.read(editingStudentProvider.notifier).state = null; Navigator.of(context).pop(); }
      } catch (e, s) {
        print("--- AddEditStudentScreen: ERROR saving student: $e\n$s");
        if(mounted){ ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error saving student details: $e'), backgroundColor: Theme.of(context).colorScheme.error),); }
      }
    } else {
      print("--- AddEditStudentScreen: Form validation failed.");
      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Please fix the errors highlighted in the form.'), backgroundColor: Colors.orangeAccent,),);
    }
  }


  @override
  Widget build(BuildContext context) {
    // Get theme and watch form state providers
    final theme = Theme.of(context);
    final nameController = ref.watch(studentNameControllerProvider);
    final parentNameController = ref.watch(studentParentNameControllerProvider);
    final mobile1Controller = ref.watch(studentMobile1ControllerProvider);
    final mobile2Controller = ref.watch(studentMobile2ControllerProvider);
    final whatsappController = ref.watch(studentWhatsappControllerProvider);
    final dobState = ref.watch(studentDobProvider);
    final isWhatsappSame = ref.watch(studentIsWhatsappSameProvider);
    // Watch the state provider holding the ID for the dropdown's current value
    final selectedBatchId = ref.watch(studentSelectedBatchIdProvider);
    // Note: Batch list data for dropdown options is fetched internally by BatchSelectDropdown

    // Logging during build (optional)
    // final studentBeingEdited = ref.watch(editingStudentProvider);
    // print("--- AddEditStudentScreen BUILD: Mode=${widget.isEditMode ? 'EDIT' : 'ADD'}. Editing Student ID = ${studentBeingEdited?.id ?? 'N/A'}");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Student' : 'Add New Student'),
        leading: IconButton( icon: const Icon(Icons.close), tooltip: 'Cancel', onPressed: () { ref.read(editingStudentProvider.notifier).state = null; Navigator.of(context).pop(); },),
        actions: [ IconButton( icon: const Icon(Icons.save_outlined), tooltip: 'Save Student', onPressed: _saveStudent, ), ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 48.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Student Name ---
              TextFormField( controller: nameController, decoration: const InputDecoration(labelText: 'Student Name*', prefixIcon: Icon(Icons.person_outline)), validator: (v) => Validators.name(v, 'Student Name'), textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next,),
              const SizedBox(height: 16),
              // --- Parent's Name ---
              TextFormField( controller: parentNameController, decoration: const InputDecoration(labelText: 'Parent\'s Name*', prefixIcon: Icon(Icons.escalator_warning_outlined)), validator: (v) => Validators.name(v, 'Parent\'s Name'), textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next,),
              const SizedBox(height: 16),
              // --- Date of Birth ---
              ListTile( contentPadding: EdgeInsets.zero, leading: const Icon(Icons.calendar_today_outlined), title: const Text("Date of Birth"), subtitle: Text( dobState == null ? 'Tap to select date' : DateFormatter.formatReadable(dobState), style: TextStyle( color: dobState == null ? theme.hintColor : theme.textTheme.bodyLarge?.color, fontSize: 16, ), ), trailing: Text( dobState != null ? 'Age: ${Student.fromMap({'id': 'temp', 'name': '', 'parentName': '', 'mobile1': '', 'dob': dobState.toIso8601String()}).age ?? '-'}' : '', style: theme.textTheme.bodySmall), onTap: () => _selectDate(context),),
              const SizedBox(height: 16),
              // --- Mobile Number 1 ---
              TextFormField( controller: mobile1Controller, decoration: const InputDecoration(labelText: 'Mobile Number 1*', prefixIcon: Icon(Icons.phone_android_outlined)), keyboardType: TextInputType.phone, validator: (v) => Validators.mobileNumber(v, isCompulsory: true), onChanged: (value) { if (ref.read(studentIsWhatsappSameProvider)) { ref.read(studentWhatsappControllerProvider).text = value; } }, textInputAction: TextInputAction.next,),
              const SizedBox(height: 16),
              // --- Mobile Number 2 ---
              TextFormField( controller: mobile2Controller, decoration: const InputDecoration(labelText: 'Mobile Number 2 (Optional)', prefixIcon: Icon(Icons.phone_android)), keyboardType: TextInputType.phone, validator: Validators.optionalMobileNumber, textInputAction: TextInputAction.next,),
              const SizedBox(height: 16),
              // --- WhatsApp Handling ---
              CheckboxListTile( contentPadding: EdgeInsets.zero, title: const Text("Mobile 1 is WhatsApp number"), value: isWhatsappSame, onChanged: (bool? value) { if (value != null) { ref.read(studentIsWhatsappSameProvider.notifier).state = value; if (value) { whatsappController.text = mobile1Controller.text; } } }, controlAffinity: ListTileControlAffinity.leading, dense: true,),
              if (!isWhatsappSame) ...[ const SizedBox(height: 8), TextFormField( controller: whatsappController, decoration: const InputDecoration( labelText: 'WhatsApp Number (if different)', prefixIcon: Icon(Icons.message_outlined),), keyboardType: TextInputType.phone, validator: (value) { if (value != null && value.trim().isNotEmpty) { return Validators.optionalMobileNumber(value); } return null;} , textInputAction: TextInputAction.next,), const SizedBox(height: 16),],

              // --- Batch Assignment Dropdown ---
              // Use the extracted BatchSelectDropdown widget
              BatchSelectDropdown(
                selectedBatchId: selectedBatchId, // Pass the current state value
                onChanged: (String? newValue) {
                  // Update the state provider when the dropdown value changes
                  ref.read(studentSelectedBatchIdProvider.notifier).state = newValue;
                },
              ),
              // --- End Batch Dropdown ---

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}