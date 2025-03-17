abstract class IconsState {}

class IconsInitial extends IconsState {}

class IconsLoading extends IconsState {}

class IconsLoaded extends IconsState {
  final List<String> icons;
  final List<String> filteredIcons;
  final String? selectedIcon;
  final String? searchQuery;
  final String? message; // Add this to show success feedback

  IconsLoaded({
    required this.icons,
    required this.filteredIcons,
    this.selectedIcon,
    this.searchQuery,
    this.message,
  });
}

class IconsError extends IconsState {
  final String message;

  IconsError(this.message);
}