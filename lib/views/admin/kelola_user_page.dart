import 'package:flutter/material.dart';
import '../../databases/db_helper.dart';
import '../../models/users.dart';
import '../../components/custom_snackbar.dart';
import '../../components/custom_alert_dialog.dart';
import '../../components/user_form_dialog.dart';

class KelolaUserPage extends StatefulWidget {
  const KelolaUserPage({super.key});

  @override
  State<KelolaUserPage> createState() => _KelolaUserPageState();
}

class _KelolaUserPageState extends State<KelolaUserPage> {
  final DbHelper db = DbHelper();
  List<Users> _usersList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final result = await db.getAllUsers();
    setState(() {
      _usersList = result;
      _isLoading = false;
    });
  }

  Future<void> _saveUser(Users? user) async {
    await showDialog(
      context: context,
      builder: (context) {
        return UserFormDialog(
          user: user,
          onSubmit: (newUser) async {
            if (user == null) {
              await db.insertUsers(newUser);
            } else {
              await db.updateUsers(newUser);
            }
            await _loadUsers();
            showCustomSnackbar(context: context, message: '${user == null ? 'User berhasil ditambah' : 'User berhasil diperbarui'}!');
          },
        );
      },
    );
  }

  Future<void> _deleteUser(Users users) async {
    await db.deleteUsers(users.id!);

    // refresh daftar user
    await _loadUsers();
    showCustomSnackbar(
      context: context,
      message: '${users.username} berhasil dihapus',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _usersList.isEmpty
        ? Center(
          child: Text(
            'Belum ada data user',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        )
        : Padding(
          padding: EdgeInsets.all(12.0),
          child: ListView.separated(
            itemCount: _usersList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final user = _usersList[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 12,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(user.role == 'admin' ? Icons.admin_panel_settings : Icons.person, size: 40),
                ),
                title: Text(
                  user.username,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  user.role,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[700],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                      tooltip: 'Edit',
                      onPressed: () => _saveUser(user),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      tooltip: 'Hapus',
                      onPressed: () => _showDeleteConfirmation(user),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _saveUser(null),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          child: const Icon(Icons.person_add),
        ),
    );
  }

  void _showDeleteConfirmation(Users users) {
    customAlertDialog(
      context: context,
      title: 'Hapus User',
      content: 'Anda yakin ingin menghapus ${users.username} dari daftar user?',
      onConfirm: () => _deleteUser(users),
    );
  }
}
