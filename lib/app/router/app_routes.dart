abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const profile = '/profile';
  static const changePassword = '/change-password';
  static const premiseForm = '/premise/form';
  static const premiseDrafts = '/premise/drafts';
  static const premiseDuplicate = '/premise/duplicate';

  static String module(String id) => '/module/$id';
  static String premiseFormWithMode(String mode) => '$premiseForm?mode=$mode';
  static String premiseFormNewEntry() => '$premiseForm?mode=create&i=${DateTime.now().microsecondsSinceEpoch}';
  static String premiseFormDraft(int localId) => '$premiseForm?mode=draft&localId=$localId';
}
