import re
import sys

def normalize_dot(dot_content):
    # Remove the "Ref" label if present
    dot_content = re.sub(r'label="Ref";?\s*', '', dot_content)
    
    # Normalize all node IDs to a common value
    dot_content = re.sub(r'\d+', 'ID', dot_content)
    
    # Remove all whitespace and newlines for comparison
    dot_content = re.sub(r'\s+', '', dot_content)
    
    return dot_content

def compare_dot_files(file1, file2):
    with open(file1, 'r') as f1, open(file2, 'r') as f2:
        content1 = normalize_dot(f1.read())
        content2 = normalize_dot(f2.read())
        
        return content1 == content2

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python compare_dot.py <file1.dot> <file2.dot>")
        sys.exit(1)
    
    file1 = sys.argv[1]
    file2 = sys.argv[2]
    
    if compare_dot_files(file1, file2):
        print("Graphs are equivalent")
    else:
        print("Graphs are different")