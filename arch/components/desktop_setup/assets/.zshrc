# MACROS

export D="$(date '+%Y-%m-%d')"

RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
NOCOLOR="\033[0m"

setopt no_share_history

export ZSH="/home/jared/.oh-my-zsh"
alias ls='ls -v --color=auto'
ZSH_THEME="robbyrussell"

HYPHEN_INSENSITIVE="true"
DISABLE_AUTO_TITLE="false"
ENABLE_CORRECTION="true"
source $ZSH/oh-my-zsh.sh

case "$TERM" in
	rxvt|*term)
		PROMPT_COMMAND='echo -ne "\033]0;$PWD\007"'
	;;
esac

[[ -n "$SSH_CONNECTION" ]] && export EDITOR='vim'

# Small repetitive commands
rm -r ~/.zcompdump*
git config --global credential.helper 'cache --timeout=18000'

# Exports
export PAGER="most"
export ZSH_THEME="common"
PATH=$PATH$(find "$HOME/scripts" -type d -not -path '*/\.*' -printf ":%p")
#PATH=$PATH$(sed 's/\:/\n/g' <<< "$(find "$HOME/scripts" -type d -not -path '/.' -not -path "*/\.*" -not -path '*__pycache__*' -printf ":%p")")
#export PATH="/home/jared/.ebcli-virtual-env/executables:$PATH"
# BEGIN PERSONAL EDITS #


# Functions and aliases

# defined functions that would not fit in a simple alias command
prompt_context() {}

function respring_iphone() {
	tcprelay -t 22:2222 &
	ssh root@localhost 'killall -9 SpringBoard'
	killall tcprealy
}

function git_push(){
  DIR="$1"
  MESSAGE="$2"
  PREV="$PWD"

  cd "$DIR"
  git add *
  git commit -m "$MESSAGE"
  git push origin master

  cd "$PREV"
}

function example_projects(){
    PROJECTS=(~/Projects/{dotfiles,thin-mint} ~/scripts)
    for PROJECT in "${PROJECTS[@]}"; do
        echo "$PROJECT"
    done
}

function bak_pref() {
    usb_devices="$(awk '{ s = ""; for (i = 7; i <= NF; i++) s = s $i " "; print s }' <<< "$(lsusb)" | sort | uniq)"
	prev="$PWD"

    # current projects

    # LANG=C find ~/Projects -type d -name '.git' | while read dir; do egrep -o "https://github.com/\\w+/\\w+.git" "$dir"/config; done | sort >/dev/null


	[[ -d ~/Projects/dotfiles ]] || exit
	# shell
	cp -ar ~/.zshrc ~/Projects/dotfiles/shell/zshrc
	cp -ar ~/.vimrc ~/Projects/dotfiles/shell/vimrc
    cp -ar ~/.vim/spell/en.utf-8.add ~/Projects/dotfiles/shell/ # user defined words

	# terminal

	cp -ar ~/.Xresources ~/Projects/dotfiles/terminal/Xresources

	cd ~/Projects/dotfiles
	echo ""$BLUE"Project: dotfiles"$NOCOLOR""
	git add *
	git commit -m "Automatic backup performed"
	git push origin master
	echo "$BLUE""Project: scripts"$NOCOLOR""
	cd ~/scripts
	git add *
	git commit -m "Automatically backing up scripts"
	git push origin master
	cd "$prev"
    echo ""$BLUE"Project: installed pkgs"$NOCOLOR""
    cd ~/Projects/thin-mint/
    list_installed
    git add *
    git commit -m "Automatically backing up installed packages"
    git push origin master

}

