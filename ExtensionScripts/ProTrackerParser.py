from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import json

def get_hero_info(hero_name, url):
    chrome_options = Options()
    chrome_options.add_argument("--headless")  # Запуск без UI
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")

    service = Service('C:\\ProgramData\\chocolatey\\bin\\chromedriver.EXE')
    driver = webdriver.Chrome(service=service, options=chrome_options)
    
    try:
        driver.get(url)
        wait = WebDriverWait(driver, 10)

        # Ожидаем появления данных о контрпиках
        counterpicks_section = wait.until(
            EC.presence_of_all_elements_located((By.CLASS_NAME, "counters-class"))  # Укажите реальный класс
        )

        hero_info = {"name": hero_name, "counterpicks": []}

        for counter in counterpicks_section:
            counter_name = counter.text.strip()  # Замените на точный путь к имени контрпика
            hero_info["counterpicks"].append(counter_name)

        return hero_info

    except Exception as e:
        print(f"Ошибка: {e}")
        return None

    finally:
        driver.quit()

def save_to_json(data, file_name):
    try:
        with open(file_name, 'w', encoding='utf-8') as file:
            json.dump(data, file, ensure_ascii=False, indent=4)
        print(f"Информация сохранена в файл: {file_name}")
    except Exception as e:
        print(f"Ошибка при сохранении файла: {e}")

def main():
    hero_name = "Lina"
    url = "https://dota2protracker.com/hero/Lina"
    print(f"Получение информации о герое {hero_name}...")

    hero_info = get_hero_info(hero_name, url)
    if hero_info:
        save_to_json(hero_info, f"{hero_name}_info.json")

if __name__ == "__main__":
    main()
