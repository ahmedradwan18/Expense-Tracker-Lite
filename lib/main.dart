import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/constants/app_constants.dart';
import 'core/network/network_info.dart';
import 'core/di/injection_container.dart' as di;


// Data layer imports
import 'features/dashboard/data/models/expense_model.dart';
import 'features/dashboard/data/datasources/expense_local_data_source.dart';
import 'features/dashboard/data/repositories/expense_repository_impl.dart';
import 'features/add_expense/data/models/exchange_rate_model.dart';
import 'features/add_expense/data/datasources/currency_local_data_source.dart';
import 'features/add_expense/data/datasources/currency_remote_data_source.dart';
import 'features/add_expense/data/repositories/currency_repository_impl.dart';

// Domain layer imports
import 'features/dashboard/domain/repositories/expense_repository.dart';
import 'features/dashboard/domain/usecases/get_expenses.dart';
import 'features/add_expense/domain/repositories/currency_repository.dart';
import 'features/add_expense/domain/usecases/add_expense.dart';

// Presentation layer imports
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_event.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/add_expense/presentation/pages/add_expense_page.dart';
import 'features/add_expense/presentation/bloc/add_expense_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize dependencies
  await di.init();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) {
              debugPrint('🔄 Creating new DashboardBloc and loading data...');
              return di.sl<DashboardBloc>()..add(const LoadDashboardData());
            },
            child: const DashboardPage(),
          ),
          transitionType: TransitionType.slideFromBottom,
        ),
      ),
      GoRoute(
        path: '/add-expense',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: BlocProvider(
            create: (context) => di.sl<AddExpenseBloc>(),
            child: const AddExpensePage(),
          ),
          transitionType: TransitionType.slideFromRight,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(AppConstants.primaryColor),
            ),
            useMaterial3: true,
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

enum TransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  slideFromTop,
  fade,
  scale,
  rotation,
}

class CustomTransitionPage extends CustomTransitionPageBase {
  final TransitionType transitionType;

  const CustomTransitionPage({
    required super.key,
    required super.child,
    required this.transitionType,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (transitionType) {
      case TransitionType.slideFromRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: child,
        );
      case TransitionType.slideFromLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: child,
        );
      case TransitionType.slideFromBottom:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: child,
        );
      case TransitionType.slideFromTop:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: child,
        );
      case TransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutBack,
          )),
          child: child,
        );
      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);
}

abstract class CustomTransitionPageBase extends Page {
  const CustomTransitionPageBase({
    required super.key,
    required this.child,
  });

  final Widget child;

  Duration get transitionDuration => const Duration(milliseconds: 300);
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  );

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: transitionDuration,
      reverseTransitionDuration: reverseTransitionDuration,
      transitionsBuilder: buildTransitions,
    );
  }
}
