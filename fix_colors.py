import os

def replace_in_file(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = content.replace('.withValues(alpha: ', '.withOpacity(')
        
        if content != new_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Fixed: {file_path}")
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

def main():
    for root, dirs, files in os.walk('lib'):
        for file in files:
            if file.endswith('.dart'):
                replace_in_file(os.path.join(root, file))

if __name__ == "__main__":
    main()
