import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../databases/db_helper.dart';
import '../models/users.dart';

class UserFormDialog extends StatefulWidget {
  final Users? user;
  final Function(Users user) onSubmit;

  const UserFormDialog({super.key, this.user, required this.onSubmit});

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final DbHelper db = DbHelper();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  String _role = 'kasir';

  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user?.username);
    _passwordController = TextEditingController();
    _role = widget.user?.role ?? 'kasir';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset(
                widget.user == null
                    ? 'assets/lottie/person.json'
                    : 'assets/lottie/edit.json',
                height: 110,
              ),
              SizedBox(height: 12),
              Text(
                widget.user == null ? 'Tambah User' : 'Edit User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelStyle: TextStyle(color: Colors.black54),
                        errorText: _usernameError,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText:
                            widget.user == null
                                ? 'Password'
                                : 'Ubah Password (opsional)',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelStyle: TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (widget.user == null &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Password wajib diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Role: $_role',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Batal',
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: Icon(Icons.save),
                          label: Text(
                            widget.user == null ? 'Tambah' : 'Simpan',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              _usernameError = null; // reset error sebelum validasi
                            });

                            if (_formKey.currentState!.validate()) {
                              final _username = _usernameController.text.trim();
                              final _password = _passwordController.text;

                              final isTaken = await db.isUsernameTaken(
                                _username, 
                                excludeId: widget.user?.id
                              );

                              if (isTaken) {
                                setState(() {
                                  _usernameError = 'Username $_username sudah digunakan';
                                });
                                return;
                              }

                              final newUser = Users(
                                id: widget.user?.id ?? DateTime.now().millisecond, // Generate a unique ID if it's a new user
                                username: _username,
                                password: widget.user?.password ?? _password,
                                role: _role,
                              );
                              widget.onSubmit(newUser);
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
