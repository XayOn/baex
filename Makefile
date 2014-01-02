PREFIX=/usr/local
install:
	@install src/source_yabatool $(PREFIX)/bin/
	@install -d $(PREFIX)/share/yabatool
	@install src/plugins/* $(PREFIX)/share/yabatool/

config:
	@install -d /home/$(USER)/.yabatool
	@cp -r src/confs/* /home/$(USER)/.yabatool/
	@echo "Now just source /home/$(USER)/.yabatool/bashrc from your bashrc"

doc: install
	@.mkdocs

