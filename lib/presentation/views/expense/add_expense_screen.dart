import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/mixins/disposable_controllers_mixin.dart';
import '../../../core/mixins/form_validation_mixin.dart';
import '../../../core/mixins/loading_state_mixin.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../data/models/expense_category.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/models/receipt_scan_result.dart';
import '../../providers/expense_controller.dart';
import '../../providers/repository_providers.dart';
import '../../providers/session_providers.dart';
import '../../widgets/expense/expense_image_picker_field.dart';

/// Form for creating a new expense.
///
/// Renamed from `NewExpense`. The original screen duplicated an entire
/// Firestore-write code path twice (once with an image, once without) and
/// mixed image-persistence, Firestore writes and form UI in one widget.
/// This version builds one [ExpenseModel] draft and hands it to
/// [ExpenseController], which owns image persistence + the write.
///
/// Capturing a receipt photo also runs it through on-device OCR
/// ([ReceiptScannerService]) to auto-fill amount/name/date — see
/// [_handleImagePicked]. This is best-effort only: it never blocks
/// manual entry and never overwrites a field the user already typed in.
class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen>
    with
        LoadingStateMixin<AddExpenseScreen>,
        DisposableControllersMixin<AddExpenseScreen>,
        FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = registerController();
  late final _amountController = registerController();
  late final _descriptionController = registerController();

  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.extras;
  File? _pickedImage;

  bool _isScanningReceipt = false;
  bool _didAutofillFromReceipt = false;

  Future<void> _presentDatePicker() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 20, now.month, now.day),
      lastDate: now,
    );
    if (pickedDate == null) return;
    setState(() => _selectedDate = pickedDate);
  }

  /// Runs when [ExpenseImagePickerField] hands back a captured photo.
  ///
  /// OCR is pure convenience on top of a form the user can already fill
  /// in by hand, so a scan failure is swallowed here (via
  /// [ErrorHandlerService.guard], which logs + toasts it) rather than
  /// blocking the flow — the picked image is kept either way.
  Future<void> _handleImagePicked(File image) async {
    setState(() {
      _pickedImage = image;
      _isScanningReceipt = true;
    });

    final result = await ref
        .read(errorHandlerServiceProvider)
        .guard(() => ref.read(receiptScannerServiceProvider).scan(image));

    if (!mounted) return;
    setState(() => _isScanningReceipt = false);
    if (result != null) _applyScanResult(result);
  }

  /// Fills the form from a scan, but only into fields the user hasn't
  /// already typed something into — auto-fill should never clobber input
  /// a person already made.
  void _applyScanResult(ReceiptScanResult result) {
    if (!result.hasAnyMatch) return;

    setState(() {
      if (result.amount != null && _amountController.text.trim().isEmpty) {
        _amountController.text = result.amount!.toStringAsFixed(2);
      }
      if (result.merchantName != null && _nameController.text.trim().isEmpty) {
        _nameController.text = result.merchantName!;
      }
      if (result.date != null) {
        _selectedDate = result.date!;
      }
      _didAutofillFromReceipt = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final errorHandler = ref.read(errorHandlerServiceProvider);
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      errorHandler.handle(const UnauthenticatedException());
      return;
    }

    final draft = ExpenseModel(
      id: '',
      name: _nameController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      date: _selectedDate,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
    );

    try {
      await withLoading(
        () => ref.read(expenseControllerProvider).submitExpense(
          draft: draft,
          ownerUid: currentUser.uid,
          receiptImage: _pickedImage,
        ),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: 'Expense Added',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (error) {
      errorHandler.handle(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add new Expense')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      label: Text('Name of Expense'),
                    ),
                    maxLength: 50,
                    validator: (value) => validateRequired(
                      value,
                      fieldLabel: 'Name',
                      minLength: 2,
                      maxLength: 50,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      label: Text('Description of Expense'),
                    ),
                    maxLength: 1000,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            label: Text('Enter Amount'),
                            prefixText: '\$',
                          ),
                          validator: validatePositiveAmount,
                        ),
                      ),
                      const SizedBox(width: 17),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(DateFormatting.formatShort(_selectedDate)),
                            IconButton(
                              onPressed: _presentDatePicker,
                              icon: const Icon(Icons.calendar_month),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: _selectedCategory,
                    items: ExpenseCategory.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  ExpenseImagePickerField(onImagePicked: _handleImagePicked),
                  if (_isScanningReceipt) ...[
                    const SizedBox(height: 8),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Reading receipt…'),
                      ],
                    ),
                  ] else if (_didAutofillFromReceipt) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Filled in from your receipt — check it over before saving.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : _submit,
                      child: Text(
                        'submit',
                        style: GoogleFonts.spaceMono(color: Colors.black),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'cancel',
                        style: GoogleFonts.spaceMono(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isBusy)
            Container(
              color: const Color.fromARGB(112, 0, 0, 0),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
