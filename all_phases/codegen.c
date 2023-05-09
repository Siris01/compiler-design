#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int reg_count = 0;
int loop_count = 0;
char predefined_list[10][10] = {"while ", "if ", "for "};
struct registers {
  char name[10];
  char value[10];
  int reg_num;
  struct registers *next;
};
struct registers *head = NULL;
struct registers *add_items(struct registers *, char[], int, char[]);
void display(struct registers *);
void print_Arithmetic_statement(char[], char);
void print_Condition_statement(char[]);
void print_assignmentOp(char[]);
int isGoto_statement(char[], int);
int isAssignmentOp(char[]);
int isArithmetic(char[]);
int isCondition(char[]);
int main(int argc, char const *argv[]) {
  FILE *fp = fopen(argv[1], "r");
  if (fp == NULL) {
    printf("404-File not found.....!\n");
    exit(1);
  }
  int ch = fgetc(fp);
  int i = 0, result = -1;
  char temp[20];
  memset(temp, 0, sizeof(temp));
  printf("Assembly code:\n");
  while (ch != EOF) {
    if (ch == '\n') {
      temp[i] = '\0';
      result = isCondition(temp);
      if (result == 0) {
        result = isGoto_statement(temp, i - 1);
        if (result == 0) {
          result = isArithmetic(temp);
          if (result == 0) {
            result = isAssignmentOp(temp);
            if (result == 0) {
              printf("%s\n", temp);
            }
          }
        }
      }
      memset(temp, 0, sizeof(temp));
      i = 0;
    }
    temp[i++] = (char)ch;
    ch = fgetc(fp);
  }
  // display(head);
  return 0;
}
int isGoto_statement(char temp[20], int i) {
  char *res = strstr(temp, "goto");
  if (res) {
    printf("JMP L%c\n", temp[i]);
    return 1;
  }
  return 0;
}
int isCondition(char temp[20]) {
  char *res = strstr(temp, "if ");
  if (res) {
    print_Condition_statement(temp);
    return 1;
  }
  return 0;
}
void print_Condition_statement(char temp[]) {
  char var[10], goto_s[5], op[3];
  int num = 0, i = 0, flag = 0, j = 0, pos = 0;
  memset(goto_s, 0, sizeof(goto_s));
  memset(op, 0, sizeof(op));
  memset(var, 0, sizeof(var));
  int n = strlen(temp);
  for (i = 0; i < n; i++) {
    char c = temp[i];
    if (isdigit(c) && temp[i - 1] != 'L') {
      pos = i;
      while (isdigit(c)) {
        num = num * 10 + (c - '0');
        i++;
        if (i < strlen(temp))
          c = temp[i];
        else
          break;
        flag = 1;
      }
    }
    if (flag)
      break;
  }
  i = 1;
  while (i < n) {
    if (temp[i - 1] == 'i' && temp[i] == 'f')
      break;
    i++;
  }
  i = i + 2;
  while (i < n) {
    if (temp[i] == '=' || temp[i] == '<' || temp[i] == '>' || temp[i] == '!')
      break;
    var[j++] = temp[i++];
  }
  var[j] = '\0';
  j = 0;
  while (i < pos) {
    op[j++] = temp[i++];
  }
  op[j] = '\0';
  struct registers *ptr = head;
  if (ptr != NULL) {
    while (ptr != NULL) {
      if (strcmp(var, ptr->name) == 0) {
        printf("MOV R%d,#%d\n", reg_count++, num);
        printf("%c%c:CMP R%d,R%d\n", temp[1], temp[2], ptr->reg_num,
               reg_count - 1);
        if (strcmp(op, "<=") == 0)
          printf("JLE L%c\n", temp[strlen(temp) - 1]);
        else {
          if (strcmp(op, ">=") == 0)
            printf("JGE L%c\n", temp[strlen(temp) - 1]);
          else {
            if (strcmp(op, "==") == 0)
              printf("JE L%c\n", temp[strlen(temp) - 1]);
            else {
              if (strcmp(op, "!=") == 0)
                printf("JNE L%c\n", temp[strlen(temp) - 1]);
              else {
                if (strcmp(op, "<") == 0)
                  printf("JL L%c\n", temp[strlen(temp) - 1]);
                else {
                  if (strcmp(op, ">") == 0)
                    printf("JG L%c\n", temp[strlen(temp) - 1]);
                }
              }
            }
          }
        }
        break;
      }
      ptr = ptr->next;
    }
  }
}
int isArithmetic(char temp[20]) {
  int i = 0, flag = 0, j = 0;
  char op;
  for (i = 0; i < strlen(temp); i++) {
    if (temp[i] == '=')
      flag = 1;
    if ((temp[i] == '+' || temp[i] == '*' || temp[i] == '-' ||
         temp[i] == '/') &&
        flag == 1) {
      flag = 2;
      op = temp[i];
      break;
    }
  }
  if (flag != 2)
    return 0;
  char temp2[20];
  memset(temp2, 0, sizeof(temp2));
  i = 0;
  flag = 0;
  while (i < strlen(temp)) {
    if (temp[i] == ':') {
      flag = 1;
      break;
    }
    i++;
  }
  if (flag == 1) {
    i++;
    while (i < strlen(temp)) {
      temp2[j++] = temp[i++];
    }
    temp2[j] = '\0';
    printf("%c%c:", temp[1], temp[2]);
    print_Arithmetic_statement(temp2, op);
    return 1;
  }
  print_Arithmetic_statement(temp, op);
  return 1;
}
void print_Arithmetic_statement(char var[20], char op) {
  char temp[20];
  memset(temp, 0, sizeof(temp));
  char a[5], b[5], c[5];
  memset(a, 0, sizeof(a));
  memset(b, 0, sizeof(b));
  memset(c, 0, sizeof(c));
  int i = 0, j = 0;
  while (i < strlen(var)) {
    if (var[i] != '\n')
      temp[j++] = var[i];
    i++;
  }
  temp[j] = '\0';
  i = 0;
  j = 0;
  while (temp[i] != '=') {
    a[j++] = temp[i++];
  }
  a[j] = '\0';
  i++;
  j = 0;
  while (temp[i] != op) {
    b[j++] = temp[i++];
  }
  b[j] = '\0';
  i++;
  j = 0;
  while (i < strlen(temp)) {
    c[j++] = temp[i++];
  }
  c[j] = '\0';
  struct registers *ptr = head;
  int flag = 1000;
  while (ptr != NULL) {
    if (strcmp(ptr->name, a) == 0) {
      flag = flag + 100;
      sprintf(a, "R%d", ptr->reg_num);
      break;
    }
    ptr = ptr->next;
  }
  ptr = head;
  while (ptr != NULL) {
    if (strcmp(ptr->name, b) == 0) {
      flag = flag + 10;
      sprintf(b, "R%d", ptr->reg_num);
      break;
    }
    ptr = ptr->next;
  }
  ptr = head;
  while (ptr != NULL) {
    if (strcmp(ptr->name, c) == 0) {
      flag = flag + 1;
      sprintf(c, "R%d", ptr->reg_num);
      break;
    }
    ptr = ptr->next;
  }
  int flag2 = 0;
  char temp2[10];
  memset(temp2, 0, sizeof(temp2));
  if (isdigit(b[0])) {
    printf("MOV R%d,#%s\n", reg_count++, b);
    if (isdigit(c[0])) {
      printf("MOV R%d,#%s\n", reg_count++, c);
      if (op == '+')
        printf("ADD R%d,R%d\n", reg_count - 1, reg_count - 2);
      else {
        if (op == '-')
          printf("SUB R%d,R%d\n", reg_count - 1, reg_count - 2);
        else {
          if (op == '*')
            printf("MUL R%d,R%d\n", reg_count - 1, reg_count - 2);
          else
            printf("DIV R%d,R%d\n", reg_count - 1, reg_count - 2);
        }
      }
      printf("MOV %s,R%d\n", a, reg_count - 1);
      if (flag == 1000)
        printf("MOV R%d,%s\n", reg_count++, a);
    } else {
      if (flag == 1001 || flag == 1111 || flag == 1101 || flag == 1011) {
        if (op == '+')
          printf("ADD %s,R%d\n", c, reg_count - 1);
        else {
          if (op == '-')
            printf("SUB %s,R%d\n", c, reg_count - 1);
          else {
            if (op == '*')
              printf("MUL %s,R%d\n", c, reg_count - 1);
            else
              printf("DIV %s,R%d\n", c, reg_count - 1);
          }
        }
        printf("MOV %s,%s\n", a, c);
        if (flag == 1000)
          printf("MOV R%d,%s\n", reg_count++, a);
      } else {
        if (op == '+')
          printf("ADD R%d,%s\n", reg_count - 1, c);
        else {
          if (op == '-')
            printf("SUB R%d,%s\n", reg_count - 1, c);
          else {
            if (op == '*')
              printf("MUL R%d,%s\n", reg_count - 1, c);
            else
              printf("DIV R%d,%s\n", reg_count - 1, c);
          }
        }
        printf("MOV %s,R%d\n", a, reg_count - 1);
        if (flag == 1000)
          printf("MOV R%d,%s\n", reg_count++, a);
      }
    }
  } else {
    if (flag == 1010 || flag == 1110 || flag == 1111 || flag == 1011) {
      if (flag == 1001 || flag == 1111 || flag == 1101 || flag == 1011) {
        if (op == '+')
          printf("ADD %s,%s\n", c, b);
        else {
          if (op == '-')
            printf("SUB %s,%s\n", c, b);
          else {
            if (op == '*')
              printf("MUL %s,%s\n", c, b);
            else
              printf("DIV %s,%s\n", c, b);
          }
        }
        printf("MOV %s,%s\n", a, c);
        if (flag == 1000)
          printf("MOV R%d,%s\n", reg_count++, a);
      } else {
        if (isdigit(c[0])) {
          printf("MOV R%d,#%s\n", reg_count++, c);
        } else {
          printf("MOV R%d,%s\n", reg_count++, c);
        }
        if (op == '+')
          printf("ADD %s,R%d\n", b, reg_count - 1);
        else {
          if (op == '-')
            printf("SUB %s,R%d\n", b, reg_count - 1);
          else {
            if (op == '*')
              printf("MUL %s,R%d\n", b, reg_count - 1);
            else
              printf("DIV %s,R%d\n", b, reg_count - 1);
          }
        }
        printf("MOV %s,%s\n", a, b);
        if (flag == 1000)
          printf("MOV R%d,%s\n", reg_count++, a);
      }
    } else {
      printf("MOV R%d,%s\n", reg_count++, b);
      if (isdigit(c[0])) {
        printf("MOV R%d,#%s\n", reg_count++, c);
        if (op == '+')
          printf("ADD R%d,R%d\n", reg_count - 1, reg_count - 2);
        else {
          if (op == '-')
            printf("SUB R%d,R%d\n", reg_count - 1, reg_count - 2);
          else {
            if (op == '*')
              printf("MUL R%d,R%d\n", reg_count - 1, reg_count - 2);
            else
              printf("DIV R%d,R%d\n", reg_count - 1, reg_count - 2);
          }
        }
        printf("MOV %s,R%d\n", a, reg_count - 1);
        if (flag == 1000)
          printf("MOV R%d,%s\n", reg_count++, a);
      } else {
        if (flag == 1001 || flag == 1111 || flag == 1101 || flag == 1011) {
          if (op == '+')
            printf("ADD %s,R%d\n", c, reg_count - 1);
          else {
            if (op == '-')
              printf("SUB %s,R%d\n", c, reg_count - 1);
            else {
              if (op == '*')
                printf("MUL %s,R%d\n", c, reg_count - 1);
              else
                printf("DIV %s,R%d\n", c, reg_count - 1);
            }
          }
          printf("MOV %s,%s\n", a, c);
          if (flag == 1000)
            printf("MOV R%d,%s\n", reg_count++, a);
        } else {
          if (op == '+')
            printf("ADD R%d,%s\n", reg_count - 1, c);
          else {
            if (op == '-')
              printf("SUB R%d,%s\n", reg_count - 1, c);
            else {
              if (op == '*')
                printf("MUL R%d,%s\n", reg_count - 1, c);
              else
                printf("DIV R%d,%s\n", reg_count - 1, c);
            }
          }
          printf("MOV %s,R%d\n", a, reg_count - 1);
          if (flag == 1000)
            printf("MOV R%d,%s\n", reg_count++, a);
        }
      }
    }
  }
}
int isAssignmentOp(char temp[20]) {
  int i = 0;
  char *result;
  result = strstr(temp, ":");
  if (result)
    return 0;
  for (i = 0; i < 3; i++) {
    result = strstr(temp, predefined_list[i]);
    if (result) {
      return 0;
    }
  }
  for (i = 0; i < strlen(temp); i++) {
    if (temp[i] == '+' || temp[i] == '*' || temp[i] == '-' || temp[i] == '/') {
      return 0;
    }
  }
  print_assignmentOp(temp);
  return 1;
}
void print_assignmentOp(char temp[20]) {
  char value[10], variable[10];
  memset(value, 0, sizeof(value));
  memset(variable, 0, sizeof(variable));
  int i = 0, j = 0;
  while (temp[i] != '=') {
    variable[j++] = temp[i++];
  }
  variable[j] = '\0';
  i++;
  j = 0;
  while (temp[i] != '\0')
    value[j++] = temp[i++];
  value[j] = '\0';
  struct registers *ptr = head;
  int flag = 0;
  char temp2[10];
  memset(temp2, 0, sizeof(temp2));
  i = 0, j = 0;
  while (i < strlen(variable)) {
    if (variable[i] != '\n')
      temp2[j++] = variable[i];
    i++;
  }
  temp2[j] = '\0';
  while (ptr != NULL) {
    if (strcmp(ptr->name, temp2) == 0) {
      if (isdigit(value[0]))
        printf("MOV R%d , #%s\n", ptr->reg_num, value);
      else
        printf("MOV R%d , %s\n", ptr->reg_num, value);
      flag = 1;
      break;
    }
    ptr = ptr->next;
  }
  if (flag == 0)
    printf("MOV R%d , #%s\n", reg_count++, value);
  head = add_items(head, variable, reg_count - 1, value);
}
struct registers *add_items(struct registers *head, char variable[10],
                            int reg_number, char data[10]) {
  struct registers *new_node, *ptr;
  new_node = (struct registers *)malloc(sizeof(struct registers));
  new_node->reg_num = reg_number;
  char temp[10];
  memset(temp, 0, sizeof(temp));
  int i = 0, j = 0;
  while (i < strlen(variable)) {
    if (variable[i] != '\n')
      temp[j++] = variable[i];
    i++;
  }
  temp[j] = '\0';
  strcpy(new_node->name, temp);
  memset(temp, 0, sizeof(temp));
  i = 0, j = 0;
  while (i < strlen(data)) {
    if (data[i] != '\n')
      temp[j++] = data[i];
    i++;
  }
  temp[j] = '\0';
  strcpy(new_node->value, temp);
  // reg_count++;
  new_node->next = NULL;
  if (head == NULL) {
    head = new_node;
  } else {
    ptr = head;
    while (ptr->next != NULL)
      ptr = ptr->next;
    ptr->next = new_node;
  }
  return head;
}
void display(struct registers *head) {
  struct registers *ptr;
  ptr = head;
  while (ptr != NULL) {
    printf("%s <-> %s\n", ptr->name, ptr->value);
    ptr = ptr->next;
  }
}
