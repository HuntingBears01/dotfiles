# dotfiles

## Prerequisites

- fzf
- git
- vim
- zsh

Set your default shell to `zsh`

```
chsh /bin/zsh
```

## Installation

Download the files to your **config** directory:

Via HTTPS

```
cd ~/.config && git clone https://github.com/huntingbears01/dotfiles.git
```

Or SSH

```
cd ~/.config && git clone git@github.com:HuntingBears01/dotfiles.git
```

## Setup

Run the setup script

```
~/.config/dotfiles/setup.sh
```

Apply the new configuration

```
source ~/.zshrc
```

## Terminal customisation

- Theme: [Catppuccin](https://catppuccin.com/)
- Font: [Iosevka Term](https://typeof.net/Iosevka/)
