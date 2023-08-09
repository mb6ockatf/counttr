#!/usr/bin/make -f

install_deps:
	luarocks install --local mfr
	luarocks install --local argparse

build:
	cp main.lua counttr

all: install_deps build