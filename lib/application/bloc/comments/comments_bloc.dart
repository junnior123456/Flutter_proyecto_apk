import 'package:flutter_bloc/flutter_bloc.dart';
import 'comments_event.dart';
import 'comments_state.dart';

class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  CommentsBloc() : super(const CommentsInitial()) {
    on<FetchCommentsByPet>(_onFetchComments);
    on<CreateComment>(_onCreateComment);
    on<UpdateComment>(_onUpdateComment);
    on<DeleteComment>(_onDeleteComment);
    on<RefreshComments>(_onRefreshComments);
  }

  Future<void> _onFetchComments(
    FetchCommentsByPet event,
    Emitter<CommentsState> emit,
  ) async {
    emit(const CommentsLoading());
    try {
      // TODO: Implement actual API call to CommentsService
      // final comments = await commentsService.getCommentsByPetId(event.petId);
      emit(const CommentsLoaded([]));
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }

  Future<void> _onCreateComment(
    CreateComment event,
    Emitter<CommentsState> emit,
  ) async {
    try {
      // TODO: Implement actual API call
      // final comment = await commentsService.createComment(
      //   petId: event.petId,
      //   userId: event.userId,
      //   text: event.text,
      // );
      // emit(CommentCreated(comment));
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }

  Future<void> _onUpdateComment(
    UpdateComment event,
    Emitter<CommentsState> emit,
  ) async {
    try {
      // TODO: Implement actual API call
      // final comment = await commentsService.updateComment(
      //   commentId: event.commentId,
      //   text: event.text,
      // );
      // emit(CommentUpdated(comment));
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }

  Future<void> _onDeleteComment(
    DeleteComment event,
    Emitter<CommentsState> emit,
  ) async {
    try {
      // TODO: Implement actual API call
      // await commentsService.deleteComment(event.commentId);
      // emit(CommentDeleted(event.commentId));
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }

  Future<void> _onRefreshComments(
    RefreshComments event,
    Emitter<CommentsState> emit,
  ) async {
    emit(const CommentsLoading());
    try {
      // TODO: Implement refresh logic
      emit(const CommentsLoaded([]));
    } catch (e) {
      emit(CommentsError(e.toString()));
    }
  }
}
