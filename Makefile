install:
	install -d /usr/share/codenv
	cp -r conf/* /usr/share/codenv
	install src/codenv /usr/bin
	install src/*.* /usr/bin
	mv /usr/bin/codenv.conf /etc
