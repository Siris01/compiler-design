#include <ctype.h>
#include <stdlib.h>
#include <string.h>

char *trim_white_space(char *str) {
  char *end;

  while (isspace((unsigned char)*str))
    str++;

  if (*str == 0)
    return str;

  end = str + strlen(str) - 1;
  while (end > str && isspace((unsigned char)*end))
    end--;

  end[1] = '\0';
  return str;
}

int substring_index(char *str, char *substr) {
  char *p = strstr(str, substr);
  if (p)
    return p - str;
  else
    return -1;
}

char *substring(char *str, int start, int end) {
  char *sub = (char *)malloc(sizeof(char) * (end - start + 1));
  int i = 0;
  for (i = start; i < end; i++) {
    sub[i - start] = str[i];
  }
  sub[i - start] = '\0';
  return sub;
}