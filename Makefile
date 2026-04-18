clean:
	rm -fr bin/

runjs: buildjs
	chromium index.html

buildjs:
	haxe js.hxml