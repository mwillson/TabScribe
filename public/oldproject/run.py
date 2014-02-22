# -*- coding: utf-8 -*-
# run.py
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

from flask import Flask
from flask import request, Response
from scraper import download_tab
from tab_parser import find_staves, find_intersections, regenerate_tab, parse_list

app = Flask(__name__)
app.debug = True

@app.route("/")
def hello():
    return "TabScribe"

# Aww yeah, short & sweet & straight to the point.
@app.route("/tab", methods=['GET'])
def get_tab():
	
	try:
		print request.args
		tabs = []
		tab = download_tab(request.args.get('taburl',''))
		staves = find_staves(tab.split("\r\n"))
		for staff in staves:
			tabs.append(find_intersections(staff))
	except:
		import traceback
		traceback.print_exc()
	print len(tabs)
	out = [str(t).replace("'",'').replace(',','').replace('u','') for t in tabs]
	body = "\r\n".join(
		[regenerate_tab(parse_list(l))+"\n" for l in out]
	)

	return Response(body, mimetype='text/plain')

if __name__ == "__main__":
    app.run()