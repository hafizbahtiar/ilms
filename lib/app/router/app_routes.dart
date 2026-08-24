abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/home';
  static const changePassword = '/change-password';
  static const premiseForm = '/premise/form';
  static const premiseDrafts = '/premise/drafts';
  static const premiseDuplicate = '/premise/duplicate';
  static const premiseDetail = '/premise/detail';
  static const billboardList = '/billboard/list';
  static const billboardForm = '/billboard/form';
  static const billboardDrafts = '/billboard/drafts';
  static const investigationList = '/investigation/list';
  static const investigationForm = '/investigation/form';
  static const investigationDrafts = '/investigation/drafts';

  static String module(String id) => '/module/$id';
  static String premiseFormWithMode(String mode) => '$premiseForm?mode=$mode';
  static String premiseFormNewEntry() => '$premiseForm?mode=create&i=${DateTime.now().microsecondsSinceEpoch}';
  static String premiseFormNewVacantEntry() =>
      '$premiseForm?mode=create&vacant=true&i=${DateTime.now().microsecondsSinceEpoch}';
  static String premiseFormDraft(int localId) => '$premiseForm?mode=draft&localId=$localId';
  static String premiseFormView(String visitNo) =>
      '$premiseForm?mode=view&visitNo=${Uri.encodeQueryComponent(visitNo)}';
  static String premiseDetailView(String visitNo) => '$premiseDetail?visitNo=${Uri.encodeQueryComponent(visitNo)}';

  static String billboardFormNewEntry() => '$billboardForm?mode=create&i=${DateTime.now().microsecondsSinceEpoch}';
  static String billboardFormDraft(int localId) => '$billboardForm?mode=draft&localId=$localId';
  static String billboardFormView(String billboardNo) =>
      '$billboardForm?mode=view&billboardNo=${Uri.encodeQueryComponent(billboardNo)}';
  static String billboardFormEdit(String billboardNo) =>
      '$billboardForm?mode=edit&billboardNo=${Uri.encodeQueryComponent(billboardNo)}';

  static String investigationListSearch() => '$investigationList?mode=search';
  static String investigationListHistory() => '$investigationList?mode=history';
  static String investigationFormView(String investigationNo) =>
      '$investigationForm?mode=view&investigationNo=${Uri.encodeQueryComponent(investigationNo)}';
  static String investigationFormEdit(String investigationNo) =>
      '$investigationForm?mode=edit&investigationNo=${Uri.encodeQueryComponent(investigationNo)}';
}
