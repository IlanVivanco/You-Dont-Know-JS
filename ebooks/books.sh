#!/bin/bash

compile_md() {
	markdown-pp $1/$1.mdpp -o $1/$1.md
}

create_epub() {
	pandoc -o $1/$1.epub $1/metadata.yml $1/$1.md --toc --css=stylesheet.css --toc-depth=2 --epub-cover-image=../$1/images/cover.png
}

remap_images() {
	sed -i "s/images\//..\/$1\/images\//" $1/$1.md
}

remove_titles() {
	edition=" - 2nd Edition"
	title="# $2$edition"
	sed -i "s/$title//" $1/$1.md
}

create_metadata() {
	echo "---
title: \"$2\"
creator: Kyle Simpson
rights: © 2019-2020 Kyle Simpson.
language: en-US
---" >$1/metadata.yml
}

remove_files() {
	books_dir=epubs
	[ ! -d $books_dir ] && mkdir $books_dir
	mv $1/$1.epub $books_dir
	rm -rf $1
}

create_books() {
	# Books
	declare -A books
	books['get-started']=get_started
	books['scope-closures']=scope_closures

	# Titles
	title_get_started="You Don't Know JS Yet: Get Started"
	title_scope_closures="You Don't Know JS Yet: Scope & Closures"

	# Chapters
	chapters_get_started=('foreword.md' 'preface.md' 'ch1.md' 'ch2.md' 'ch3.md' 'ch4.md' 'apA.md' 'apB.md')
	chapters_scope_closures=('foreword.md' 'preface.md' 'ch1.md' 'ch2.md' 'ch3.md' 'ch4.md' 'ch5.md' 'ch6.md' 'ch7.md' 'ch8.md' 'apA.md' 'apB.md')

	# Create a book for each on the array
	for key in "${!books[@]}"; do
		book_chapters=chapters_${books[$key]}[@]
		book_title=title_${books[$key]}[@]

		[ ! -d $key ] && mkdir $key

		for chapter in ${!book_chapters}; do
			echo "!INCLUDE '../$key/$chapter'"
			echo ""
		done >$key/$key.mdpp

		compile_md $key
		create_metadata $key "${!book_title}"
		remap_images $key
		remove_titles $key "${!book_title}"
		create_epub $key
		remove_files $key

	done
}

create_books
