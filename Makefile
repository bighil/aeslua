DIST=aeslua-0.2.1
LIBDIR=/usr/local/lib/lua/5.1

SUBMODULES=aes buffer ciphermode gf util

FILES= Copyright.txt \
	   Changelog \
	   License.txt \
	   Makefile \
	   README \
	   README.html

.PHONY: dist install uninstall test speed
   
dist:
	mkdir -p $(DIST)
	cp -rf src $(DIST)
	cp -rf lib $(DIST)
	cp -f $(FILES) $(DIST)
	find . -name .svn -print0 | xargs -0 rm -rf
	tar cvzf $(DIST).tar.gz $(DIST)
	zip -9 -r $(DIST).zip $(DIST)
	
install:
	mkdir -p $(LIBDIR)
	cp -p src/aeslua.lua $(LIBDIR)
	mkdir -p $(LIBDIR)/aeslua 
	for i in $(SUBMODULES); do cp -p src/aeslua/$$i.lua $(LIBDIR)/aeslua; done

uninstall:
	rm -rf $(LIBDIR)/aeslua $(LIBDIR)/aeslua.lua

test:
	echo "print(aeslua.decrypt('key', aeslua.encrypt('key', 'hello world')))" | LUA_PATH="src/?.lua" lua5.1 -laeslua -lbit
	LUA_PATH="src/?.lua" lua5.1 -laeslua -lbit src/test/testaes.lua

speed:
	LUA_PATH="src/?.lua" lua5.1 -laeslua -lbit src/test/aesspeed.lua
