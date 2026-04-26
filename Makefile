clean:
	rm -fr bin/

runjs: buildjs
	chromium index.html

buildjs:
	haxe js.hxml

buildhl:
	haxe hl.hxml

runhl: buildhl
	hl ./bin/game.hl

push: clean buildjs
	rm -f LD59.zip
	zip -r LD59.zip index.html bin/game.js bin/game.js.map
	butler push LD59.zip nathmate/finnicky-fourier-toy:HTML
	git push