import 'package:budgeit/common/bloc/session/session_cubit.dart';
import 'package:budgeit/core/constant/api_url.dart';
import 'package:budgeit/core/network/dio_client.dart';
import 'package:budgeit/data/auth/repositories/auth.dart';
import 'package:budgeit/data/auth/sources/auth_api_services.dart';
import 'package:budgeit/data/budget/repositories/budget.dart';
import 'package:budgeit/data/budget/services/budget_api_service.dart';
import 'package:budgeit/data/categories/repositories/category.dart';
import 'package:budgeit/data/categorystream/repositories/category_stream.dart';
import 'package:budgeit/data/categorystream/services/categorystream_api_services.dart';
import 'package:budgeit/data/icons/repositories/icons.dart';
import 'package:budgeit/data/icons/sources/icons_api_service.dart';
import 'package:budgeit/domain/auth/repositories/auth.dart';
import 'package:budgeit/domain/auth/usecases/refresh_token.dart';
import 'package:budgeit/domain/auth/usecases/signin.dart';
import 'package:budgeit/domain/auth/usecases/signout.dart';
import 'package:budgeit/domain/auth/usecases/signup.dart';
import 'package:budgeit/domain/auth/usecases/udpate_user.dart';
import 'package:budgeit/domain/budget/repositories/budget.dart';
import 'package:budgeit/domain/budget/usecase/deleteBudget.dart';
import 'package:budgeit/domain/budget/usecase/getBudgetsByUserId.dart';
import 'package:budgeit/domain/budget/usecase/setBudget.dart';
import 'package:budgeit/domain/budget/usecase/updateBudget.dart';
import 'package:budgeit/domain/categories/usecase/delete_category.dart';
import 'package:budgeit/domain/categories/usecase/get_category_by_id.dart';
import 'package:budgeit/domain/categories/usecase/update_category.dart';
import 'package:budgeit/domain/categorystream/repositories/category_stream.dart';
import 'package:budgeit/domain/categorystream/usecase/add_stream.dart';
import 'package:budgeit/domain/categorystream/usecase/delete_stream.dart';
import 'package:budgeit/domain/categorystream/usecase/edit_stream.dart';
import 'package:budgeit/domain/categorystream/usecase/get_by_date_category_stream.dart';
import 'package:budgeit/domain/categorystream/usecase/get_by_date_range_category_stream.dart';
import 'package:budgeit/domain/icons/repositories/icons.dart';
import 'package:budgeit/domain/icons/usecases/getIcons.dart';
import 'package:budgeit/domain/reports/usecase/analyzeMoneyFlowByDateRange.dart';
import 'package:budgeit/presentation/auth_page/bloc/auth/auth_cubit.dart';
import 'package:budgeit/presentation/auth_page/bloc/department/department_cubit.dart';
import 'package:budgeit/presentation/budget/bloc/budget/budget_cubit.dart';
import 'package:budgeit/presentation/budget/bloc/setBudget/set_budget_cubit.dart';
import 'package:budgeit/presentation/calendar/bloc/calendar_cubit.dart';
import 'package:budgeit/presentation/categories/bloc/educationalExpense/educationalexpense_cubit.dart';
import 'package:budgeit/presentation/categories/bloc/income/income_cubit.dart';
import 'package:budgeit/presentation/categories/bloc/personalExpense/myexpense_cubit.dart';
import 'package:budgeit/presentation/icons/bloc/icons_cubit.dart';
import 'package:budgeit/presentation/profile/bloc/profile_cubit.dart';
import 'package:budgeit/presentation/reports/bloc/reports_cubit.dart';
import 'package:budgeit/presentation/streams/bloc/streams_cubit.dart';
import 'package:get_it/get_it.dart';

import 'package:budgeit/data/categories/services/categoty_api_services.dart';
import 'package:budgeit/data/reports/repositories/ai.dart';
import 'package:budgeit/data/reports/sources/ai_api_service.dart';
import 'package:budgeit/domain/categories/repositories/category.dart';
import 'package:budgeit/domain/categories/usecase/add_category.dart';
import 'package:budgeit/domain/categorystream/usecase/get_category_streams_by_id.dart';
import 'package:budgeit/domain/categorystream/usecase/get_daily_category_streams.dart';
import 'package:budgeit/domain/reports/repositories/ai_repository.dart';

import 'domain/auth/usecases/confirm_email.dart';
import 'domain/auth/usecases/request_confirmation.dart';
import 'domain/auth/usecases/request_reset.dart';
import 'domain/auth/usecases/reset_password.dart';
import 'domain/auth/usecases/verify_reset_codes.dart';
import 'domain/reports/usecase/analyzeMoneyFlowByDate.dart';

final sl = GetIt.instance;

