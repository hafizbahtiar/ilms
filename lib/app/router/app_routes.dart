abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
  static const changePassword = '/change-password';
  static const premiseForm = '/premise/form';

  static String module(String id) => '/module/$id';
  static String premiseFormWithMode(String mode) => '$premiseForm?mode=$mode';
}
