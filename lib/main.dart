import 'package:doctor_booking_app_with_flutter/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'repositories/doctor_repository.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'shared/theme/app_theme.dart';
import 'state/home/authentication_bloc.dart';
import 'state/home/home_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final doctorRepository = DoctorRepository();
  runApp(MyApp(doctorRepository: doctorRepository));
}

class MyApp extends StatelessWidget {
  final DoctorRepository doctorRepository;

  const MyApp({Key? key, required this.doctorRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: doctorRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthenticationBloc>(
            create: (context) => AuthenticationBloc(),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(doctorRepository: doctorRepository)..add(LoadHomeData()), // Initialize and add LoadHomeData event
          ),
        ],
        child: MaterialApp(
          title: 'Your App',
          theme: AppTheme().themeData,
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return BlocProvider<HomeBloc>.value(
                  value: BlocProvider.of<HomeBloc>(context),
                  child: const HomeScreen(),
                );
              } else if (state is Unauthenticated) {
                return state.showLogin ? LoginPage() : SignupPage();
              } else {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
          debugShowCheckedModeBanner: false,
          routes: {
            '/home': (context) => BlocProvider<HomeBloc>.value(
              value: BlocProvider.of<HomeBloc>(context),
              child: const HomeScreen(),
            ),
            '/login': (context) => LoginPage(),
            '/signup': (context) => SignupPage(),
          },
        ),
      ),
    );
  }
}
