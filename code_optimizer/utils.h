#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *getSubstring(char *str) {
  char *start = strchr(str, '('); // Find first occurrence of '('
  char *end = strrchr(str, ')');  // Find last occurrence of ')'
  if (start == NULL || end == NULL || end < start) {
    // Parentheses not found or invalid order
    return NULL;
  }
  size_t len = end - start - 1; // Length of substring between parentheses
  char *substr = (char *)malloc(
      len + 1); // Allocate memory for substring (+1 for null terminator)
  if (substr == NULL) {
    // Memory allocation failed
    return NULL;
  }
  strncpy(substr, start + 1,
          len);       // Copy substring between parentheses to new string
  substr[len] = '\0'; // Add null terminator to end of string
  return substr;
}