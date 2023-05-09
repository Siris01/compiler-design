#include <ctype.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SIZE 1024
char *buffer;

char tokens[10][10];
int occurs[10];
int token_id = 0;
/*CONSTANT FOLDING */
void constant_folding(char *line) {
  int len = strlen(line);
  int count = 0;
  char *token;
  char string[100];
  char str[100];
  strcpy(string, line);
  token = strtok(line, " ");
  int digit = 0;
  int num1 = 0;
  int num2 = 0;
  int knt = 0;
  char op[2];
  while (token != NULL) {
    strcpy(str, token);
    knt++;
    if (knt < 2) {
      printf("%s = ", token);
      token = strtok(NULL, " ");
      continue;
    }
    int token_len = strlen(str);
    int number = 0;
    int yes = 0;
    digit = 0;
    for (int j = 0; j < token_len; j++) {
      if (isdigit(str[j]) != 0) {
        yes = 1;
        digit++;
      }
    }
    if (digit == token_len && count == 0 && yes != 0) {
      num1 = atoi(&token[0]);
      // printf("num1 : %d\n",num1);
      count = 1;
      token = strtok(NULL, " ");
      continue;
    }
    if (digit == token_len && count == 1 && yes != 0) {
      num2 = atoi(&token[0]);
      count += 1;
      // printf("num2 : %d\n",num2);
    }
    if (strcmp(token, "+") == 0 || strcmp(token, "-") == 0 ||
        strcmp(token, "/") == 0 || strcmp(token, "*") == 0) {
      strcpy(op, token);
      // printf("operator : %s",op);
    }
    token = strtok(NULL, " ");
  }
  if (count != 2) {
    printf("no constant folding\n");
    printf("\n%s\n", string);
    return;
  }
  if (strcmp(op, "+") == 0)
    printf("%d\n", num1 + num2);
  else if (strcmp(op, "-") == 0)
    printf("%d\n", num1 - num2);
  else if (strcmp(op, "*") == 0)
    printf("%d\n", num1 * num2);
  else if (strcmp(op, "/") == 0)
    printf("%d\n", num1 / num2);
  else
    printf("%s", line);
}

/*ALGEBRAIC IDENTITIES*/
void algebraic_identities(char *line) {
  char string[1000];
  strcpy(string, line);
  char *token = strtok(line, " ");
  char t0[100];
  char t1[100];
  char t2[100];
  char op[2];
  char t3[100];
  int knt = 0;
  bzero(&t0, sizeof(t0));
  while (token != NULL) {
    if (knt == 0) {
      // printf("%s",token);
      strcpy(t0, token);
      token = strtok(NULL, " ");
      // token = strtok(NULL," ");
    } else if (knt == 1)
      strcpy(t1, token);
    else if (knt == 2)
      strcpy(op, token);
    else if (knt == 3)
      strcpy(t2, token);
    token = strtok(NULL, " ");
    knt++;
  }
  // printf("\n%s\t%s\t%s\t%s\t\n",t0,t1,op,t2);
  if (strcmp(t0, t1) == 0) {
    if ((strcmp(op, "+") == 0 && strcmp(t2, "0") == 0) ||
        (strcmp(op, "*") == 0 && strcmp(t2, "1") == 0))
      printf("\nAlgebraic identity found! Code removed\n");
    else
      printf("\n%s\n", string);
  } else if (strcmp(op, "^") == 0 && strcmp(t2, "2") == 0) {
    printf("\n%s = %s * %s\n", t0, t1, t1);
  } else {
    printf("\n%s\n", string);
  }
}
/* STRENGTH REDUCTION */
void strength_reduction(char *line) {
  char string[1000];
  strcpy(string, line);
  char *token = strtok(line, " ");
  char t0[100];
  char t1[100];
  char t2[100];
  char op[2];
  char t3[100];
  int knt = 0;
  bzero(&t0, sizeof(t0));
  while (token != NULL) {
    if (knt == 0) {
      strcpy(t0, token);
      token = strtok(NULL, " ");
    } else if (knt == 1)
      strcpy(t1, token);
    else if (knt == 2)
      strcpy(op, token);
    else if (knt == 3)
      strcpy(t2, token);
    token = strtok(NULL, " ");
    knt++;
  }
  if (strcmp(op, "*") == 0 && strcmp(t2, "2") == 0)
    printf("\n%s = %s << 1\n", t0, t1);
  else
    printf("%s", string);
}
/* DEAD CODE ELIMINATION */
void dead_code(char line[100]) {
  char string[1000];
  strcpy(string, line);
  printf("\n%s", line);
  char *token = strtok(line, " ");
  char t0[100];
  char t1[100];
  char t2[100];
  char op[2];
  char t3[100];
  int knt = 0;
  bzero(&t0, sizeof(t0));
  while (token != NULL) {
    if (knt == 0) {
      strcpy(t0, token);
      strcpy(tokens[token_id], token);
      token_id++;
      token = strtok(NULL, " ");
    } else if (knt == 1) {
      strcpy(t1, token);
      for (int i = 0; i < token_id; i++) {
        if (strcmp(t1, tokens[i]) == 0)
          occurs[i] = 1;
      }
    } else if (knt == 2)
      strcpy(op, token);
    else if (knt == 3) {
      strcpy(t2, token);
      for (int i = 0; i < token_id; i++) {
        if (strcmp(t1, tokens[i]) == 0)
          occurs[i] = 1;
      }
    }
    token = strtok(NULL, " ");
    knt++;
  }
}

