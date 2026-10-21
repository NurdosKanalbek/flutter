import 'package:flutter/material.dart';
import '../models/workshop.dart';
import '../utils/format.dart';

typedef _FormValues = ({String title, String place, String limit,
  String description, WorkshopCategory? category, bool online,
  DateTime? date, TimeOfDay? time});

class WorkshopFormScreen extends StatefulWidget {
  const WorkshopFormScreen({super.key, this.workshop});
  final Workshop? workshop;
  @override
  State<WorkshopFormScreen> createState() => _WorkshopFormScreenState();
}

class _WorkshopFormScreenState extends State<WorkshopFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _place = TextEditingController();
  final _limit = TextEditingController();
  final _description = TextEditingController();
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  late final Workshop _original;
  WorkshopCategory? _category;
  bool _online = false;
  DateTime? _date;
  TimeOfDay? _time;
  late final _FormValues _initialValues;
  bool _saving = false;
  bool _allowPop = false;
  bool _confirmingDiscard = false;

  @override
  void initState() {
    super.initState();
    _original = widget.workshop ?? Workshop.empty();
    _title.text = _original.title;
    _place.text = _original.place;
    _limit.text = '${_original.limit}';
    _description.text = _original.description ?? '';
    _category = _original.category;
    _online = _original.online;
    if (widget.workshop != null) {
      _date = DateUtils.dateOnly(_original.when);
      _time = TimeOfDay.fromDateTime(_original.when);
      _dateText.text = formatDate(_original.when);
      _timeText.text = formatTime(_original.when);
    }
    _initialValues = _values;
  }

  _FormValues get _values => (title: _title.text, place: _place.text,
    limit: _limit.text, description: _description.text,
    category: _category, online: _online, date: _date, time: _time);

  bool get _dirty => _values != _initialValues;

  Future<void> _pop(Workshop? workshop) async {
    setState(() => _allowPop = true);
    // PopScope must receive the new canPop before Navigator.pop is attempted.
    await WidgetsBinding.instance.endOfFrame;
    if (mounted == false) return;
    Navigator.pop(context, workshop);
  }

  Future<void> _discard() async {
    if (_confirmingDiscard) return;
    _confirmingDiscard = true;
    final discard = await showDialog<bool>(context: context, builder: (dialogContext) =>
      AlertDialog(title: const Text('Discard changes?'),
        content: const Text('Your changes have not been saved.'),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Keep editing')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'))]));
    if (mounted == false) return;
    _confirmingDiscard = false;
    if (discard == true) await _pop(null);
  }

  DateTime? get _when => switch ((_date, _time)) {
    (final date?, final time?) => DateTime(date.year, date.month, date.day, time.hour, time.minute),
    _ => null,
  };

  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();
    return title.length < 3 || title.length > 60 ? 'Use 3–60 characters' : null;
  }

  String? _validatePlace(String? value) {
    final place = (value ?? '').trim();
    if (place.isEmpty) return _online ? 'Enter a meeting link' : 'Enter a place';
    return _online && place.contains('://') == false ? 'Include :// in the meeting link' : null;
  }

  String? _validateLimit(String? value) {
    final limit = int.tryParse((value ?? '').trim());
    if (limit == null || limit < 1 || limit > 500) return 'Enter a whole number from 1 to 500';
    return limit < _original.count ? 'At least ${_original.count} makers are already on the list' : null;
  }

  String? _validateDate(String? value) => _date == null ? 'Choose a date' : _validateFuture();
  String? _validateTime(String? value) => _time == null ? 'Choose a time' : _validateFuture();
  String? _validateFuture() => widget.workshop == null &&
    (_when?.isAfter(DateTime.now()) == false) ? 'Choose a future date and time' : null;

  Future<void> _pickDate() async {
    final selected = await showDatePicker(context: context,
      initialDate: _date ?? _original.when,
      firstDate: DateTime(2000), lastDate: DateTime(DateTime.now().year + 5, 12, 31));
    if (selected == null) return;
    if (mounted == false) return;
    setState(() { _date = selected; _dateText.text = formatDate(selected); });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(context: context,
      initialTime: _time ?? TimeOfDay.fromDateTime(_original.when));
    if (selected == null) return;
    if (mounted == false) return;
    setState(() {
      _time = selected;
      _timeText.text = '${selected.hour}:${selected.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    // Safe here: this handler belongs to the mounted Form's Save button.
    if (_formKey.currentState!.validate() == false) return;
    final when = _when;
    final category = _category;
    if (when == null || category == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted == false) return;
    final description = _description.text.trim();
    final workshop = _original.copyWith(
      id: widget.workshop?.id ?? 'maker-${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(), place: _place.text.trim(),
      limit: int.parse(_limit.text.trim()), category: category, online: _online,
      when: when, description: description, clearDescription: description.isEmpty);
    await _pop(workshop);
  }

  @override
  void dispose() {
    for (final controller in [_title, _place, _limit, _description, _dateText, _timeText]) {
      controller.dispose();
    }
    for (final node in [_placeFocus, _limitFocus, _descriptionFocus]) { node.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope<Workshop>(
    canPop: _allowPop || (_dirty == false && _saving == false),
    onPopInvokedWithResult: (didPop, result) {
      if (didPop == false && _saving == false) _discard();
    },
    child: Scaffold(
    appBar: AppBar(title: Text(widget.workshop == null ? 'New workshop' : 'Edit workshop')),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16),
      child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600),
        child: AbsorbPointer(absorbing: _saving,
        child: Form(key: _formKey, autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}), child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(controller: _title, validator: _validateTitle,
                maxLength: 60, textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Workshop title'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus()),
              const SizedBox(height: 16),
              TextFormField(controller: _place, focusNode: _placeFocus, validator: _validatePlace,
                decoration: InputDecoration(labelText: _online ? 'Meeting link' : 'Place',
                  hintText: _online ? 'https://meet.example.org/workshop' : 'Building and room'),
                keyboardType: _online ? TextInputType.url : TextInputType.streetAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus()),
              const SizedBox(height: 16),
              TextFormField(controller: _limit, focusNode: _limitFocus, validator: _validateLimit,
                decoration: InputDecoration(labelText: 'Maker limit',
                  helperText: widget.workshop == null ? '1–500 places' : '${_original.count} makers already on the list'),
                keyboardType: TextInputType.number, textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus()),
              const SizedBox(height: 16),
              DropdownButtonFormField<WorkshopCategory>(initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [for (final category in WorkshopCategory.values)
                  DropdownMenuItem(value: category, child: Row(children: [
                    Icon(category.icon, size: 20), const SizedBox(width: 12), Text(category.label),
                  ]))],
                validator: (category) => category == null ? 'Choose a category' : null,
                onChanged: (category) => setState(() => _category = category)),
              const SizedBox(height: 8),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Online workshop'),
                subtitle: const Text('Use a meeting link instead of a room'), value: _online,
                onChanged: (online) => setState(() => _online = online)),
              const SizedBox(height: 8),
              TextFormField(controller: _dateText, readOnly: true, validator: _validateDate,
                decoration: const InputDecoration(labelText: 'Date', suffixIcon: Icon(Icons.calendar_month)),
                onTap: _pickDate,
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus()),
              const SizedBox(height: 16),
              TextFormField(controller: _timeText, readOnly: true, validator: _validateTime,
                decoration: const InputDecoration(labelText: 'Time', suffixIcon: Icon(Icons.schedule)),
                onTap: _pickTime,
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus()),
              const SizedBox(height: 16),
              TextFormField(controller: _description, focusNode: _descriptionFocus,
                validator: (value) => (value ?? '').length > 600 ? 'Use at most 600 characters' : null,
                maxLength: 600, minLines: 2, maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                keyboardType: TextInputType.text, textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus()),
              const SizedBox(height: 24),
              FilledButton.icon(onPressed: _saving ? null : _save,
                icon: _saving ? const SizedBox(width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
                label: Text(_saving ? 'Saving…' : 'Save')),
              const SizedBox(height: 16),
            ])),
      ))))),
  ));
}
