# Compiler

## Use instructions
to run, use the following commands
```bash
  make
  # example of use
  ./etapa2 < tests/test0.ll
  ./etapa2 < tests/test.ll
  ./etapa2 < tests/matmul.ll
```

## Tester
To use the tester, run the following commands
```bash
  make
  python3 tester.py
```

### How is the tester working
The tester runs all the files in the format "`test{number}.ll`" located in the "`./tests/`" folder.

### Output 
The tester runs displaying the following log in the screen
```
Running test <number> (test<number>.ll)
```
If it passes, it displays
```
✓ PASSED (found expected error)
```
if it doesn't, it shows 
```
✗ FAILED (expected error not found)
Parser output:
        [Error] - line 3: syntax error, <found_error>

Expected: 
        syntax error, <expected_error>
```

### How to write new tests
Create a new file with the format "`./tests/test<number>.ll`". The file must start with a comment in the format
```
// Expected: syntax error, unexpected <unexpected_token>, expecting <expected_token>
```

Passing the test is not sensible to the line, so it has to be omitted.

