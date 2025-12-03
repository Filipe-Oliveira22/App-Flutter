
// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'package:flutter/material.dart';


String sha256Hex(String input) {
  final bytes = utf8.encode(input);
  final h = _sha256(bytes);
  return h.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

List<int> _sha256(List<int> message) {

  final k = <int>[
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
    0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
    0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
    0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
    0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
    0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
  ];

  int rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xFFFFFFFF;
  int shr(int x, int n) => x >> n;

  int bigSigma0(int x) => rotr(x, 2) ^ rotr(x, 13) ^ rotr(x, 22);
  int bigSigma1(int x) => rotr(x, 6) ^ rotr(x, 11) ^ rotr(x, 25);
  int smallSigma0(int x) => rotr(x, 7) ^ rotr(x, 18) ^ shr(x, 3);
  int smallSigma1(int x) => rotr(x, 17) ^ rotr(x, 19) ^ shr(x, 10);
  int ch(int x, int y, int z) => (x & y) ^ ((~x) & z);
  int maj(int x, int y, int z) => (x & y) ^ (x & z) ^ (y & z);

  
  var h0 = 0x6a09e667;
  var h1 = 0xbb67ae85;
  var h2 = 0x3c6ef372;
  var h3 = 0xa54ff53a;
  var h4 = 0x510e527f;
  var h5 = 0x9b05688c;
  var h6 = 0x1f83d9ab;
  var h7 = 0x5be0cd19;

  
  final ml = message.length * 8;
  var padded = List<int>.from(message);
  
  padded.add(0x80);
 
  while ((padded.length % 64) != 56) {
    padded.add(0x00);
  }
  
  for (var i = 7; i >= 0; i--) {
    padded.add((ml >> (8 * i)) & 0xFF);
  }

  
  for (var chunkStart = 0; chunkStart < padded.length; chunkStart += 64) {
    final w = List<int>.filled(64, 0);
 
    for (var i = 0; i < 16; i++) {
      final idx = chunkStart + i * 4;
      w[i] = (padded[idx] << 24) |
          (padded[idx + 1] << 16) |
          (padded[idx + 2] << 8) |
          (padded[idx + 3]);
    }

    for (var i = 16; i < 64; i++) {
      final s0 = smallSigma0(w[i - 15]);
      final s1 = smallSigma1(w[i - 2]);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xFFFFFFFF;
    }


    var a = h0;
    var b = h1;
    var c = h2;
    var d = h3;
    var e = h4;
    var f = h5;
    var g = h6;
    var hh = h7;


    for (var i = 0; i < 64; i++) {
      late final int T1 = (hh + bigSigma1(e) + ch(e, f, g) + k[i] + w[i]) & 0xFFFFFFFF;
      final T2 = (bigSigma0(a) + maj(a, b, c)) & 0xFFFFFFFF;
      hh = g;
      g = f;
      f = e;
      e = (d + T1) & 0xFFFFFFFF;
      d = c;
      c = b;
      b = a;
      a = (T1 + T2) & 0xFFFFFFFF;
    }

    h0 = (h0 + a) & 0xFFFFFFFF;
    h1 = (h1 + b) & 0xFFFFFFFF;
    h2 = (h2 + c) & 0xFFFFFFFF;
    h3 = (h3 + d) & 0xFFFFFFFF;
    h4 = (h4 + e) & 0xFFFFFFFF;
    h5 = (h5 + f) & 0xFFFFFFFF;
    h6 = (h6 + g) & 0xFFFFFFFF;
    h7 = (h7 + hh) & 0xFFFFFFFF;
  }

  final hash = <int>[];
  for (var hv in [h0, h1, h2, h3, h4, h5, h6, h7]) {
    hash.addAll([
      (hv >> 24) & 0xFF,
      (hv >> 16) & 0xFF,
      (hv >> 8) & 0xFF,
      hv & 0xFF
    ]);
  }
  return hash;
}


void saveUserToStorage(Map<String, dynamic> user) {
  final key = 'user:${user['email']}';
  html.window.localStorage[key] = jsonEncode(user);
}

Map<String, dynamic>? getUserFromStorage(String email) {
  final key = 'user:$email';
  final raw = html.window.localStorage[key];
  if (raw == null) return null;
  return jsonDecode(raw) as Map<String, dynamic>;
}



int countCharacters(String text, {bool includeSpaces = true}) =>
    includeSpaces ? text.length : text.replaceAll(' ', '').length;

int countWords(String text) {
  final words = text.split(RegExp(r'\s+')).where((s) => s.trim().isNotEmpty);
  return words.length;
}

int countSentences(String text) {
  final sentences =
      text.split(RegExp(r'[.!?]+')).where((s) => s.trim().isNotEmpty);
  return sentences.length;
}

List<MapEntry<String, int>> topWords(String text, {List<String>? stopwords}) {
  final sw = stopwords ?? [];
  final words = text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]', unicode: true), '')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty && !sw.contains(w))
      .toList();
  final Map<String, int> freq = {};
  for (var w in words) {
    freq[w] = (freq[w] ?? 0) + 1;
  }
  final sorted = freq.entries.toList()..sort((a, b) => b.value - a.value);
  return sorted.take(10).toList();
}