void setupServiceLocator(){
  sl.registerSingleton<DioClient>(DioClient(IconsApi.iconsBaseUrl), instanceName: 'iconsClient');
  sl.registerSingleton<DioClient>(DioClient(ApiUrl.baseUrl), instanceName: 'apiUrl');

  //Services
  sl.registerSingleton<IconsApiService>(IconsApiServiceImpl());
  sl.registerSingleton<AuthApiService>(AuthApiServiceImpl());
  sl.registerSingleton<CategoryApiService>(CategoryApiServiceImpl());
  sl.registerSingleton<CategoryStreamApiService>(CategoryStreamApiServiceImpl());
  sl.registerSingleton<BudgetApiService>(BudgetApiServiceImpl());
  sl.registerSingleton<AiApiService>(AiApiServiceImpl());

  //Repositories
  sl.registerSingleton<IconsRepository>(IconsRepositoryImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  sl.registerSingleton<CategoryRepository>(CategoryRepositoryImpl());
  sl.registerSingleton<CategoryStreamRepository>(CategoryStreamRepositoryImpl());
  sl.registerSingleton<BudgetRepository>(BudgetRepositoryImpl());
  sl.registerSingleton<AiRepository>(AiRepositoryImpl());

  //Cubit LazyLoad
  sl.registerLazySingleton<IconsCubit>(() => IconsCubit());
  sl.registerLazySingleton<AddIncomeCubit>(() => AddIncomeCubit());
  sl.registerLazySingleton<EducationalExpenseCubit>(() => EducationalExpenseCubit());
  sl.registerLazySingleton<PersonalExpenseCubit>(() => PersonalExpenseCubit());
  sl.registerLazySingleton<CategoryStreamCubit>(() => CategoryStreamCubit());
  sl.registerLazySingleton<EditStreamCubit>(() => EditStreamCubit());
  sl.registerLazySingleton<SetBudgetCubit>(() => SetBudgetCubit());
  sl.registerLazySingleton<ReportsCubit>(() => ReportsCubit());
  sl.registerLazySingleton<BudgetCubit>(() => BudgetCubit());
  //Cubit
  sl.registerFactory(() => AuthCubit());
  sl.registerFactory(() => SessionCubit());
  sl.registerFactory(() => DepartmentCubit());
  sl.registerFactory(() => ProfileCubit());
  //UseCase
  sl.registerSingleton<GetIconsUseCase>(GetIconsUseCase());
  sl.registerSingleton<SignInUseCase>(SignInUseCase());
  sl.registerSingleton<SignUpUseCase>(SignUpUseCase());
  sl.registerSingleton<SignOutUseCase>(SignOutUseCase());
  sl.registerSingleton<RefreshTokenUseCase>(RefreshTokenUseCase());
  sl.registerSingleton<AddCategoryUseCase>(AddCategoryUseCase());
  sl.registerSingleton<DeleteCategoryUseCase>(DeleteCategoryUseCase());
  sl.registerSingleton<UpdateCategoryUseCase>(UpdateCategoryUseCase());
  sl.registerSingleton<GetCategoriesByIdUseCase>(GetCategoriesByIdUseCase());
  sl.registerSingleton<AddStreamUseCase>(AddStreamUseCase());
  sl.registerSingleton<DeleteStreamUseCase>(DeleteStreamUseCase());
  sl.registerSingleton<EditStreamUseCase>(EditStreamUseCase());
  sl.registerSingleton<GetCategoryStreamsByIdUseCase>(GetCategoryStreamsByIdUseCase());
  sl.registerSingleton<GetDailyCategoryStreamsByIdUseCase>(GetDailyCategoryStreamsByIdUseCase());
  sl.registerSingleton<GetByDateCategoryStreamsByIdUseCase>(GetByDateCategoryStreamsByIdUseCase());
  sl.registerSingleton<GetByDateRangeCategoryStreamUseCase>(GetByDateRangeCategoryStreamUseCase());
  sl.registerSingleton<GetBudgetsByUserIdUseCase>(GetBudgetsByUserIdUseCase());
  sl.registerSingleton<SetBudgetUseCase>(SetBudgetUseCase());
  sl.registerSingleton<UpdateBudgetUseCase>(UpdateBudgetUseCase());
  sl.registerSingleton<DeleteBudgetUseCase>(DeleteBudgetUseCase());
  sl.registerSingleton<AnalyzeMoneyFlowByDateRangeUseCase>(AnalyzeMoneyFlowByDateRangeUseCase());
  sl.registerSingleton<AnalyzeMoneyFlowByDateUseCase>(AnalyzeMoneyFlowByDateUseCase());
  sl.registerSingleton<ConfirmEmailUseCase>(ConfirmEmailUseCase());
  sl.registerSingleton<RequestConfirmationUseCase>(RequestConfirmationUseCase());
  sl.registerSingleton<RequestResetUseCase>(RequestResetUseCase());
  sl.registerSingleton<ResetPasswordUseCase>(ResetPasswordUseCase());
  sl.registerSingleton<VerifyResetCodeUseCase>(VerifyResetCodeUseCase());
  sl.registerSingleton<UpdateUserUseCase>(UpdateUserUseCase());
}