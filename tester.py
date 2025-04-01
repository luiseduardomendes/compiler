import os
import subprocess
import sys

# Configuration
TEST_DIR = "tests"
TEST_PREFIX = "test"
TEST_EXTENSION = ".ll"
EXPECTED_ERROR_PREFIX = "[Error] - line "
COMPILER_PATH = "./etapa2"  # Path to your compiler executable

def run_tests():
    # Get all test files in order
    test_files = sorted(
        [f for f in os.listdir(TEST_DIR) if f.startswith(TEST_PREFIX) and f.endswith(TEST_EXTENSION)],
        key=lambda x: int(x[len(TEST_PREFIX):-len(TEST_EXTENSION)])
    )
    
    passed = 0
    failed = 0
    
    for test_file in test_files:
        test_num = test_file[len(TEST_PREFIX):-len(TEST_EXTENSION)]
        test_path = os.path.join(TEST_DIR, test_file)
        
        # Read expected error from first line of test file (assuming it's in a comment)
        with open(test_path, 'r') as f:
            first_line = f.readline().strip()
            if first_line.startswith("// Expected: "):
                expected_error = first_line[len("// Expected: "):].replace('\n', '')
            else:
                print(f"Test {test_num} missing expected error in first line comment")
                failed += 1
                continue
        
        # Run compiler and capture output
        try:
            result = subprocess.run(
                [COMPILER_PATH, test_path],
                capture_output=True,
                text=True,
                timeout=5
            )
        except subprocess.TimeoutExpired:
            print(f"Test {test_num} timed out")
            failed += 1
            continue
        
        # Check if we got the expected error
        stderr = result.stderr.strip()
        if stderr.startswith(EXPECTED_ERROR_PREFIX):
            if expected_error in stderr:
                print(f"Test {test_num} PASSED")
                passed += 1
            else:
                print(f"Test {test_num} FAILED")
                print(f"  Expected: {expected_error}")
                print(f"  Got: {stderr}")
                failed += 1
        else:
            print(f"Test {test_num} FAILED (no error detected)")
            print(f"  Expected error: {expected_error}")
            print(f"  Compiler output: {stderr if stderr else 'No output'}")
            failed += 1
    
    print(f"\nSummary: {passed} passed, {failed} failed")
    return 0 if failed == 0 else 1

if __name__ == "__main__":
    sys.exit(run_tests())