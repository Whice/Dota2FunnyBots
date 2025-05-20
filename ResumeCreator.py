import os

# Задаем список расширений файлов для обработки
FILE_EXTENSIONS = {".txt", ".lua"}

# Имя выходного файла
OUTPUT_FILE = "resume.txt"

# Список файлов для игнорирования
IGNORED_FILES = {OUTPUT_FILE}

def collect_files(directory):
    """Собирает пути ко всем файлам с заданными расширениями в указанной папке и подпапках."""
    collected_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file not in IGNORED_FILES and any(file.endswith(ext) for ext in FILE_EXTENSIONS):
                collected_files.append(os.path.join(root, file))
    return collected_files

def merge_files(files, output_file):
    """Объединяет содержимое всех файлов в один выходной файл."""
    with open(output_file, "w", encoding="utf-8") as out_f:
        for file in files:
            try:
                with open(file, "r", encoding="utf-8") as in_f:
                    content = in_f.read()
                out_f.write(f"{os.path.basename(file)}:\n\n")
                out_f.write(f"{content}\n")
                out_f.write("*------*\n\n")
            except Exception as e:
                print(f"Ошибка при обработке файла {file}: {e}")

if __name__ == "__main__":
    current_directory = os.getcwd()
    files_to_merge = collect_files(current_directory)
    merge_files(files_to_merge, OUTPUT_FILE)
    print(f"Файл {OUTPUT_FILE} успешно создан.")
