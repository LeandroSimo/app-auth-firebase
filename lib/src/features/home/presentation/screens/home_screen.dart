import 'package:app_test/src/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../posts/presentation/bloc/post_cubit.dart';
import '../../../posts/presentation/bloc/post_state.dart';
import '../../../posts/presentation/widgets/post_item.dart';
import '../../../../core/routes/app_routes.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Carrega os posts sempre que a home screen for inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostCubit>().loadPosts();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recarrega os posts quando o app voltar do background
      context.read<PostCubit>().refreshPosts();
    }
  }

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
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.profile,
                        arguments: state.user.uid,
                      );
                    },
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
                        itemCount:
                            postState.posts.length +
                            (postState.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          // Se chegou no final da lista e não chegou no máximo
                          if (index >= postState.posts.length) {
                            return Padding(
                              padding: EdgeInsets.all(
                                context.mediaQuery.width * 0.04,
                              ),
                              child: Center(
                                child: Column(
                                  children: [
                                    const CircularProgressIndicator(),
                                    SizedBox(
                                      height: context.mediaQuery.height * 0.01,
                                    ),
                                    Text(
                                      'Carregando...',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final post = postState.posts[index];

                          // Carregar mais posts quando chegar no último post da página atual
                          // (múltiplos de 10: 9, 19, 29, etc - já que index começa em 0)
                          if ((index + 1) % 10 == 0 &&
                              index == postState.posts.length - 1 &&
                              !postState.hasReachedMax &&
                              !postState.isLoadingMore) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              context.read<PostCubit>().loadMorePosts();
                            });
                          }

                          return PostItem(
                            post: post,
                            onTap: () async {
                              final postCubit = context.read<PostCubit>();
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.postDetail,
                                arguments: post.id,
                              );
                              // Recarrega os posts quando voltar da tela de detalhes
                              if (mounted) {
                                postCubit.refreshPosts();
                              }
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
                    // Estado inicial - mostra indicador de carregamento
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
