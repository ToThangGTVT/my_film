import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../feature/home/cubit/movie_download/movie_download_cubit.dart';
import '../feature/home/cubit/movie_download/movie_download_state.dart';

class LoadingCircle extends StatelessWidget {
  const LoadingCircle ({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocBuilder<MovieDownloadCubit, MovieDownloadState>(
      builder: (context, state) {
        return Text(state.progress.toString());
      });
  }
}
