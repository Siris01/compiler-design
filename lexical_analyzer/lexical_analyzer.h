#include <ctype.h>
#include <string.h>

char *keywords[32] = {"auto",     "break",   "case",   "char",     "const",
                      "continue", "default", "do",     "double",   "else",
                      "enum",     "extern",  "float",  "for",      "goto",
                      "if",       "int",     "long",   "register", "return",
                      "short",    "signed",  "sizeof", "static",   "struct",
                      "switch",   "typedef", "union",  "unsigned", "void",
                      "volatile", "while"};

char *operators[33] = {
    "+",  "-", "*",  "/",  "%", "+=",  "-=",  "*=", "/=", "%=", "&&",
    "||", "!", "==", "!=", "<", ">",   "<=",  ">=", "++", "--", "<<",
    ">>", "&", "|",  "^",  "~", "<<=", ">>=", "&=", "|=", "^=", "="};

char *special_chars[9] = {";", ",", ".", "[", "]", "(", ")", "{", "}"};

int is_preprocessor_directive(char *token) {
  if (token[0] == '#')
    return 1;
  else
    return 0;
}

int is_function_call(char *token) {
  int n = strlen(token);
  if (isalpha(token[0]) && token[n - 2] == '(' && token[n - 1] == ')')
    return 1;
  else
    return 0;
}

int is_keyword(char *token) {
  int i = 0;
  for (i = 0; i < 32; i++) {
    if (strcmp(keywords[i], token) == 0)
      return 1;
  }

  return 0;
}

int is_identifier(char *token) {
  if (isdigit(token[0]))
    return 0;

  int n = strlen(token);
  int i = 0, j = 0;

  for (i = 0; i < n; i++) {
    if (!isalnum(token[i]) && token[i] != '_')
      return 0;
  }

  return 1;
}

int is_single_line_comment(char *token) {
  if (token[0] == '/' && token[1] == '/')
    return 1;
  else
    return 0;
}

int is_multi_line_comment(char *token) {
  if (token[0] == '/' && token[1] == '*')
    return 1;
  else
    return 0;
}

int is_integer_constant(char *token) {
  int n = strlen(token);
  int i = 0;

  for (i = 0; i < n; i++) {
    if (!isdigit(token[i]))
      return 0;
  }

  return 1;
}

int is_string_constant(char *token) {
  int n = strlen(token);
  int i = 0;

  if (token[0] == '"' && token[n - 1] == '"')
    return 1;
  else
    return 0;
}