import csv
import requests
from bs4 import BeautifulSoup
from openpyxl import Workbook

# Function to check if div element with given class name is missing or does not contain an <a href=''> element
def is_div_with_class_missing(url, div_class):
    # Fetch the HTML content
    response = requests.get(url)
    html_content = response.content

    soup = BeautifulSoup(html_content, 'html.parser')

    # Find the div elements with the given class
    div_elements = soup.find_all('div', class_=div_class)

    # Check if div element with the given class is missing or does not contain an <a href=''> element
    for div in div_elements:
        if not div.find('a', href=True):
            return True

    return False

# Function to check if the div element with the given class exists in the HTML
def is_div_present(url, div_class):
    # Fetch the HTML content
    response = requests.get(url)
    html_content = response.text

    soup = BeautifulSoup(html_content, 'html.parser')

    # Find all div elements with the given class
    div_elements = soup.find_all('div', class_=div_class)

    return len(div_elements) > 0

# Read URLs from a CSV file
def read_urls_from_csv(file_path):
    urls = []
    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            row = [url.strip('\ufeff') for url in row]  # Strip special characters from URLs
            urls.extend(row)
    return urls

# CSV file containing URLs to be investigated
csv_file_path = '/Users/ronangabriel/Documents/Website Audit Data/websites.csv'
website_urls = read_urls_from_csv(csv_file_path)


# Save results as an Excel File
workbook = Workbook()
sheet = workbook.active

# Write headers
sheet.append(['Website URL', 'CTA Buttons', 'Click-to-Call link'])


# Check each website for missing div elements with class names and the <a href=''> conditions
for website in website_urls:
    cta_buttons_present = not is_div_with_class_missing(website, 'sidebar-ctas')
    click_to_call_present = is_div_present(website, 'appointment appointment-box gold box1 center title1')

    sheet.append([website, cta_buttons_present, click_to_call_present])

# Specify file path to save results
result_file_path = '/Users/ronangabriel/Documents/Website Audit Results/Website Audit Results (Neuro).xlsx'
workbook.save(result_file_path)
print(f"Results saved to {result_file_path}")

