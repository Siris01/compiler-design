#include "lexical_analyzer.h"
#include "string_utils.h"
#include "symbol_table.h"
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define MAX 4096

void error(char *msg) {
  printf("%s\n", msg);
  exit(-1);
}

void analyze(char *line) {
  if (strlen(line) == 0 || line[0] == '\0' || line == NULL)
    return;

  int n = substring_index(line, "\n");
  if (n != -1) {
    char *spl = NULL;
    spl = strtok(line, "\n");

    while (spl != NULL) {
      analyze(spl);
      spl = strtok(NULL, "\n");
    }

    return;
  }

  if (is_preprocessor_directive(line)) {
    printf("%s -\t\tPreprocessor directive\n", line);
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
          analyze(trim_white_space(prev));
        }
        printf("%s\t\t-\t\tOperator\n", operators[i]);
        if (strcmp(operators[i], "=") == 0) {
          scanned_assignment();
        }
        analyze(trim_white_space(line + n + 1));
        return;
      }
    } // TOOD: Do not split the line futher if it is part of a string ""

    int n = substring_index(line, " ");
    int is_part_of_string = substring_index(line, "\"");
    if (n != -1 && is_part_of_string == -1) {
      char *prev = substring(line, 0, n);
      if (strlen(prev) > 0) {
        analyze(trim_white_space(prev));
      }
      analyze(trim_white_space(line + n + 1));
      return;
    }

    for (i = 0; i < 9; i++) {
      int n = substring_index(line, special_chars[i]);
      if (n != -1) {
        char *prev = substring(line, 0, n);
        if (strlen(prev) > 0) {
          analyze(trim_white_space(prev));
        }
        printf("%s\t\t-\t\tSpecial character\n", special_chars[i]);
        analyze(trim_white_space(line + n + 1));
        return;
      }
    }

    if (is_keyword(line)) {
      printf("%s\t\t-\t\tKeyword\n", line);
    } else if (is_identifier(line)) {
      printf("%s\t\t-\t\tIdentifier\n", line);
      scanned_ident(line);
    } else if (is_integer_constant(line)) {
      printf("%s\t\t-\t\tInteger constant\n", line);
      scanned_val(line);
    } else if (is_string_constant(line)) {
      printf("%s -\t\tString constant\n", line);
    } else {
      printf("%s\t\t-\t\tUnknown\n", line);
    }
  }
}

void read_program(char *file_name) {
  char *buff = (char *)malloc(MAX * sizeof(char));

  int fd = open(file_name, O_RDONLY);
  if (fd == -1)
    error("Unable to open file");

  int n = read(fd, buff, MAX);
  analyze(trim_white_space(buff));

  close(fd);
  if (buff)
    free(buff);

  print_symbol_table();
}

int main(int argc, void *argv[]) {
  if (argc != 2)
    error("Usage: ./bin <filename>");

  read_program((char *)argv[1]);
  return 0;
}
