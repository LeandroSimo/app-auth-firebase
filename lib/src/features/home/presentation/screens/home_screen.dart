import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../posts/presentation/bloc/post_cubit.dart';
import '../../../posts/presentation/bloc/post_state.dart';
import '../../../posts/presentation/widgets/post_item.dart';
import '../../../posts/presentation/screens/post_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

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
                      radius: 20,
                      backgroundImage: state.user.photoURL != null
                          ? NetworkImage(state.user.photoURL!)
                          : null,
                      child: state.user.photoURL == null
                          ? Icon(Icons.person, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getUserDisplayName(state.user),
                      style: const TextStyle(
                        fontSize: 18,
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
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
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
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            postState.message,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Foto do Perfil',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPhotoOption(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Câmera',
                    onTap: () {
                      Navigator.pop(context);
                      _takePhoto();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Funcionalidade de câmera será implementada',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  _buildPhotoOption(
                    context,
                    icon: Icons.photo_library,
                    label: 'Galeria',
                    onTap: () {
                      Navigator.pop(context);
                      _pickFromGallery();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Funcionalidade de galeria será implementada',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  _buildPhotoOption(
                    context,
                    icon: Icons.delete,
                    label: 'Remover',
                    onTap: () {
                      Navigator.pop(context);
                      _removePhoto();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Funcionalidade de remoção será implementada',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _takePhoto() {
    // TODO: Implementar captura de foto com camera
    // ScaffoldMessenger será chamado no contexto do onTap
  }

  void _pickFromGallery() {
    // TODO: Implementar seleção de foto da galeria
    // ScaffoldMessenger será chamado no contexto do onTap
  }

  void _removePhoto() {
    // TODO: Implementar remoção de foto do perfil
    // ScaffoldMessenger será chamado no contexto do onTap
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
