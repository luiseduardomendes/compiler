# Design Name: Tester.py
# Project Name: Compiler Tester
# Description: Python tester for UFRGS compiler
# Authors:
#  - Leonardo Kauer Leffa - 00333399
#  - Luis Eduardo Pereira Mendes - 00333936

import os
import subprocess
import sys
import signal
from typing import Tuple, Optional

# Configuration
TEST_DIR = "tests"
TEST_PREFIX = "test"
TEST_EXTENSION = ".ll"
EXPECTED_ERROR_PREFIX = "[Error]"
COMPILER_PATH = "./etapa2"
TIMEOUT = 2

def run_parser(test_file: str) -> Tuple[Optional[str], Optional[str]]:
    """Run the parser and return combined output"""
    try:
        with open(test_file, 'r') as f:
            proc = subprocess.Popen(
                [COMPILER_PATH],
                stdin=f,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                bufsize=1,
                universal_newlines=True
            )
            try:
                stdout, stderr = proc.communicate(timeout=TIMEOUT)
                return stdout + stderr  # Combine both outputs
            except subprocess.TimeoutExpired:
                os.killpg(os.getpgid(proc.pid), signal.SIGTERM)
                return f"Timeout after {TIMEOUT} seconds"
    except Exception as e:
        return f"Execution failed: {str(e)}"

def run_tests():
    if not os.path.exists(COMPILER_PATH):
        print(f"Error: Parser executable not found at {COMPILER_PATH}")
        return 1

    test_files = sorted(
        [f for f in os.listdir(TEST_DIR) 
         if f.startswith(TEST_PREFIX) and f.endswith(TEST_EXTENSION)],
        key=lambda x: int(x[len(TEST_PREFIX):-len(TEST_EXTENSION)]))
    
    passed = 0
    failed = 0
    
    print(f"Found {len(test_files)} test files")
    print("=" * 50)

    for test_file in test_files:
        test_num = test_file[len(TEST_PREFIX):-len(TEST_EXTENSION)]
        test_path = os.path.join(TEST_DIR, test_file)
        
        with open(test_path, 'r') as f:
            first_line = f.readline()
            expected_error = first_line[len("// Expected: "):].strip() if first_line.startswith("// Expected: ") else ""
        
        print(f"\n\033[33mRunning test {test_num}\033[m ({test_file})")

        output = run_parser(test_path)

        if expected_error:
            # Test expects an error
            if expected_error in output:
                print("\033[32m✓ PASSED (found expected error)\033[m")
                passed += 1
            else:
                print("\033[31m✗ FAILED (expected error not found)\033[m")
                print(f"Parser output:\n\t{output}")
                print(f"Expected: \n\t{expected_error}")
                failed += 1
        else:
            # Test expects success
            if EXPECTED_ERROR_PREFIX not in output:
                print("\033[32m✓ PASSED (no errors found)\033[m")
                passed += 1
            else:
                print("\033[31m✗ FAILED (found unexpected error)\033[m")
                print(f"Parser output:\n\t{output}")
                print(f"Expected: \n\tSuccess")
                failed += 1
    
    print("\n" + "=" * 50)
    print(f"TEST SUMMARY: \033[32m{passed} passed\033[m, \033[31m{failed} failed\033[m")
    return 0 if failed == 0 else 1

if __name__ == "__main__":
    sys.exit(run_tests())