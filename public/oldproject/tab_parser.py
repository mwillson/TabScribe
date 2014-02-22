# -*- coding: utf-8 -*-
# tab_parser.py
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

import re

# regex to find guitar strings
RAW_STRING_REGEX = ur'^\w[\|\d\w\-\u2014\s\~\+\.\(\/\\\^\>]*\|$'
COMPILED_STRING_REGEX = re.compile(RAW_STRING_REGEX)
# regex to find notes/augmented notes
RAW_NOTE_REGEX = r'([\w\d]+)'
COMPILED_NOTE_REGEX = re.compile(RAW_NOTE_REGEX)
NUM_GUITAR_STRINGS = 6

def intersection(note_a, note_b):
	"""
	Determine if two ranges of integers intersect.

	"""
	
	return (note_a[0] <= note_b[1] and note_a[1] >= note_b[0])

def find_staves(tabfile):
	"""
	Return a list of "staves" in a guitar tabulature file. This
	is pretty rough, since tabulature files are not especially
	well standarized. Staves generally look something like this:

		  Intro
		  D               D6   D      E               E6/D E
		e|5----- ----5- 5H7--- 5-----|7----- ----7- 7H9--- 7-----|
		B|7----------7--7------7-----|9----------9--9------9-----|
		G|7----------7--7------7-----|9----------9--9------9-----|
		D|0----------0--0------0-----|0----------0--0------0-----|
		A|---------------------------|---------------------------|
		E|---------------------------|---------------------------|

	This function doesn't bother trying to find the section or 
	chord headers for now.

	"""

	keys = []
	bars = []
	matched = []
	for line in tabfile:
		match = COMPILED_STRING_REGEX.match(line.strip())
		if match:
			processed_line = []
			key = line[0]
			keys.append(key)
			for m in COMPILED_NOTE_REGEX.finditer(line[1:]):
				processed_line.append((m.start(), m.end(), m.group(), key))
			bars.append(processed_line)
	assert len(bars) % NUM_GUITAR_STRINGS == 0, "Error parsing tab file."
	assert len(keys) % NUM_GUITAR_STRINGS == 0, "Error parsing tab file."
	return list(chunks(bars, NUM_GUITAR_STRINGS))

def find_intersections(staff):
	"""
	Return a mapping of all of the columns of notes in a
	staff. Since rows of notes don't always line up perfectly,
	but may overlap, we calculate intersections to find the columns.

	Example of columns that would be found:

		---5h7-----1---
		---12------2---
		----0------3---
		-----5-----4---

	"""
	from copy import deepcopy
	staff = deepcopy(staff)

	intersections = {}
	# subtract one to skip checking to see
	# if the last line intersects with anything,
	# since there aren't any lines after that.
	for line in range(len(staff) - 1):
		for n in range(len(staff[line])):
			note_a = tuple(staff[line][n])
			intersections[note_a] = []
			# for each in in the staff after the current one
			# (no pointless backtracking/double work)
			for l in staff[(line+1):]:
				if l:
					to_remove = []
					for i in range(len(l)):
						# see if any notes in that row intersect
						# with note_a.
						#
						# if this is true, we can actually probably
						# break right here, since only one note per
						# row should ever be in each column, but
						# we'll let this go for now.
						if intersection(note_a, l[i]):
							intersections[note_a].append(l[i])
							to_remove.append(l[i])
					# if notes intersected, remove them
					# from the list so that they aren't accidentally
					# used to start their own column.
					for each in to_remove:
						l.remove(each)
	
	# sort the columns into the proper order and
	# return them as a tuple to simplify printing
	# them out in a sufficiently lispy format.
	columns = []
	sorted_keys = sorted(intersections.keys())
	for key in sorted_keys:
		column = []
		column.append((key[3],key[2]))
		[column.append((k[3],k[2])) for k in intersections[key]]
		columns.append(tuple(column))
	return tuple(columns)

def parse_list(lisp):
	"""
	Parse a Lisp list back into a multidimensional
	Python list.

	"""

	from pyparsing import OneOrMore, nestedExpr
	data = OneOrMore(nestedExpr()).parseString(lisp)
	# rip out all the empty dicts that pyparsing
	# scatters all over the place
	return [[[(x[0], x[1]) for x in y] for y in z] for z in data]

def regenerate_tab(staves, key={"e":0,"B":1,"G":2,"D":3,"A":4,"E":5}):
	default_row = '|' + ('-'*78) + '|'
	lines = {}
	for i in range(len(key.keys())):
		lines[i] = list(default_row)
	for staff in staves:
		
		num_columns = len(staff)
		spacing = len(default_row)/num_columns
		for col in range(len(staff)):
			for row in range(len(staff[col])):
				tuning = staff[col][row][0]
				note = staff[col][row][1]
				if tuning in key and key[tuning] == row:
					diff = spacing - len(note)
					if diff == 1:
						note = "-" + note
					else:
						note = "-"*(diff/2)+note+"-"*(diff/2)
					index = (col * spacing) + 1
					for i in range(len(note)):
						lines[row][index + i] = note[i]
	output = []
	for i in range(len(key.keys())):
		lines[i][-1] = '|'
		output.append("".join(lines[i]))
	return "\n".join(output)

def chunks(l, n):
    """
    Yield successive n-sized chunks from l.

    """

    for i in xrange(0, len(l), n):
        yield l[i:i+n]

def tab_out(tablines, target_tuning=('G', 'C', 'E', 'A')):
	output = []
	output.append(str(target_tuning).replace("'","").replace(",",""))
	staves = find_staves(tablines)
	for staff in staves:
		output.append(str(find_intersections(staff)).replace("'","").replace(",",""))
	return "\n".join(output)

if __name__ == "__main__":
	"""
	Test the tab parser.

	"""

	import pprint
	tabfile = open("eight_days.txt").readlines()
	output = tab_out(tabfile)
	lists = output.split('\n')[1:]
	for l in lists:
		print regenerate_tab(parse_list(l))
		print ""

