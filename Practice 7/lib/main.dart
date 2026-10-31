import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: const SignUpScreen(),
  );
}

const groups = ['IT-2301', 'IT-2302', 'IT-2303', 'IT-2304', 'IT-2305'];

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Level 1: Controllers — created once in State, disposed here
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthController = TextEditingController();

  // Level 2: Form key
  final _formKey = GlobalKey<FormState>();

  // Level 3: FocusNode for email — created once in State, disposed here
  final _emailFocus = FocusNode();

  // Level 1: password length counter
  int _passwordLength = 0;

  // Level 4: dropdown, date picker, checkbox state
  String? _group;
  DateTime? _birth;
  bool _agreed = false;

  // Level 5: done/summary state
  bool _done = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm, _birthController]) {
      c.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  // ─── Level 1: if-chain submit (kept for reference; Level 2 replaces) ───────
  // void _submitIfChain() { ... }

  // ─── Level 2: form-based submit ─────────────────────────────────────────────
  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _done = true);
    }
  }

  // ─── Level 4: date picker ────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    // null → user pressed Cancel: keep the old value
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _birth = picked;
      _birthController.text =
          '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
    });
  }

  // ─── Level 5: start over ─────────────────────────────────────────────────────
  void _startOver() {
    setState(() {
      for (final c in [_name, _email, _password, _confirm, _birthController]) {
        c.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _passwordLength = 0;
      _done = false;
      // Note: _formKey.currentState is null while Form is not on screen —
      // never call _formKey.currentState!.reset() here.
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: _done ? _buildSummary() : _buildForm(),
  );

  // ─── Level 5: summary ────────────────────────────────────────────────────────
  Widget _buildSummary() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        SummaryCard(
          name: _name.text,
          email: _email.text,
          group: _group ?? '—',
          birthDate: _birthController.text.isEmpty
              ? '—'
              : _birthController.text,
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: _startOver, child: const Text('Start over')),
      ],
    ),
  );

  // ─── Levels 1–4: form ────────────────────────────────────────────────────────
  Widget _buildForm() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      key: _formKey,
      // Level 2: errors appear while typing (after first touch)
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Name ──────────────────────────────────────────────────────────
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
            textInputAction: TextInputAction.next,
            // Level 3: move focus to email specifically
            onFieldSubmitted: (_) => _emailFocus.requestFocus(),
            // Level 3: tap outside folds keyboard
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            // Level 2: validator beside the field
            validator: (v) {
              final text = (v ?? '').trim();
              if (text.length < 2) return 'Name is too short';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // ── Email ─────────────────────────────────────────────────────────
          TextFormField(
            controller: _email,
            focusNode: _emailFocus, // Level 3: named focus node
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@kbtu.kz',
            ),
            keyboardType: TextInputType.emailAddress, // Level 3
            autocorrect: false, // Level 3
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            validator: (v) {
              final text = (v ?? '').trim();
              if (!text.contains('@') || !text.contains('.')) {
                return 'Email looks wrong';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // ── Password ──────────────────────────────────────────────────────
          TextFormField(
            controller: _password,
            decoration: const InputDecoration(
              labelText: 'Password',
              helperText: 'At least 8 characters',
            ),
            obscureText: true, // Level 3
            textInputAction: TextInputAction.next,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            // Level 1: length counter via onChanged — value in, setState out
            onChanged: (v) => setState(() => _passwordLength = v.length),
            validator: (v) {
              if ((v ?? '').length < 8) return 'Password is too short';
              return null;
            },
          ),
          // Level 1: live counter under password field
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              '$_passwordLength of 8',
              style: TextStyle(
                fontSize: 12,
                color: _passwordLength >= 8 ? Colors.teal : Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Confirm password ──────────────────────────────────────────────
          TextFormField(
            controller: _confirm,
            decoration: const InputDecoration(labelText: 'Confirm password'),
            obscureText: true, // Level 3
            textInputAction: TextInputAction.done, // Level 3: last field
            onFieldSubmitted: (_) => _submit(), // Level 3: done submits
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            // Validator reads another controller — allowed
            validator: (v) {
              if ((v ?? '') != _password.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Level 4: Group dropdown ───────────────────────────────────────
          DropdownButtonFormField<String>(
            value: _group,
            decoration: const InputDecoration(labelText: 'Group'),
            items: groups
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => setState(() => _group = v),
            validator: (g) => g == null ? 'Choose a group' : null,
          ),
          const SizedBox(height: 16),

          // ── Level 4: Date of birth ────────────────────────────────────────
          TextFormField(
            controller: _birthController,
            decoration: const InputDecoration(
              labelText: 'Date of birth',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: _pickDate,
            validator: (_) => _birth == null ? 'Pick a date of birth' : null,
          ),
          const SizedBox(height: 8),

          // ── Level 4: Agree checkbox ───────────────────────────────────────
          CheckboxListTile(
            title: const Text('I agree to the rules'),
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24), // Level 3: SizedBox, not Spacer
          // ── Sign up button ────────────────────────────────────────────────
          // Level 4: onPressed: null disables the button when not agreed
          FilledButton(
            onPressed: _agreed ? _submit : null,
            child: const Text('Sign up'),
          ),
        ],
      ),
    ),
  );
}
