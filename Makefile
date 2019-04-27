ifeq '$(findstring ;,$(PATH))' ';'
	detected_OS := Windows
else
	detected_OS := $(shell uname 2>/dev/null || echo Unknown)
	detected_OS := $(patsubst CYGWIN%,Cygwin,$(detected_OS))
	detected_OS := $(patsubst MSYS%,MSYS,$(detected_OS))
	detected_OS := $(patsubst MINGW%,MSYS,$(detected_OS))
endif

current_dir = $(shell pwd)
DOTFILE_NAMES := $(subst ./dotfiles/, , $(shell find ./dotfiles -maxdepth 1 -name ".*"))
DOTFILES := $(addprefix ~/, $(DOTFILE_NAMES))

all: \
	brew

bootstrap: \
	all

# OSX Specific targets
ifeq ($(detected_OS),Darwin)

/usr/local/bin/brew:
	ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	brew analytics off

.PHONY: brew
brew: /usr/local/bin/brew
	brew bundle --file=Brewfile.osx

endif

# Linux specific targets
ifeq ($(detected_OS),Linux)

/usr/local/bin/brew:
	sh -c "$$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
	# TODO: shits all broke camp - fix this
	# test -d ~/.linuxbrew && PATH="$$HOME/.linuxbrew/bin:$$HOME/.linuxbrew/sbin:$$PATH"
	# test -d /home/linuxbrew/.linuxbrew && PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$$PATH"
	# test -r ~/.bash_profile && echo "export PATH='$$(brew --prefix)/bin:$$(brew --prefix)/sbin'":'"$$PATH"' >>~/.bash_profile
	# echo "export PATH='$$(brew --prefix)/bin:$$(brew --prefix)/sbin'":'"$$PATH"' >>~/.profile

.PHONY: brew
brew: /usr/local/bin/brew
	brew bundle --file=Brewfile.lin

endif
