#! /usr/bin/env bash

rsync -rlpt --delete --exclude=sync-shared.sh --exclude=.git --stats ~/Projects/dotfiles/ ~/Shared/dotfiles/

exit 0
