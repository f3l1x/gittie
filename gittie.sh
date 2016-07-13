#!/usr/bin/env bash

# CONFIGURATION ======================================================
# ====================================================================

VERSION=0.1.1
GITTIE_GIT_CURRENT_BRANCH=$(git symbolic-ref -q HEAD)
GITTIE_GIT_CURRENT_BRANCH_SHORT=$(git symbolic-ref --short -q HEAD)

# VARIABLES ==========================================================
# ====================================================================

SCRIPT=$0
COMMAND=$1
BIN=/usr/local/bin/gittie
LAST_ANSWER=''

# USAGE ==============================================================
# ====================================================================

usage() {
cat << EOF
Usage: ${0##*/} [-h]

Git for dummies, a.k.a gittie!

Version: $VERSION

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
EOF
}

# COMMANDS ===========================================================
# ====================================================================

# [c] COMMIT CHANGES =================================================
# ====================================================================
git_commit() {
	if [ $(git status -s | wc -l) -le 0 ]; then
		echo "Nothing to commit."
		exit 1
	fi

	if [ -z "$1" ]; then
		_ask_question "Type commit message?"
		local message=${LAST_ANSWER}
	elif [ -n "$1" ]; then
		local message=${*}
	fi

	git add --all .
	git commit --all -m "${message}"
	_color_green "All changes commited."
}

# [a] COMMIT AMEND ==================================================
# ====================================================================
git_amend() {
	git add --all .

	if [ -n "$1" ]; then
		git commit -m "$*" --all --amend
		_color_green "All changes amended with new message \e[42m\e[39m $* \e[0m\e[0m."
	elif [ -z "$1" ]; then
		git commit -C HEAD --all --amend
		_color_green "All changes amended."
	fi
}

# [p] PUSH ===========================================================
# ====================================================================
git_push() {
	local branch=${1:-${GITTIE_GIT_CURRENT_BRANCH_SHORT}}
	local commits=$(git log --oneline "origin/${branch}"..${GITTIE_GIT_CURRENT_BRANCH_SHORT} | wc -l)

	_ask_yn_question "Do you really want to push \e[42m\e[39m ${commits} commit(s) \e[0m\e[0m into \e[41m\e[39m origin/${branch} \e[0m\e[0m?"
	local yn=$?
	if [ $yn -eq 1 ]; then
		git push origin ${branch}
	fi
}

# [s] SQUASH =========================================================
# ====================================================================
git_squash() {
	local branch=${GITTIE_GIT_CURRENT_BRANCH_SHORT}
	local commits=${1:-2}
	local lastmessage=$(git log -n 1 --skip $((${commits}-1)) --pretty=%B)

	_ask_yn_question "Do you really want to squash \e[42m\e[39m ${commits} commit(s) \e[0m\e[0m on \e[41m\e[39m ${branch} \e[0m\e[0m into 1 commit?"
	local yn=$?
	if [ $yn -eq 1 ]; then
		git reset --soft HEAD~${commits}
		_ask_question "Type new commit message?" "${lastmessage}"
		git_commit "${LAST_ANSWER}"
	fi
}

# [ch] CHECKOUT ======================================================
# ====================================================================
git_checkout() {
	if [ -z "$1" ]; then
		_ask_question "Checkout to branch?"
		local branch=${LAST_ANSWER}
	elif [ -n "$1" ]; then
		local branch=${1}
	fi
	git checkout "${branch}"
}

# [m] MERGE ==========================================================
# ====================================================================
git_merge() {
	if [ -z "$1" ]; then
		_ask_question "Merge branch?"
		local branch=${LAST_ANSWER}
	elif [ -n "$1" ]; then
		local branch=${1}
	fi
	git merge "${branch}"
}

# [ms] MERGE SQUASH ==================================================
# ====================================================================
git_merge_squash() {
	if [ -z "$1" ]; then
		_ask_question "Merge & squash branch?"
		local branch=${LAST_ANSWER}
	elif [ -n "$1" ]; then
		local branch=${1}
	fi
	git merge --squash "${branch}"
}

# [fp] FORCE PUSH ====================================================
# ====================================================================
git_force_push() {
	local branch=${1:-${GITTIE_GIT_CURRENT_BRANCH_SHORT}}
	local commits=$(git log --oneline "origin/${branch}"..${GITTIE_GIT_CURRENT_BRANCH_SHORT} | wc -l)

	_ask_yn_question "Do you really want to force push \e[42m\e[39m ${commits} commit(s) \e[0m\e[0m into \e[41m\e[39m origin/${branch} \e[0m\e[0m?"
	local yn=$?
	if [ $yn -eq 1 ]; then
		git push origin ${branch} -f
	elif [ $yn -eq 0 ]; then
		echo "Good choice! Force push is eval."
	fi
}

# [rb] REBASE ========================================================
# ====================================================================
git_rebase() {
	if [ $(git status -s | wc -l) -gt 0 ]; then
		echo "Please commit changes, my lord."
		git status -s
		exit 1
	fi

	local branch=${1:-origin/${GITTIE_GIT_CURRENT_BRANCH_SHORT}}

	_ask_yn_question "Do you really want to rebase onto \e[41m\e[39m ${branch} \e[0m\e[0m?"
	local yn=$?
	if [ $yn -eq 1 ]; then
		if [[ $branch == *"/"* ]]; then
			git fetch ${branch/\// }
		fi
		git rebase -i "${branch}"
	fi
}

# [r] RESET ==========================================================
# ====================================================================
git_reset() {
	local branch=${GITTIE_GIT_CURRENT_BRANCH_SHORT}
	local commits=${1:-1}

	_ask_yn_question "Do you really want to reset \e[41m\e[39m ${branch} \e[0m\e[0m \e[42m\e[39m ${commits} commit(s) \e[0m\e[0m backward?"
	local yn=$?
	if [ $yn -eq 1 ]; then
		git reset HEAD^${commits}
	fi
}

# [rh] RESET HARD ====================================================
# ====================================================================
git_reset_hard() {
	local branch=${GITTIE_GIT_CURRENT_BRANCH_SHORT}
	local commits=${1:-1}

	_ask_yn_question "Do you really want to \e[44m\e[39m hard reset \e[0m\e[0m \e[41m\e[39m ${branch} \e[0m\e[0m \e[42m\e[39m ${commits} commit(s) \e[0m\e[0m backward?"
	local yn=$?
	if [ $yn -eq 1 ]; then
		git reset --hard HEAD^${commits}
	fi
}

# [rs] RESET SOFT ====================================================
# ====================================================================
git_reset_soft() {
	local branch=${GITTIE_GIT_CURRENT_BRANCH_SHORT}
	local commits=${1:-1}

	_ask_yn_question "Do you really want to \e[44m\e[39m soft reset \e[0m\e[0m \e[41m\e[39m ${branch} \e[0m\e[0m \e[42m\e[39m ${commits} commit(s) \e[0m\e[0m backward?"
	local yn=$?
	if [ $yn -eq 1 ]; then
		git reset --soft HEAD^${commits}
	fi
}

# INTEGRATION ========================================================
# ====================================================================
integration_install() {
	if [ "$(id -u)" != "0" ]; then
		_color_red "This script needs root, my lord!"
		exit 1
	fi

	cp ${SCRIPT} ${BIN}
	chmod +x ${BIN}
	_color_green "All systems ready, my lord!"
}

integration_purge() {
	if [ "$(id -u)" != "0" ]; then
		_color_red "This script needs root, my lord!"
		exit 1
	fi

	if [ -e "$BIN" ]; then
		rm ${BIN}
		_color_green "Everything is removed, my lord!"
	else
		_color_red "Gittie is not installed, my leader!"
	fi
}

# FUNCTIONS ==========================================================
# ====================================================================

_ask_question() {
	while true; do
		if [ -n "$2" ]; then
			echo -ne $(_color_red $(_font_bold $1)" [${2}]")": "
		elif [ -n "$1" ]; then
			echo -ne $(_color_red $(_font_bold $1))": "
		fi

		read -r answer
		if [ -z "$answer" ] && [ -n "$2" ]; then
			LAST_ANSWER=${2}
			return 1
		elif [ -z "$answer" ]; then
			echo "Please answer."
		elif [ -n "$answer" ]; then
			LAST_ANSWER=${answer}
			return 1
		fi
	done
}

_ask_yn_question() {
	echo -ne $(_color_red $(_font_bold $1))" [y/n]: "
	while true; do
		read yn
		case $yn in
			[Yy]* ) return 1;;
			[Nn]* ) return 0;;
			* ) echo "Please answer yes[Yy] or no[Nn].";;
		esac
	done
}

