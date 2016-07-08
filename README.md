# Gittie

Git for dummies, a.k.a gittie!

-----

## Install

```sh
curl -sL https://raw.githubusercontent.com/f3l1x/gittie/master/installer.sh | sudo bash --
```

## Usage

```sh
Usage: gittie [-h]

Git for dummies, a.k.a gittie!

Version: 0.1

Options:

  -h        Display this help and exit.

Commands:
  c         Commit all changes. <message>
  a         Amend changes to last commit.
  p         Push current branch to [<origin/current> or <branch>].
  s         Squash <commits> together.
  ch        Checkout to <branch>.
  m         Merge current branch with <branch>
  ms        Merge & squash current branch with <branch>
  fp        Force push current branch to [<origin/current> or <branch>].
  rb        Rebase current branch onto [<origin/current> or <branch>].
  r         Reset mixed current branch <commits> backward.
  rh        Reset hard current branch <commits> backward.
  rs        Reset soft current branch <commits> backward.

Integration:
  install   Install to your OS.
  purge     Remove from your OS.
```
