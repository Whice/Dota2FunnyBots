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

def get_relative_path(file_path, base_dir):
    """Возвращает относительный путь от базовой директории."""
    return os.path.relpath(file_path, base_dir)

def merge_files(files, output_file, base_dir):
    """Объединяет содержимое всех файлов в один выходной файл."""
    with open(output_file, "w", encoding="utf-8") as out_f:
        for file in files:
            try:
                with open(file, "r", encoding="utf-8") as in_f:
                    content = in_f.read()
                
                # Получаем относительный путь
                relative_path = get_relative_path(file, base_dir)
                
                # Записываем относительный путь и содержимое файла
                out_f.write(f"Файл: {relative_path}\n\n")
                out_f.write(f"{content}\n")
                out_f.write("*" * 40 + "\n\n")
            except Exception as e:
                print(f"Ошибка при обработке файла {file}: {e}")

if __name__ == "__main__":
    # Получаем директорию, где находится скрипт
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Собираем файлы в директории скрипта и подпапках
    files_to_merge = collect_files(script_dir)
    
    # Объединяем файлы
    merge_files(files_to_merge, OUTPUT_FILE, script_dir)
    
    print(f"Файл {OUTPUT_FILE} успешно создан.")
    print(f"Обработано файлов: {len(files_to_merge)}")