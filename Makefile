-include $(shell curl -sSL -o .build-harness "https://raw.githubusercontent.com/russelltsherman/build-harness/master/templates/Makefile.build-harness"; echo .build-harness)

all: \
	brew \
	vagrant_plugins

bootstrap: \
	all

vagrant_plugins:
	vagrant plugin install vagrant-disksize
