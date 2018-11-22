import markdown_strings as ms

def test_header():
  assert ms.header('header', 1) == '# header'

def test_italics():
  assert ms.italics('italics') == '_italics_'

def test_bold():
  assert ms.bold('bold') == '**bold**'

def test_inline_code():
  assert ms.inline_code('code') == '`code`'

def test_code_block():
  assert ms.code_block('This is a block of code', 'python') == '```python\\nThis is a block of code\\n```'
