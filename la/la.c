#include "lexical_analyzer.h"
#include "string_utils.h"
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define MAX 4096

void error(char *msg) {
  printf("%s\n", msg);
  exit(-1);
}

void analyze(char *line) {
  if (strlen(line) == 0 || line[0] == '\0' || line == NULL)
    return;

  if (is_preprocessor_directive(line)) {
    printf("%s\t\t-\t\tPreprocessor directive\n", line);
  } else if (is_single_line_comment(line)) {
  } else if (is_multi_line_comment(line)) {
  } else if (is_function_call(line)) {
    printf("%s\t\t-\t\tFunction call\n", line);
  } else {
    int i = 0;
    for (i = 0; i < 33; i++) {
      int n = substring_index(line, operators[i]);
      if (n != -1) {
        char *prev = substring(line, 0, n);
        if (strlen(prev) > 0) {
          analyze(prev);
        }
        printf("%s\t\t-\t\tOperator\n", operators[i]);
        analyze(line + n + 1);
        return;
      }
    } // TOOD: Do not split the line futher if it is part of a string ""

    for (i = 0; i < 9; i++) {
      int n = substring_index(line, special_chars[i]);
      if (n != -1) {
        char *prev = substring(line, 0, n);
        if (strlen(prev) > 0) {
          analyze(prev);
        }
        printf("%s\t\t-\t\tSpecial character\n", special_chars[i]);
        analyze(line + n + 1);
        return;
      }
    }

    int n = substring_index(line, " ");
    if (n != -1) {
      char *prev = substring(line, 0, n);
      if (strlen(prev) > 0) {
        analyze(prev);
      }
      analyze(line + n + 1);
      return;
    }

    if (is_keyword(line)) {
      printf("%s\t\t-\t\tKeyword\n", line);
    } else if (is_identifier(line)) {
      printf("%s\t\t-\t\tIdentifier\n", line);
    } else if (is_integer_constant(line)) {
      printf("%s\t\t-\t\tInteger constant\n", line);
    } else if (is_string_constant(line)) {
      printf("%s\t\t-\t\tString constant\n", line);
    } else {
      printf("%s\t\t-\t\tUnknown\n", line);
    }
  }
}

void read_program(char *file_name) {
  char *line = NULL;
  size_t len = 0;
  ssize_t read;

  FILE *fp = fopen(file_name, "r");
  if (fp == NULL)
    error("Unable to open file");

  while ((read = getline(&line, &len, fp)) != -1) {
    line[read - 1] = '\0';
    analyze(trim_white_space(line));
  }

  fclose(fp);
  if (line)
    free(line);
}

int main(int argc, void *argv[]) {
  if (argc != 2)
    error("Usage: ./bin <filename>");

  read_program((char *)argv[1]);
  return 0;
}