function gba_bak() {
    [[ "$1" == "ez" ]] 
    SD_CARD="/run/media/jared/00C5-2440"
    BACKUP_DEST="/run/media/jared/Packages/ez_flash"
    CURRENT="$(date +"%Y-%m-%d")"

    OUTPUT="$BACKUP_DEST/$CURRENT"

    [[ ! -d "$SD_CARD"  || ! -d "$BACKUP_DEST" ]] && exit

    mkdir -p "$OUTPUT"
    cp -ar "$SD_CARD"/* "$OUTPUT"
}

function fix_repo(){
    git --no-pager diff --name-only --cached | while read line; do
        ext=$line:t:e
        [[ "$ext" != "py" ]] && continue
        vim +silent +'set ts=2 noet | retab! | set et ts=4 | retab' +wqall "$line"
    done
}

function upgrade(){
        yay -Syu --noconfirm
        bak_pref
}

function bu(){
	prev="$PWD"
	echo ""$BLUE"Project: university"$NOCOLOR""
    cd ~/Desktop/Fall\ 2019/
    find . -maxdepth 1 -type d | while read dir; do
        GOTO="$dir"/notes/exported
        waypoint="$PWD"
        if [[ -d "$GOTO" ]]; then
            SUBJECT="$(echo "$dir" | sed 's/\.\///g')"
            echo ""$GREEN"[+] Compiling $SUBJECT notes"$NOCOLOR""
            cd "$GOTO"
            pdftk $(ls -v) cat output ../compiled_"$SUBJECT"_notes.pdf
            cd "$waypoint"
        fi
    done
    cd ~/Projects/university/
    echo ""$GREEN"[+] Finished compiling, now committing to Github..."$NOCOLOR""
    git add * 
    git commit -m 'Automatic backup from the terminal...beep bloop'
    git push origin master
	cd "$prev"
}


VISUAL=editor; export VISUAL EDITOR=vim; export EDITOR
export SPOTIPY_CLIENT_ID='d2697e8198c449f09abd2e0833f48dff'
export SPOTIPY_CLIENT_SECRET='862367c3080d49e782de1bd74641b876'
export SPOTIPY_REDIRECT_URI='http://localhost:8888'


# restart cinnamon if it is acting up
alias rc="sudo systemctl restart lightdm.service"


# all things related to writing documents

function nblog(){
	current_for_jekyll="$(date +%Y-%m-%d-)"
	[[ -z "$1" ]] && (echo "[-] Provide name for blog";exit)
	name=$(printf "$current_for_jekyll" && sed -e 's/\(.*\)/\L\1/;s/\ /-/g' <<< "$1")
	real="$(realpath ~/Projects/website/_posts/"$name".md)"
	cp -ar ~/Projects/university/LaTeX\ Templates/blog_template.md "$real"
	sed -i 's/title.*/title\:\t'$1'/g' "$real" 
	vim ~/Projects/website/_posts/"$name".md
	# https://github.com/monostream/tifig/releases
	# https://gist.github.com/bittercoder/f6601784ebe4f63e9b9e037e3344b960
}

# new article
function nmla() {
	[[ -z "$1" ]] && (echo "[-] Provide name for article";exit)
	if [[ ! -f "$1" ]]; then
		cp -ar ~/Projects/university/LaTeX\ Templates/papers/mla.tex ./"$1".tex
		perl -i -pe "s/.*/$1/ if $.==62;s/CURRENT\ DATE/$CURRENT/" "$1".tex
	else
		vim "$1".tex
	fi
}

function napa(){
	[[ -z "$1" ]] && (echo "[-] Provide name for article";exit)
	cp -ar ~/Projects/university/LaTeX\ Templates/APA_Template.tex ./"$1".tex
	perl -i -pe "s/.*/\\\title\{"$1"\}/ if $.==55" ./"$1".tex
	vim "$1".tex
}


