dotfiles
==========

## Installation

Download the files to your **home** directory:

#### Git

Via HTTPS
```
cd && git clone https://github.com/huntingbears01/dotfiles.git .dotfiles
```
Or SSH
```
cd && git clone git@github.com:HuntingBears01/dotfiles.git .dotfiles
```
#### Git-free

```
cd && mkdir .dotfiles && cd .dotfiles
curl -#L https://github.com/huntingbears01/dotfiles/tarball/master \
| tar -xzv --strip-components 1
```

## Setup

Run the setup script
```
~/.dotfiles/setup
```

Apply the new configuration
```
source ~/.bashrc
```