double readingTimeMinutes(String text) {
  final words = countWords(text);
  return words / 250.0;
}

void mainUI() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Copytext - DartPad Demo',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/home': (_) => const HomePage(),
        '/results': (_) => const ResultsPage(),
      },
      initialRoute: '/',
      theme: ThemeData(primarySwatch: Colors.indigo),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _showPass = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final email = _emailCtl.text.trim();
    final pass = _passCtl.text;
    await Future.delayed(const Duration(milliseconds: 250));
    final user = getUserFromStorage(email);
    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Usuário não encontrado')));
      setState(() => _loading = false);
      return;
    }
    final salt = user['salt'] as String;
    final hashed = sha256Hex(pass + salt);
    if (hashed == user['password_hash']) {
      setState(() => _loading = false);
      Navigator.of(context).pushReplacementNamed('/home', arguments: user);
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Senha incorreta')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _emailCtl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtl,
            obscureText: !_showPass,
            decoration: InputDecoration(
              labelText: 'Senha',
              suffixIcon: IconButton(
                icon:
                    Icon(_showPass ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _showPass = !_showPass),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Entrar'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/register'),
            child: const Text('Ainda não tem conta? Cadastre-se'),
          )
        ]),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  final _nomeCtl = TextEditingController();
  final _cpfCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  DateTime? _nascimento;
  bool _showPass = false;
  bool _showConfirm = false;

  bool hasUpper = false;
  bool hasLower = false;
  bool hasDigit = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  @override
  void dispose() {
    _nomeCtl.dispose();
    _cpfCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  void _checkPassword(String s) {
    setState(() {
      hasUpper = RegExp(r'[A-Z]').hasMatch(s);
      hasLower = RegExp(r'[a-z]').hasMatch(s);
      hasDigit = RegExp(r'[0-9]').hasMatch(s);
      hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(s);
      hasMinLength = s.length >= 8;
    });
  }

  bool get isNameValid {
    final parts = _nomeCtl.text.trim().split(RegExp(r'\s+'));
    return parts.length >= 2 && parts.every((p) => p.length >= 2);
  }

  bool get isCpfValid {
    final digits = _cpfCtl.text.replaceAll(RegExp(r'\D'), '');
    return digits.length == 11;
  }

  bool get isEmailValid {
    final e = _emailCtl.text.trim();
    return e.contains('@') && e.contains('.');
  }

  bool get isPasswordValid =>
      hasUpper && hasLower && hasDigit && hasSpecial && hasMinLength;

  bool get canSubmit =>
      isNameValid &&
      isCpfValid &&
      _nascimento != null &&
      isEmailValid &&
      isPasswordValid &&
      _passCtl.text == _confirmCtl.text;

  Future<void> _submit() async {
    if (!canSubmit) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Formulário inválido')));
      return;
    }
    final salt = Random.secure().nextInt(1 << 32).toString();
    final hash = sha256Hex(_passCtl.text + salt);
    final user = {
      'nome': _nomeCtl.text.trim(),
      'cpf': _cpfCtl.text.trim(),
      'nascimento': _nascimento!.toIso8601String().split('T').first,
      'email': _emailCtl.text.trim(),
      'salt': salt,
      'password_hash': hash,
    };
    saveUserToStorage(user);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Usuário criado com sucesso')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _nomeCtl,
            decoration: const InputDecoration(labelText: 'Nome completo'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cpfCtl,
            decoration: const InputDecoration(labelText: 'CPF (apenas dígitos)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(now.year - 18),
                firstDate: DateTime(1900),
                lastDate: now,
              );
              if (picked != null) setState(() => _nascimento = picked);
            },
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Data de Nascimento',
                  hintText:
                      _nascimento == null ? 'Selecione a data' : _nascimento!.toIso8601String().split('T').first,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtl,
            decoration: const InputDecoration(labelText: 'E-mail'),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtl,
            obscureText: !_showPass,
            decoration: InputDecoration(
              labelText: 'Senha',
              suffixIcon: IconButton(
                icon: Icon(_showPass ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _showPass = !_showPass),
              ),
            ),
            onChanged: (v) => _checkPassword(v),
          ),
          const SizedBox(height: 8),
          PasswordRulesWidget(
            upper: hasUpper,
            lower: hasLower,
            digit: hasDigit,
            special: hasSpecial,
            minLength: hasMinLength,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtl,
            obscureText: !_showConfirm,
            decoration: InputDecoration(
              labelText: 'Confirmar Senha',
              suffixIcon: IconButton(
                icon: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _showConfirm = !_showConfirm),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSubmit ? _submit : null,
              child: const Text('Cadastrar'),
            ),
          ),
        ]),
      ),
    );
  }
}