function nmemo(){
	[[ -z "$1" ]] && exit
	cp -ar ~/Projects/university/LaTeX\ Templates/{memo.tex,texMemo.cls} .
	mv memo.tex "$1".tex
	vim "$1".tex
}
function git_helper() {
	cd "$1"
	git config --unset core.bare
	git add *
	git commit -m "Automated backup"
	git push origin master
}
function full_bak() {
	# this script is meant to facilitate backups that can be automated
	# TODO
	# Migrate all git repos to ~/Projects [CHECK]
	# Integrate bak_pref [CHECK]
	# Write documentation about this process []
	# Go through External and delete all unecessary files [] (Please try to make the total size no more than 128 GB. This is a goal that should be attained but not mandatory. It is an incentive to delete more unecessary crap)

	find ~/Projects -name '\.git' | while read repository; do
		l=$(echo "$repository" | sed 's/\.git//')
		echo ""$BLUE"Project: $(basename $l)"$NOCOLOR""
		echo "true" >> /tmp/full_bak_flag
		find "$l" -type f -not -path '*/\.git/*' | while read file; do
			size=$(stat --printf="%s" "$file")
			! [[ "$size" =~ '^[0-9+$]' ]] && break
			[[ "$size" -ge 100000000 ]] && (sed -i 's/true/false/g' /tmp/full_bak_flag;echo "$file" >> "$repository"/"$(basename "$l").log")
		done
		[[ "$(head -n 1 /tmp/full_bak_flag)" == "true" ]] &&  (echo "$GREEN""This repo can be committed and sent to Github""$NOCOLOR";git_helper "$(dirname $repository)") || (echo "$RED""Cannot commit because of files being too large. Please see $repository/$(basename "$l").log""$NOCOLOR")
		truncate -s 0 /tmp/full_bak_flag
	done
	bak_pref
}
set -g xterm-keys on

# remove duplicates
function rd() {	[[ -f "$1" ]] && (cat "$1" | awk '!seen[$0]++') || (echo "$1" | awk '!seen[$0]++') }

# check drive size
function chd() {
	[[ "$(whoami)" != "root" ]] && (echo "[-] Run as root";exit)
	# $1 -> current size (automate via path given)
	# $2 -> path to drive (see what I mean ^)
	dd if=/dev/random bs=1M count count="$1" of=randomfile
	dd if=randomfile of="$2"
	first="$(dd if=randomfile | sha256)"
	second="$(dd if="$2" | sha256)"
	[[ "$first" == "$second" ]] && (echo "[+] Drive is the size it claims to be") || (echo "[-] Drive is not the size it claims to be")
}
function mount_vmware() {
	# found going through old photos of tweets
	[[ ! -d "/tmp/vmware_mount" ]] && sudo mkdir -p /tmp/vmware_mount
	[[ ! -f "$1" || -z "$@" ]] && exit
	sudo mount "$1" /tmp/vmware_mount -o ro,loop=/dev/loop1,offset=32768 -t ntfs
}
function meme_template() {
	# adapted from a climagic tweet <3
	TOP="$2"
	BOTTOM="$3"
	[[ ! -f "$1" || -z "$@" ]] && exit
	convert "$1" -font Ubuntu -fill white -pointsize 48 -stroke black -strokewidth 2 -gravity north -annotate 0 "$TOP" -gravity south -annotate 0 "$BOTTOM" outputmeme
}

function batt_drain() {
	[[ "$(whoami)" != "root" ]] && exit || stress --cpu 4 --io 2 -vm2 --vm-bytes 128M
}