int main(int argc, char **argv) {
  int file;
  file = open(argv[1], O_RDONLY);

  if (strcmp(argv[2], "const") == 0) {
    printf("\nConstant Folding");
    char line[100];
    char c;
    int n = 0, t;
    t = read(file, &c, 1);
    int i = 0;
    while (t != 0) {
      if (c == '\n') {
        i = 0;
        constant_folding(line);
        t = read(file, &c, 1);
        continue;
      }
      line[i] = c;
      i++;
      t = read(file, &c, 1);
    };

  } else if (strcmp(argv[2], "alg") == 0) {
    printf("\nAlgebraic Identities");
    char line[100];
    char c;
    int n = 0, t;
    t = read(file, &c, 1);
    int i = 0;
    while (t != 0) {
      if (c == '\n') {
        i = 0;
        algebraic_identities(line);
        t = read(file, &c, 1);
        continue;
      }
      line[i] = c;
      i++;
      t = read(file, &c, 1);
    };
  } else if (strcmp(argv[2], "strength") == 0) {
    printf("\nStrength Reduction");
    char line[100];
    char c;
    int n = 0, t;
    t = read(file, &c, 1);
    int i = 0;
    while (t != 0) {
      if (c == '\n') {
        i = 0;
        strength_reduction(line);
        t = read(file, &c, 1);
        continue;
      }
      line[i] = c;
      i++;
      t = read(file, &c, 1);
    };
  } else {
    printf("\nDead Code Elimination");
    char line[100];
    char c;
    int n = 0, t;
    t = read(file, &c, 1);
    int i = 0;
    while (t != 0) {
      if (c == '\n') {
        i = 0;
        dead_code(line);
        t = read(file, &c, 1);
        continue;
      }
      line[i] = c;
      i++;
      t = read(file, &c, 1);
    };

    printf("\nWriting optimized code to out_optimized.tac\n");
    FILE *op, *ip;

    op = fopen("out_optimized.tac", "w");
    ip = fopen("out.tac", "r");

    char buf[100];
    i = 0;

    while (fgets(buf, 100, ip) != NULL) {
      if (occurs[i] == 1) {
        fputs(buf, op);
      } else {
        // NOOP
      }
      i++;
    }
  }
}
