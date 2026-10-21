import 'package:flutter/material.dart';

import 'summary_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Student sign up',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    ),
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
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _birthDate = TextEditingController();
  final _emailFocus = FocusNode();

  String? _group;
  DateTime? _birth;
  bool _agreed = false;
  bool _done = false;
  int _passwordLength = 0;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirm, _birthDate]) {
      controller.dispose();
    }
    _emailFocus.dispose();
    super.dispose();
  }

  void _signUp() {
    if (_formKey.currentState!.validate() == false) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _done = true);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Account created')));
  }

  Future<void> _pickBirthDate() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birth ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Choose your date of birth',
    );

    if (picked == null) return;
    if (mounted == false) return;
    setState(() {
      _birth = picked;
      _birthDate.text =
          '${picked.day.toString().padLeft(2, '0')}.'
          '${picked.month.toString().padLeft(2, '0')}.'
          '${picked.year.toString().padLeft(4, '0')}';
    });
  }

  void _startOver() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      for (final controller in [
        _name,
        _email,
        _password,
        _confirm,
        _birthDate,
      ]) {
        controller.clear();
      }
      _group = null;
      _birth = null;
      _agreed = false;
      _passwordLength = 0;
      _done = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign up')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _done ? 840 : 560),
            child: _done ? _buildSummary() : _buildForm(),
          ),
        ),
      ),
    ),
  );

  Widget _buildSummary() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('You’re all set', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text('Your student account details'),
      const SizedBox(height: 24),
      SummaryCard(
        name: _name.text.trim(),
        email: _email.text.trim(),
        group: _group ?? '',
        birthDate: _birthDate.text,
      ),
      const SizedBox(height: 16),
      TextButton(onPressed: _startOver, child: const Text('Start over')),
    ],
  );

  Widget _buildForm() => Form(
    key: _formKey,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create your student account',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your details to get started. All fields are required.',
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Name'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          validator: (value) =>
              (value ?? '').trim().length < 2 ? 'Name is too short' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _email,
          focusNode: _emailFocus,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'name@kbtu.kz',
          ),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          validator: (value) {
            final email = (value ?? '').trim();
            final at = email.indexOf('@');
            return at > 0 && email.indexOf('.', at + 1) > at + 1
                ? null
                : 'Email looks wrong';
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _password,
          decoration: const InputDecoration(
            labelText: 'Password',
            helperText: 'At least 8 characters',
          ),
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.next,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onChanged: (value) => setState(() => _passwordLength = value.length),
          validator: (value) =>
              (value ?? '').length < 8 ? 'Password is too short' : null,
        ),
        const SizedBox(height: 4),
        Text(
          '$_passwordLength of 8',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirm,
          decoration: const InputDecoration(labelText: 'Confirm password'),
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: TextInputAction.done,
          // The keyboard action follows the same consent gate as the button.
          onFieldSubmitted: _agreed ? (_) => _signUp() : null,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          validator: (value) {
            if ((value ?? '').isEmpty) return 'Confirm your password';
            return value == _password.text ? null : 'Passwords do not match';
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _group,
          decoration: const InputDecoration(labelText: 'Group'),
          isExpanded: true,
          items: [
            for (final group in groups)
              DropdownMenuItem(value: group, child: Text(group)),
          ],
          onChanged: (value) => setState(() => _group = value),
          validator: (group) => group == null ? 'Choose a group' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _birthDate,
          decoration: const InputDecoration(
            labelText: 'Date of birth',
            hintText: 'dd.mm.yyyy',
            suffixIcon: Icon(Icons.calendar_month_outlined),
          ),
          readOnly: true,
          onTap: _pickBirthDate,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          validator: (_) => _birth == null ? 'Choose your date of birth' : null,
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('I agree to the rules'),
          value: _agreed,
          onChanged: (value) => setState(() => _agreed = value ?? false),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _agreed ? _signUp : null,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: const Text('Sign up'),
        ),
      ],
    ),
  );
}
