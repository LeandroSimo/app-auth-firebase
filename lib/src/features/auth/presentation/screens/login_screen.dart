import 'package:app_test/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../../../../core/validators/validation_mixin.dart';
import '../../../../core/routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      context.read<AuthCubit>().clearError();
                    },
                  ),
                ),
              );
            } else if (state is AuthAuthenticated) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
            }
          },
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.all(context.mediaQuery.width * 0.06),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: context.mediaQuery.width * 0.2,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.04),
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.04),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: validateEmail,
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.02),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      validator: validatePassword,
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.03),
                    SizedBox(
                      width: double.infinity,
                      height: context.mediaQuery.height * 0.06,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading ? null : _login,
                        child: state is AuthLoading
                            ? SizedBox(
                                height: context.mediaQuery.height * 0.025,
                                width: context.mediaQuery.height * 0.025,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Entrar'),
                      ),
                    ),
                    SizedBox(height: context.mediaQuery.height * 0.02),
                    TextButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.register);
                            },
                      child: const Text('Não tem conta? Cadastre-se'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}
