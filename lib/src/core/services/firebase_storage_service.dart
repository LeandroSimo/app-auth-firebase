import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Faz upload da foto do perfil do usuário
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não está logado');
      }

      // Verifica se o arquivo existe
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      // Cria referência para o arquivo no Storage com regras de segurança mais simples
      final fileName = 'profile_${user.uid}.jpg';
      final ref = _storage.ref('profile_photos/$fileName');

      // Configura metadados para o upload
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': user.uid,
          'uploadTime': DateTime.now().toIso8601String(),
        },
      );

      // Faz upload do arquivo com timeout
      final uploadTask = ref.putFile(imageFile, metadata);

      // Adiciona listener para acompanhar o progresso
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        debugPrint('Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      final snapshot = await uploadTask.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw Exception('Timeout no upload da imagem'),
      );

      // Obtém a URL de download
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Upload concluído: $downloadUrl');

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('Firebase Storage Error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'storage/unauthorized':
          throw Exception('Sem permissão para fazer upload de imagens');
        case 'storage/canceled':
          throw Exception('Upload cancelado');
        case 'storage/unknown':
          throw Exception('Erro desconhecido no Firebase Storage');
        case 'storage/object-not-found':
          throw Exception('Arquivo não encontrado no Storage');
        case 'storage/bucket-not-found':
          throw Exception('Bucket do Storage não configurado');
        case 'storage/project-not-found':
          throw Exception('Projeto Firebase não encontrado');
        case 'storage/quota-exceeded':
          throw Exception('Cota do Storage excedida');
        case 'storage/unauthenticated':
          throw Exception('Usuário não autenticado');
        case 'storage/retry-limit-exceeded':
          throw Exception('Muitas tentativas de upload');
        default:
          throw Exception('Erro no Firebase Storage: ${e.message}');
      }
    } catch (e) {
      debugPrint('Upload Error: $e');
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Remove a foto anterior do perfil (opcional)
  Future<void> deleteProfilePhoto(String photoUrl) async {
    try {
      if (photoUrl.isEmpty) return;

      // Extrai o caminho do arquivo da URL
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      debugPrint('Foto anterior removida: $photoUrl');
    } on FirebaseException catch (e) {
      // Ignora erros específicos que não são críticos
      if (e.code == 'storage/object-not-found') {
        debugPrint('Foto anterior não encontrada (normal)');
      } else {
        debugPrint(
          'Aviso: Não foi possível excluir a foto anterior: ${e.message}',
        );
      }
    } catch (e) {
      debugPrint('Aviso: Erro ao excluir foto anterior: $e');
    }
  }

  /// Verifica se o Firebase Storage está configurado corretamente
  Future<bool> checkStorageConnection() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Tenta listar arquivos na pasta do usuário para verificar conectividade
      final ref = _storage.ref('profile_photos');
      await ref.listAll();
      return true;
    } catch (e) {
      debugPrint('Storage connection check failed: $e');
      return false;
    }
  }
}

void debugPrint(String message) {
  // Usando print temporariamente para debug
  // Em produção, usar um logger apropriado
  // ignore: avoid_print
  print('[FirebaseStorage] $message');
}
