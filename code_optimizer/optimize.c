#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "utils.h"

#define SIZE 1024

struct tac {
  int type; /*
    1: result = arg1 op? arg2?
    2: goto label
    3: if goto_if_exp goto label
    4: label
  */
  char *op;
  char *arg1;
  char *arg2;
  char *result;
  char *goto_if_exp; // type = 3
  char *goto_label;  // type = 2,3
  char *label;       // type = 4
};

struct tac tacs[SIZE];
int tac_size = 0;
char buffer[SIZE];

void parse_tac(char *line) {
  char *l = strdup(line);
  struct tac tac;
  tac.type = 0;
  tac.op = NULL;
  tac.arg1 = NULL;
  tac.arg2 = NULL;
  tac.result = NULL;
  tac.goto_if_exp = NULL;
  tac.goto_label = NULL;

  char *token = strtok(line, " ");
  if (strcmp(token, "goto") == 0) {
    tac.type = 2;
    tac.goto_label = strtok(NULL, " ");
  } else if (strcmp(token, "if") == 0) {
    tac.type = 3;
    tac.arg1 = strdup(l); // FIX: Parse this better
  } else if (token[strlen(token) - 1] == ':') {
    tac.type = 4;
    tac.label = token;
  } else {
    tac.type = 1;
    tac.result = token;
    strtok(NULL, " ");
    tac.arg1 = strtok(NULL, " ");
    tac.op = strtok(NULL, " ");
    tac.arg2 = strtok(NULL, " ");
  }

  tacs[tac_size++] = tac;
  free(l);
}

void print_tacs() {
  for (int i = 0; i < tac_size; i++) {
    struct tac tac = tacs[i];
    if (tac.type == 1) {
      printf("%s = %s %s %s\n", tac.result, tac.arg1, tac.op, tac.arg2);
    } else if (tac.type == 2) {
      printf("goto %s\n", tac.goto_label);
    } else if (tac.type == 3) {
      printf("%s\n", tac.arg1); // FIX: Parse this better
    } else if (tac.type == 4) {
      printf("%s:", tac.label);
    }
  }
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    printf("Usage: %s input.tac\n", argv[0]);
    return 1;
  }

  FILE *fp = fopen(argv[1], "r");
  if (fp == NULL) {
    printf("Error: cannot open file %s\n", argv[1]);
    return 1;
  }

  while (fgets(buffer, SIZE, fp) != NULL) {
    parse_tac(buffer);
  }

  print_tacs();

  return 0;
}