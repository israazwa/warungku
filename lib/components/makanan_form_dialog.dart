import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/makanan.dart';

class MakananFormDialog extends StatefulWidget {
  final Makanan? makanan;
  final Function(Makanan) onSubmit;

  const MakananFormDialog({super.key, this.makanan, required this.onSubmit});

  @override
  State<MakananFormDialog> createState() => _MakananFormDialogState();
}

class _MakananFormDialogState extends State<MakananFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _daerahController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
  late TextEditingController _deskripsiController;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.makanan?.nama);
    _daerahController = TextEditingController(text: widget.makanan?.daerah);
    _hargaController = TextEditingController(text: widget.makanan?.harga.toString());
    _stokController = TextEditingController(text: widget.makanan?.stok.toString());
    _deskripsiController = TextEditingController(text: widget.makanan?.deskripsi);
    if (widget.makanan?.gambar != null && widget.makanan!.gambar.isNotEmpty) {
      _imageFile = XFile(widget.makanan!.gambar);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeri'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kamera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Lottie.asset(
                widget.makanan == null
                    ? 'assets/lottie/person.json'
                    : 'assets/lottie/edit.json',
                height: 110,
              ),
              const SizedBox(height: 12),
              Text(
                widget.makanan == null ? 'Tambah Makanan' : 'Edit Makanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showPicker(context),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _imageFile == null
                                ? const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Pilih Gambar', style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_imageFile!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          if (_imageFile == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Gambar wajib diisi',
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Makanan',
                        prefixIcon: const Icon(Icons.fastfood),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelStyle: const TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama makanan wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _daerahController,
                      decoration: InputDecoration(
                        labelText: 'Asal Daerah',
                        prefixIcon: const Icon(Icons.location_city),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelStyle: const TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Daerah wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga',
                        prefixIcon: const Icon(Icons.monetization_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelStyle: const TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harga wajib diisi';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Harga harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stokController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stok',
                        prefixIcon: const Icon(Icons.inventory),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelStyle: const TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Stok wajib diisi';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Stok harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelStyle: const TextStyle(color: Colors.black54),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
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
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          label: Text(
                            widget.makanan == null ? 'Tambah' : 'Simpan',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate() && _imageFile != null) {
                              String imagePath = _imageFile!.path;

                              bool imageChanged = widget.makanan == null || widget.makanan!.gambar != _imageFile!.path;

                              if (imageChanged) {
                                final appDir = await getApplicationDocumentsDirectory();
                                final fileName = path.basename(_imageFile!.path);
                                final savedImage = await File(_imageFile!.path).copy('${appDir.path}/$fileName');
                                imagePath = savedImage.path;
                              }

                              final newMakanan = Makanan(
                                id: widget.makanan?.id,
                                nama: _namaController.text,
                                daerah: _daerahController.text,
                                harga: double.parse(_hargaController.text),
                                stok: int.parse(_stokController.text),
                                deskripsi: _deskripsiController.text,
                                gambar: imagePath,
                              );
                              widget.onSubmit(newMakanan);
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