class PasswordRulesWidget extends StatelessWidget {
  final bool upper, lower, digit, special, minLength;
  const PasswordRulesWidget({
    super.key,
    required this.upper,
    required this.lower,
    required this.digit,
    required this.special,
    required this.minLength,
  });
  Widget _rule(bool ok, String text) {
    return Row(children: [
      Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? Colors.green : Colors.grey, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(text)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _rule(upper, 'Ao menos uma letra maiúscula (A-Z)'),
      _rule(lower, 'Ao menos uma letra minúscula (a-z)'),
      _rule(digit, 'Ao menos um número (0-9)'),
      _rule(special, 'Ao menos um caractere especial (!@#\$...)'),
      _rule(minLength, 'Mínimo 8 caracteres'),
    ]);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? user;
  final _controller = TextEditingController();
  final List<String> stopwords = const [
    "a", "o", "que", "de", "para", "com", "sem", "mas",
    "e", "ou", "entre", "em", "por", "da", "do"
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      user = args;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _analyze() {
    final text = _controller.text;
    final data = {
      'charWithSpaces': countCharacters(text, includeSpaces: true),
      'charNoSpaces': countCharacters(text, includeSpaces: false),
      'words': countWords(text),
      'sentences': countSentences(text),
      'topWords': topWords(text, stopwords: stopwords),
      'readingTime': readingTimeMinutes(text),
    };
    Navigator.of(context).pushNamed('/results', arguments: {'data': data, 'text': text});
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (user != null && user!['nome'] != null)
        ? user!['nome'].toString().split(' ').first
        : '';
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, $displayName!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          )
        ],
      ),
      body: Column(children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Digite ou cole seu texto aqui...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _analyze,
                child: const Text('Analisar'),
              ),
            ),
          ]),
        ),
        Container(
          width: double.infinity,
          color: Colors.grey.shade200,
          padding: const EdgeInsets.all(8.0),
          child: const Text('By Filipe Oliveira Santos', textAlign: TextAlign.center),
        ),
      ]),
    );
  }
}

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final data = args?['data'] as Map<String, dynamic>? ?? {};
    final text = args?['text'] as String? ?? '';
    final top = data['topWords'] as List<dynamic>? ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                _row('Caracteres (com espaços):', '${data['charWithSpaces'] ?? 0}'),
                const Divider(),
                _row('Caracteres (sem espaços):', '${data['charNoSpaces'] ?? 0}'),
                const Divider(),
                _row('Palavras:', '${data['words'] ?? 0}'),
                const Divider(),
                _row('Sentenças:', '${data['sentences'] ?? 0}'),
                const Divider(),
                _row('Tempo de leitura (min):', (data['readingTime'] ?? 0).toStringAsFixed(2)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Top 10 palavras mais frequentes:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...top.map((e) {
                  if (e is MapEntry) {
                    return Text('${e.key} → ${e.value}');
                  } else if (e is Map) {
                    return Text('${e.keys.first} → ${e.values.first}');
                  } else {
                    return Text(e.toString());
                  }
                }),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Texto analisado:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(text),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
      Text(value),
    ]);
  }
}

// Entrypoint
void main() => runApp(const MyApp());