import 'package:budgeit/domain/icons/usecases/getIcons.dart';
import 'package:budgeit/presentation/icons/bloc/icons_state.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/helper/message/Failure.dart';
import '../../../domain/categories/usecase/add_category.dart';

class IconsCubit extends Cubit<IconsState> {
  IconsCubit() : super(IconsInitial());

  void loadIcons(String collection) async {
    emit(IconsLoading());
    final Either<String, List<String>> result =
    await sl<GetIconsUseCase>().call(params: collection);
    result.fold(
          (failure) => emit(IconsError(failure)),
          (icons) => emit(IconsLoaded(icons: icons, filteredIcons: icons)),
    );
  }

  void selectIcon(String iconUrl) {
    if (state is IconsLoaded) {
      final currentState = state as IconsLoaded;
      emit(IconsLoaded(
        icons: currentState.icons,
        filteredIcons: currentState.filteredIcons,
        selectedIcon: iconUrl,
        searchQuery: currentState.searchQuery,
      ));
    }
  }

  void searchIcons(String query) {
    if (state is IconsLoaded) {
      final currentState = state as IconsLoaded;
      final filteredIcons = query.isEmpty
          ? currentState.icons
          : currentState.icons
          .where((icon) => icon.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(IconsLoaded(
        icons: currentState.icons,
        filteredIcons: filteredIcons,
        selectedIcon: currentState.selectedIcon,
        searchQuery: query,
      ));
    }
  }

  Future<void> addCategory({
    required int userId,
    required String name,
    required String icon,
    required String accessToken,
    required int type,
  }) async {
    if (state is IconsLoaded) {
      // Preserve the current IconsLoaded state before emitting IconsLoading
      final currentState = state as IconsLoaded;
      emit(IconsLoading());

      final params = AddCategoryParams(
        userId: userId,
        name: name,
        icon: icon,
        type: type,
        accessToken: accessToken,
      );
      final Either<Failure, String> result = await sl<AddCategoryUseCase>().call(params: params);
      result.fold(
            (failure) => emit(IconsError(failure.message)),
            (success) => emit(IconsLoaded(
          icons: currentState.icons, // Use preserved state
          filteredIcons: currentState.filteredIcons, // Use preserved state
          selectedIcon: null,
          searchQuery: currentState.searchQuery, // Use preserved state
          message: success,
        )),
      );
    }
  }
}