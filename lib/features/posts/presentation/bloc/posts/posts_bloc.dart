import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/strings/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/post.dart';
import '../../../domain/usecases/get_all_posts.dart';

part 'posts_event.dart';
part 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {

  static PostsBloc get(BuildContext context) => BlocProvider.of<PostsBloc>(context,listen: false);

  final GetAllPostsUsecase getAllPosts;
  PostsBloc({

    required this.getAllPosts,
  }) : super(PostsInitial()) {

/// way 1 ;
    on<PostsEvent>((event, emit) async {
      if (event is GetAllPostsEvent) {
        emit(LoadingPostsState());
        final failureOrPosts = await getAllPosts();
        emit(_mapFailureOrPostsToState(failureOrPosts));
      } else if (event is RefreshPostsEvent) {
        emit(LoadingPostsState());

        final failureOrPosts = await getAllPosts();
        emit(_mapFailureOrPostsToState(failureOrPosts));
      }
    });
  }

  PostsState _mapFailureOrPostsToState(Either<Failure, List<Post>> either) {
    return either.fold(
      (failure) => ErrorPostsState(message: _mapFailureToMessage(failure)),
      (posts) => LoadedPostsState(
        posts: posts,
      ),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case EmptyCacheFailure:
        return EMPTY_CACHE_FAILURE_MESSAGE;
      case OfflineFailure:
        return OFFLINE_FAILURE_MESSAGE;
      default:
        return "Unexpected Error , Please try again later .";
    }
  }


/// way 2 :
//   @override
//   Stream<PostsState> mapEventToState(
//       PostsEvent event,
//       Either<Failure, List<Post>> either,
//       ) async* {
//     if (event is GetAllPostsEvent) {
//       // yield ExampleLoadingState();
//       yield await _mapFailureOrPostsToState(either);
//     }
//   }

  // 1
  // Future<ExampleState> getExample() async {
  //   late ExampleState exampleState;
  //   Either<Failure, ExampleEntity> failureOrExample = await _exampleUseCase();
  //   failureOrExample.fold((l) {
  //     if (l == ServerFailure()) {
  //       exampleState = const ExampleErrorState(error: AppConstants.errorOccurred);
  //     } else if (l == AuthFailure()) {
  //       exampleState = const ExampleErrorState(error: AppStrings.noAuth);
  //     } else if (l == InternetFailure()) {
  //       exampleState = const ExampleInternetState(error: AppStrings.noInternet);
  //     } else {
  //       exampleState = const ExampleErrorState(error: AppConstants.errorOccurred);
  //     }
  //   }, (r) {
  //     exampleState = ExampleSuccessState(exampleEntity: r);
  //   });
  //   return exampleState;
  // }

}