function slide_show(){ feh -F -D90 --recursive --randomize --auto-zoom ~/Pictures }
function clone_drive { rsync -av --delete /media/jared/New\ External/* /media/jared/Long\ Term/ }

# find directories that contain certain types of files
#function find_type_dir{ find . -name ".*$1" | sed 's/\/[^\/]*$//' | sort | uniq }
# Chaining multiple "grep commands" using one line in AWK
# awk '/a/ && /b/ && ! /c/ && /d/' --> grep 'a' | grep 'b' | grep -v 'c' | grep 'd'

# sudo apt-get install intel-microcode microcode.ctl -y


# ALIASES #

## NAVIGATION ##

alias gh="cd ~"
alias ga="cd ~/Applications"
alias gai="cd ~/Applications/Cydia\ Impactor"
alias cdd="cd ~/Desktop"
#alias cdds="cd '$(find ~/Desktop -maxdepth 1 | while read line; do [[ -L "$line" ]] && echo "$line"; done)'"
alias cdds="cd ~/Desktop/Fall_2021/"

alias gp="cd ~/Projects"
alias gu="cd ~/Projects/university"
alias gus="cd ~/Projects/university/scripts"
alias gpb="cd ~/Projects/backed-development"
alias gpw="cd ~/Projects/website"

alias ge="cd /media/"$USER"/External\ New"
alias gs="cd ~/scripts"

## BACKING UP ##


## MACROS FOR MISC OPERATIONS ##

alias us="cp -ar /usr/lib/python3.8/starbucksautoma/* ~/Projects/starbucks_automa_production/usr/lib/python3.8/starbucksautoma/"
alias ue="umount /media/"$USER"/External\ New && sleep 3 && notify-send 'You can now unplug External New'"
alias ua="umount /media/"$USER"/*"

## FILE MANIPULATION ##

alias sz="source ~/.zshrc"
alias zrc="vim ~/.zshrc"
alias vrc="vim ~/.vimrc"
alias vx="vim ~/.Xresources"
alias rgrep="grep -r"
alias dc="cd"

## SYSTEM MAINTAINCE ##

alias ut="uptime -p"
alias up="sudo apt-get update && sudo apt-get upgrade -y"
alias lg="sudo find "$HOME" -type d -name '.git'"
alias bp="dpkg -l | awk '/Name/{y=1;next}y {print $2}' | sed '/^$/d' > ~/Projects/thin-mint/current_installed/$D.txt"
alias dvc="rm -rf ~/.cache/vim/swap/*"

function rmb(){
  find . -type f | while read file; do 
    [[ "$(file "$file" | grep "ELF")" ]] && rm -f "$file"
  done
}

## APPLICATION MACROS ##

alias rs="Rscript"
alias jsc="shutter -f -o java_screenshot.png > /dev/null 2>&1 & disown"
alias sl="ls"

## POWER MANAGEMENT ##

# turning suspend when inactive while on battery power (for YouTube and other idle activities)

alias pma="dconf write /org/cinnamon/settings-daemon/plugins/power/sleep-inactive-battery-timeout 600"
alias pmd="dconf write /org/cinnamon/settings-daemon/plugins/power/sleep-inactive-battery-timeout 0"


# Spotify API Credentials

export SPOTIFY_SECRET_KEY="84c1c81be6f347629bf01b97fbbe883c"
export SPOTIFY_AUTHENTICATOR_CLIENT_ID="e1f239ec0ee443689d6786fd3f397af1"
export SPOTIFY_AUTHENTICATOR_CLIENT_SECRET="cbecd4d200f8482d910cb1db77d6f10c"

## SOURCING THINGS ##


function ff(){
        base="/home/jared/Desktop/Fall 2019/MATH-338"
        expression="$1"
        [[ -z "$expression" ]] && return
        find "$base"/labs "$base"/exam_two/helpful_scripts "$base"/exam_two/script_tree -type f -name '*.r' -exec grep --color=always -ni "$1" {} /dev/null \;
}

LOCAL_PATH="$HOME/.local/bin/"
export PATH="$LOCAL_PATH:$PATH:/home/jared/.gem/ruby/2.6.0/bin"
alias vi="vim"


function oapp(){
  application_name="$(echo "$1" | awk '{print tolower($0)}')"
	"$application_name" > /dev/null 2>&1 & disown
}

# kill all the open instances of xreader
alias kpdf="kapp xreader"

function hmem(){
  # show top 10 most resource hungry processes
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head
}
alias cddc="cd ~/Desktop/C-Programming/"
alias rw="restart_wifi"

#function git_patcher(){
  #[[ ! -d ".git" ]] && exit 1
  #[[ "$(git)" ]]
#}
#
source /home/jared/.zsh_utils/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

function show_colour() {
  [[ -z "$@" ]] && return
  for color in "$@"; do
    printf '\e]4;1;%s\a\e[0;41m   \n   \n\e[m' "$color"
    echo -e "\n"
  done
}

function connectheadphones(){
  echo "connect 2C:41:A1:82:F3:15" | bluetoothctl
}

function disconnectheadphones(){
  echo "disconnect 2C:41:A1:82:F3:15" | bluetoothctl
}

function pip_git(){
    sudo pip install --upgrade git+"$1"#egg=httpie
}

alias get_arch="wget http://mirror.sfo12.us.leaseweb.net/archlinux/iso/2020.06.01/archlinux-2020.06.01-x86_64.iso ~/Desktop"
alias usa="sudo pip install --upgrade git+https://github.com/JaredDyreson/starbucks_automa_production#egg=httpie"

function reload_site(){
    site="https://www.jareddyreson.xyz"
    ssh -t root@"$(basename $site)" 'update_server && echo Success'
    sleep 2
    [[ "$(curl --silent "$site")" ]] && echo "up" || echo "down"
}

function new_invoice(){
    invoice_dir="$HOME/Documents/lancer-invoices"
    current="$(date '+%Y-%m-%d')"
    unset subject
    vared -p "Subject: " -c subject
    subject="$(sed 's/\ /_/g' <<< "$subject")"
    new_invoice="$invoice_dir/"$current"_"$subject".zip"
    echo -n '\x50\x4b\x05\x06\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00' > "$new_invoice"
    file-roller "$new_invoice"
    gpg -c "$new_invoice"
}

#wal -a 75 -i ~/Pictures/Wallpapers/venom_wallpaper.jpg -q
#
alias plex="make_run_latex"
alias publicip="wget http://ipecho.net/plain -O - -q && echo"

# set filetypes

xdg-mime default pix.desktop image/png 
xdg-mime default pix.desktop image/jpg 
xdg-mime default pix.desktop image/jpeg 
xdg-mime default pix.desktop image/gif 

function nkt(){
    # i am lazy; new kernel template
    vared -p "Title: " -c title
    title="$(sed 's/\ /_/g' <<< "$title")"
    DEST=~/Projects/OS-Toolbox/assignments/"$title"
    mkdir "$DEST"
    cp ~/Projects/OS-Toolbox/templates/main_template.c "$DEST"/main.c
    cp ~/Projects/OS-Toolbox/templates/Makefile "$DEST"/Makefile
    cd "$DEST"
    echo "[INFO] Created project $title"
}

function gadd(){

    vared -p "Commit: " -c message
    [[ -d includes && -d src ]] && find includes src -type f -exec vim +ClangFormat +wq {} \;

    find . -type f -name '*.py' -exec autopep8 --in-place --aggressive --aggressive {} \;

    git add *
    git commit -m "$message"
    git push origin
}

function cform() {
    find includes src -type f -name '*.c' | while read file; do
        # echo "[INFO] Processing $file"
        #vim --not-a-term +ClangFormat +wq "$file"
        clang-format -i "$file" -style=Google --verbose
    done
}

function pd() {
    pdfgrep -Rnie "$1"
}

# Colors
default=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 2)
purple=$(tput setaf 5)
orange=$(tput setaf 9)

# Less colors for man pages
export PAGER=less
# Begin blinking
export LESS_TERMCAP_mb=$red
# Begin bold
export LESS_TERMCAP_md=$orange
# End mode
export LESS_TERMCAP_me=$default
# End standout-mode
export LESS_TERMCAP_se=$default
# Begin standout-mode - info box
export LESS_TERMCAP_so=$purple
# End underline
export LESS_TERMCAP_ue=$default
# Begin underline
export LESS_TERMCAP_us=$green

export TEXMFHOME="/home/jared/texmf/"
