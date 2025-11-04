import 'package:flutter/material.dart';

class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  
  const EditProfileDialog({
    super.key,
    required this.currentName,
    required this.currentEmail,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String email;
  String? password;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    name = widget.currentName;
    email = widget.currentEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Editar Perfil', 
                    style: Theme.of(context).textTheme.titleLarge
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                      onSaved: (value) => name = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: email,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu email';
                        }
                        if (!value.contains('@')) {
                          return 'Por favor ingresa un email válido';
                        }
                        return null;
                      },
                      onSaved: (value) => email = value!,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña (opcional)',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                      onSaved: (value) => password = value,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Retornar los nuevos datos
                        Navigator.pop(context, {
                          'name': name,
                          'email': email,
                          if (password != null && password!.isNotEmpty)
                            'password': password,
                        });
                      }
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}