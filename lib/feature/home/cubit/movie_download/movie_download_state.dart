import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';

part 'movie_download_state.g.dart';

enum MovieDownloadStatus { init, loading, success, error }

@CopyWith()
class MovieDownloadState extends Equatable {

  const MovieDownloadState(this.progress);

  final int progress ;

  @override
  // TODO: implement props
  List<Object?> get props => [progress];
}