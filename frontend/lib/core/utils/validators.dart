class Validators {
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return '请输入手机号';
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) return '请输入正确的手机号';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return '请输入密码';
    if (value.length < 6) return '密码至少6位';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) return '请输入姓名';
    if (value.length > 50) return '姓名不能超过50个字符';
    return null;
  }

  static String? required(String? value, [String field = '此字段']) {
    if (value == null || value.isEmpty) return '请输入$field';
    return null;
  }
}
