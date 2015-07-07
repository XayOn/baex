CONFIG="default"

default: all

all: clean
	mkdir build
	cat config/${CONFIG} lib/general.bash lib/math.bash lib/terminal.bash lib/tui.bash lib/color.bash plugins/* > build/baex.bash

clean:
	rm -rf build

recreate_docs: all
	bash -c "source build/baex.bash; show_docs > ../docs/api.rst"
