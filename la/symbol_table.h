#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct table {
  char *name;
  char *type;
  int no_of_bytes;
  int address;
  char *value;
};

struct table st[10];

int stage = 0;
char *name;
int scanned = 0;
int curr_address = 1000;

void scanned_ident(char *identifier) {
  stage = 1;
  name = (char *)malloc(100);
  strcpy(name, identifier);
}

void scanned_assignment() {
  if (stage == 1)
    stage++;
  else
    stage = 0;
}

void scanned_val(char *val) {
  if (stage != 2) {
    stage = 0;
    return;
  }

  int SIZE = 2;
  char *TYPE = "int";

  struct table t;
  t.address = curr_address;
  t.name = (char *)malloc(100);
  strcpy(t.name, name);
  t.no_of_bytes = SIZE;
  t.type = (char *)malloc(100);
  strcpy(t.type, TYPE);
  t.value = (char *)malloc(100);
  strcpy(t.value, val);

  st[scanned] = t;

  name = NULL;
  stage = 0;
  curr_address += SIZE;
  scanned++;
}

void print_symbol_table() {
  int i = 0;
  printf("\n\n\n\t\t\tSymbol Table\n\n");
  printf("Name\t\tType\t\tbytes\t\tAddress\t\tValue");

  for (i = 0; i < scanned; i++) {
    printf("\n%s\t\t%s\t\t%d\t\t%d\t\t%s", st[i].name, st[i].type,
           st[i].no_of_bytes, st[i].address, st[i].value);
  }

  printf("\n");
}