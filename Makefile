PREFIX=/usr/local
install:
	@install src/source_jabashit $(PREFIX)/bin/
	@install -d $(PREFIX)/share/jabashit
	@install src/plugins/* $(PREFIX)/share/jabashit/

config:
	@install -d /home/$(USER)/.jabashit
	@cp -r src/confs/* /home/$(USER)/.jabashit/
	@echo "Now just source /home/$(USER)/.jabashit/bashrc from your bashrc"

doc: install
	@.mkdocs

