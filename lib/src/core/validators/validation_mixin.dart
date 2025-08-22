/// Mixin que fornece métodos de validação para formulários
///
/// Contém validações para os campos implementados no app: email, senha, nome e confirmação de senha.
/// Para usar, aplique o mixin à classe State do seu widget:
///
/// ```dart
/// class _MyFormState extends State<MyForm> with ValidationMixin {
///   // ...
/// }
/// ```
mixin ValidationMixin {
  /// Valida se o email é válido e obrigatório
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email é obrigatório';
    }

    // Regex para validação de email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Digite um email válido';
    }

    return null;
  }

  /// Valida senha simples (mínimo 6 caracteres)
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }

    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }

    return null;
  }

  /// Valida confirmação de senha
  String? validatePasswordConfirmation(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Confirme sua senha';
    }

    if (value != originalPassword) {
      return 'Senhas não coincidem';
    }

    return null;
  }

  /// Valida nome completo
  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nome é obrigatório';
    }

    // Remove espaços extras e verifica se tem pelo menos 2 caracteres
    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }

    // Verifica se contém apenas letras e espaços
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(trimmedValue)) {
      return 'Nome deve conter apenas letras';
    }

    return null;
  }
}