_color_red() {
	echo -e "\e[31m$*\e[0m"
}

_color_green() {
	echo -e "\e[32m$*\e[0m"
}

_font_bold() {
	echo -e "\e[1m$*\e[0m"
}

# MAIN LOOP ==========================================================
# ====================================================================

# Check environment
if [ -z $BASH ]; then
	echo "Please use native calling or bash."
	echo "Type: ./${0}"
	exit 2
fi

# Shift first argument
if [ "$#" -gt 0 ]; then shift; fi

# Main switch
case ${COMMAND} in
	c)
		git_commit $*
		exit 1
		;;
	a)
		git_amend $*
		exit 1
		;;
	p)
		git_push $*
		exit 1
		;;
	s)
		git_squash $*
		exit 1
		;;
	ch)
		git_checkout $*
		exit 1
		;;
	m)
		git_merge $*
		exit 1
		;;
	ms)
		git_merge_squash $*
		exit 1
		;;
	fp)
		git_force_push $*
		exit 1
		;;
	rb)
		git_rebase $*
		exit 1
		;;
	r)
		git_reset $*
		exit 1
		;;
	rh)
		git_reset_hard $*
		exit 1
		;;
	rs)
		git_reset_soft $*
		exit 1
		;;
	install)
		integration_install $*
		exit 1
		;;
	purge)
		integration_purge $*
		exit 1
		;;
	*)
		usage
		exit 1
		;;
esac
