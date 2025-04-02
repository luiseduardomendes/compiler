# Compiler and flags
CC = gcc
CFLAGS = -Wall -Wextra -g -fsanitize=address
LEX = flex
BISON = bison

# Source files
LEX_FILE = scanner.l
BISON_FILE = parser.y
C_SOURCES = main.c
GENERATED_SOURCES = lex.yy.c parser.tab.c
GENERATED_HEADERS = parser.tab.h
SOURCES = $(C_SOURCES) $(GENERATED_SOURCES)
OBJ = $(SOURCES:.c=.o)

# Output binary
TARGET = etapa2

# Default target
all: $(TARGET)

# Main build rule
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) -lfl

# Flex rule
lex.yy.c: $(LEX_FILE)
	$(LEX) -o $@ $<

# Bison rule (generates both .c and .h)
parser.tab.c parser.tab.h: $(BISON_FILE)
	$(BISON) -d -o parser.tab.c $<

# Special rule for main.o since it depends on generated header
main.o: main.c $(GENERATED_HEADERS)
	$(CC) $(CFLAGS) -c $< -o $@

# Pattern rule for other object files
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Clean generated files
clean:
	rm -f $(OBJ) $(GENERATED_SOURCES) $(GENERATED_HEADERS) $(TARGET)

# Phony targets
.PHONY: all clean