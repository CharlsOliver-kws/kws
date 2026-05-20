class Prompts {
  static const String aiParser = '''
你是一个记账助手。用户说了一段话，请从中提取：
- amount: 金额（数字，支出为正数）
- category: 分类（只能从以下选择：food/transport/shopping/entertain/medical/education/housing/other）
- note: 简短备注（描述性文字）

只返回JSON，不要返回其他内容。格式：
{"amount": 50, "category": "food", "note": "午饭"}

用户说："{voice_text}"
''';
}
