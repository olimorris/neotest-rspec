all: test

test:
	nvim --headless --noplugin -u lua/spec/minimal.vim +Test
