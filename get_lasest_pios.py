#!/usr/bin/env python3

import requests
import sys
from bs4 import BeautifulSoup

#print(sys.argv)

lenarg2=len(sys.argv[2])
lenarg3=len(sys.argv[3])
lenarg4=len(sys.argv[4])
#lenarg5=len(sys.argv[5])

url = f"{sys.argv[1]}{sys.argv[2]}_{sys.argv[3]}_{sys.argv[4]}/images/"

html_doc = requests.get(url).text
soup = BeautifulSoup(html_doc, 'html.parser')
latesturl = "not found"

for link in soup.find_all('a'):
    href = link.get('href')
    if href[0:lenarg2] == sys.argv[2]:
        latesturl = f"{url}{href}"

html_doc = requests.get(latesturl).text
soup = BeautifulSoup(html_doc, 'html.parser')

for link in soup.find_all('a'):
    href = link.get('href')
    if href.endswith(".xz"):
        print (f"{latesturl}/{href}")
