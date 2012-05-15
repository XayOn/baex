PREFIX=/usr/local
install:
	@install src/source_jabashit $(PREFIX)/bin/
	@install -d $(PREFIX)/share/jabashit
	@install src/plugins/* $(PREFIX)/share/jabashit/

config:
	@install -d ~/.jabashit
	@install src/confs/* ~/.jabashit
	@echo "Now just source ~/.jabashit from your bashrc"

doc: install
	@.mkdocs

