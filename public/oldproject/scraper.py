# -*- coding: utf-8 -*-
# scraper.py
# Author: Sam Lucidi <mansam@csh.rit.edu>

# Guitar Tablature Translator
# Copyright (C) 2013  Mark Willson, Samuel Lucidi

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

def download_tab(ug_url):
	import requests
	from bs4 import BeautifulSoup

	base_url = "http://tabs.ultimate-guitar.com"
	user_agent = "Mozilla/4.0 (compatible; MSIE 6.1; Windows XP; .NET CLR 1.1.4322; .NET CLR 2.0.50727)"
	response = requests.get(ug_url)
	if not response.status_code == 200:
		raise Exception

	html = response.content
	the_soup = BeautifulSoup(html)
	link = the_soup.find(attrs={"class":"pr_b"}).get("href")

	response = requests.get(base_url + link, headers={
												"User-Agent": user_agent,
												"Referer": ug_url})
	if not response.status_code == 200:
		raise Exception

	the_soup = BeautifulSoup(response.content)
	return the_soup.find("pre").prettify(formatter=None)