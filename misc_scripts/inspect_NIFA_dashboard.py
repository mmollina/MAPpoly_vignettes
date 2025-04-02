from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from PIL import Image
from io import BytesIO
import pytesseract
import csv
import time
import re

# --- Setup Selenium ---
driver = webdriver.Chrome()
driver.set_window_size(1920, 1080)
driver.get("https://publicdashboards.dl.usda.gov/t/REE_PUB/views/NIFAApplicationStatus/DASHBOARD")
wait = WebDriverWait(driver, 30)

# --- Grant Numbers ---
grant_numbers = [f"GRANT{num}" for num in range(14276254, 14277800)]
#grant_numbers  = ["GRANT14277059"]
results = []

# --- Date Extraction via Regex from OCR ---
def extract_all_dates_from_ocr(text):
    matches = re.findall(r'\d{1,2}/\d{1,2}/\d{4}', text)
    while len(matches) < 4:
        matches.append("NA")
    return matches[:4]

# --- Main Loop ---
for grant_number in grant_numbers:
    try:
        # Input retry block
        for attempt in range(3):
            try:
                search_box = wait.until(
                    EC.presence_of_element_located((By.CSS_SELECTOR, "input.QueryBox"))
                )
                driver.execute_script("arguments[0].scrollIntoView(true);", search_box)
                time.sleep(0.3)
                search_box.click()
                time.sleep(0.3)
                search_box.clear()
                time.sleep(0.3)

                # Type slowly
                for char in grant_number:
                    search_box.send_keys(char)
                    time.sleep(0.05)
                search_box.send_keys(Keys.ENTER)
                break  # success
            except Exception as e:
                print(f"⚠️ Retry #{attempt + 1} input error: {e}")
                time.sleep(1)
        else:
            raise Exception("❌ Failed to type grant number after 3 retries.")

        print(f"🔍 Searching for: {grant_number}")
        time.sleep(2)  # Wait for dashboard update

        # Screenshot full screen
        full_image = Image.open(BytesIO(driver.get_screenshot_as_png()))

        # Crop only dashboard status region (adjust if needed)
        cropped = full_image.crop((480, 606, 3180, 960))
        cropped.save(f"{grant_number}.png")  # Optional debug

        # OCR
        ocr_text = pytesseract.image_to_string(cropped, config="--psm 6")
        print(f"📸 OCR TEXT:\n{ocr_text}\n{'-'*40}")

        # Extract dates
        received_date, in_review_date, decision_pending_date, decision_complete_date = extract_all_dates_from_ocr(ocr_text)

        # Store result
        result = {
            "grant": grant_number,
            "received": received_date,
            "in_review": in_review_date,
            "pending": decision_pending_date,
            "complete": decision_complete_date
        }
        results.append(result)

        # Save CSV after each grant (auto-progress tracking)
        with open("nifa_grant_statuses.csv", "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=["grant", "received", "in_review", "pending", "complete"])
            writer.writeheader()
            writer.writerows(results)

        # Console Output
        print(f"✅ Result for {grant_number}:")
        print(f"  📥 Received         : {received_date}")
        print(f"  🔍 In Review        : {in_review_date}")
        print(f"  ⏳ Decision Pending : {decision_pending_date}")
        print(f"  ✅ Decision Complete: {decision_complete_date}")
        print("-" * 50)

    except Exception as e:
        print(f"❌ Error with {grant_number}: {e}")
        result = {
            "grant": grant_number,
            "received": "Error",
            "in_review": "Error",
            "pending": "Error",
            "complete": "Error"
        }
        results.append(result)

        # Save error row too
        with open("nifa_grant_statuses.csv", "w", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=["grant", "received", "in_review", "pending", "complete"])
            writer.writeheader()
            writer.writerows(results)

# --- Cleanup ---
driver.quit()
