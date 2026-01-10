import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../databases/db_helper.dart';
import 'admin_page.dart';
import 'kasir_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final DbHelper _db = DbHelper();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _loginError;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loginError = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    final user = await _db.login(username, password);

    setState(() => _isLoading = false);

    if (user != null) {
      // reset login error
      setState(() => _loginError = null);

      // simpan data ke shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('role', user.role);
      await prefs.setString('username', user.username);
      await prefs.setInt('kasir_id', user.id!);

      // redirect sesuai role
      if (user.role == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
          (route) => false,
        );
      } else if (user.role == 'kasir') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => KasirHomePage()),
          (route) => false,
        );
      } else {
        setState(() => _loginError = 'Role tidak valid');
      }
    } else {
      setState(() => _loginError = 'Username atau Password salah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 7),
                Text(
                  'Login',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Warungku',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: UnderlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                    labelStyle: TextStyle(color: Colors.black54),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username harus diisi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  obscuringCharacter: '*',
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: UnderlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.redAccent),
                    ),
                    labelStyle: TextStyle(color: Colors.black54),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password harus diisi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _login,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateColor.resolveWith((state) {
                          if (state.contains(WidgetState.hovered)) {
                            return Colors.white;
                          }
                          return Colors.orange;
                        }),
                        foregroundColor: WidgetStateColor.resolveWith((state) {
                          if (state.contains(WidgetState.hovered)) {
                            return Colors.orange;
                          }
                          return Colors.white;
                        }),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                SizedBox(height: 8),
                if (_loginError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 40),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.redAccent[700]),
                        SizedBox(width: 8),
                        Text(
                          _loginError!,
                          style: TextStyle(
                            color: Colors.redAccent[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
