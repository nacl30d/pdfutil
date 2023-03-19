NAME=pdf utility
VERSION=1.0

SCRIPT_FILES = $(wildcard *.sh)
DEST = ${HOME}/.local/bin/

deploy:
	@ls ${DEST} &> /dev/null || (mkdir ${DEST} && echo 'directory ${DEST} created.')
	@$(foreach file, $(SCRIPT_FILES), ln -svfn $(abspath $(file)) $(DEST)$(basename ${file} .sh);)

update:
	git pull origin master

install: update deploy

clean:
	@find ${DEST} -xtype l -delete -printf 'broken symlink %P deleted.\n'
