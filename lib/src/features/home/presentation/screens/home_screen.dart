import 'dart:io';
import 'package:app_test/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
// import '../../../profile/presentation/screens/profile_image_test_screen.dart';
import '../../../posts/presentation/bloc/post_cubit.dart';
import '../../../posts/presentation/bloc/post_state.dart';
import '../../../posts/presentation/widgets/post_item.dart';
import '../../../posts/presentation/screens/post_detail_screen.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/services/firebase_storage_service.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePickerService _imagePickerService = ImagePickerService();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  bool _isUploadingPhoto = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return Row(
                children: [
                  GestureDetector(
                    onTap: () => _showPhotoOptions(context),
                    child: CircleAvatar(
                      radius: context.mediaQuery.width * 0.05,
                      backgroundImage: state.user.photoURL != null
                          ? NetworkImage(state.user.photoURL!)
                          : null,
                      child: state.user.photoURL == null
                          ? Icon(Icons.person, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                  SizedBox(width: context.mediaQuery.width * 0.03),
                  Expanded(
                    child: Text(
                      _getUserDisplayName(state.user),
                      style: TextStyle(
                        fontSize: context.mediaQuery.width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }
            return const Text('Feed');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Implementar edição de perfil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edição de perfil em desenvolvimento'),
                ),
              );
            },
            tooltip: 'Editar Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return BlocBuilder<PostCubit, PostState>(
                builder: (context, postState) {
                  if (postState is PostLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (postState is PostLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        await context.read<PostCubit>().refreshPosts();
                      },
                      child: ListView.builder(
                        itemCount: postState.hasReachedMax
                            ? postState.posts.length
                            : postState.posts.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= postState.posts.length) {
                            // Indicador de carregamento no final da lista
                            return Padding(
                              padding: EdgeInsets.all(
                                context.mediaQuery.width * 0.04,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final post = postState.posts[index];

                          // Carregar mais posts quando próximo do final
                          if (index == postState.posts.length - 1 &&
                              !postState.hasReachedMax) {
                            context.read<PostCubit>().loadMorePosts();
                          }

                          return PostItem(
                            post: post,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PostDetailScreen(postId: post.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  } else if (postState is PostError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: context.mediaQuery.width * 0.16,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: context.mediaQuery.height * 0.02),
                          Text(
                            postState.message,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: context.mediaQuery.height * 0.02),
                          ElevatedButton(
                            onPressed: () {
                              context.read<PostCubit>().loadPosts();
                            },
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Estado inicial - carrega os posts
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<PostCubit>().loadPosts();
                    });
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  String _getUserDisplayName(user) {
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    // Se não tem displayName, pega a parte antes do @ do email
    final emailParts = user.email.split('@');
    return emailParts.isNotEmpty ? emailParts[0] : 'Usuário';
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.mediaQuery.width * 0.05),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(context.mediaQuery.width * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.mediaQuery.width * 0.1,
                height: context.mediaQuery.height * 0.005,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(
                    context.mediaQuery.width * 0.005,
                  ),
                ),
              ),
              SizedBox(height: context.mediaQuery.height * 0.025),
              Text(
                'Foto do Perfil',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: context.mediaQuery.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Câmera',
                    isLoading: _isUploadingPhoto,
                    onTap: _isUploadingPhoto
                        ? null
                        : () {
                            Navigator.pop(context);
                            _takePhoto();
                          },
                  ),
                  _buildPhotoOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    isLoading: _isUploadingPhoto,
                    onTap: _isUploadingPhoto
                        ? null
                        : () {
                            Navigator.pop(context);
                            _pickFromGallery();
                          },
                  ),
                  _buildPhotoOption(
                    context,
                    icon: Icons.delete,
                    label: 'Remover',
                    isLoading: _isUploadingPhoto,
                    onTap: _isUploadingPhoto
                        ? null
                        : () {
                            Navigator.pop(context);
                            _removePhoto();
                          },
                  ),
                ],
              ),
              SizedBox(height: context.mediaQuery.height * 0.025),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Column(
          children: [
            Container(
              width: context.mediaQuery.width * 0.15,
              height: context.mediaQuery.width * 0.15,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).primaryColor.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(
                  context.mediaQuery.width * 0.075,
                ),
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: context.mediaQuery.width * 0.075,
                        height: context.mediaQuery.width * 0.075,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: context.mediaQuery.width * 0.075,
                    ),
            ),
            SizedBox(height: context.mediaQuery.height * 0.01),
            Text(
              isLoading ? 'Processando...' : label,
              style: TextStyle(
                fontSize: context.mediaQuery.width * 0.03,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _takePhoto() async {
    if (_isUploadingPhoto) return;

    try {
      setState(() {
        _isUploadingPhoto = true;
      });

      final imageFile = await _imagePickerService.pickImageFromCamera();
      if (imageFile != null) {
        await _uploadProfilePhoto(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao capturar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  void _pickFromGallery() async {
    if (_isUploadingPhoto) return;

    try {
      setState(() {
        _isUploadingPhoto = true;
      });

      final imageFile = await _imagePickerService.pickImageFromGallery();
      if (imageFile != null) {
        await _uploadProfilePhoto(imageFile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  Future<void> _uploadProfilePhoto(File imageFile) async {
    try {
      // Primeiro verifica se o Storage está configurado
      final isStorageConnected = await _storageService.checkStorageConnection();
      if (!isStorageConnected) {
        throw Exception('Firebase Storage não está configurado corretamente');
      }

      // Faz upload da imagem para o Firebase Storage
      final photoURL = await _storageService.uploadProfilePhoto(imageFile);

      // Atualiza o perfil do usuário no Firebase Auth
      if (mounted) {
        await context.read<AuthCubit>().updateUserPhotoURL(photoURL);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto do perfil atualizada com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Erro ao atualizar foto do perfil';

        // Personaliza a mensagem baseada no tipo de erro
        final errorString = e.toString();
        if (errorString.contains('Storage não está configurado')) {
          errorMessage =
              'Firebase Storage não configurado. Verifique as configurações.';
        } else if (errorString.contains('Sem permissão')) {
          errorMessage =
              'Sem permissão para fazer upload. Verifique as regras do Storage.';
        } else if (errorString.contains('Timeout')) {
          errorMessage = 'Upload demorou muito. Tente novamente.';
        } else if (errorString.contains('não está logado')) {
          errorMessage = 'Usuário não está logado. Faça login novamente.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage),
                const SizedBox(height: 4),
                Text(
                  'Detalhes: ${e.toString()}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    }
  }

  void _removePhoto() async {
    if (_isUploadingPhoto) return;

    try {
      setState(() {
        _isUploadingPhoto = true;
      });

      // Remove a foto do perfil (define como null/vazio)
      if (mounted) {
        await context.read<AuthCubit>().updateUserPhotoURL('');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto do perfil removida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover foto do perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Deseja realmente sair?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sair'),
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthCubit>().signOut();
              },
            ),
          ],
        );
      },
    );
  }
}
