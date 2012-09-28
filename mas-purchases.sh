#!/bin/zsh
# parse a file of your Mac App Store purchases
#
# From:	Timothy J. Luoma
# Mail:	luomat at gmail dot com
# Date:	2012-09-28

NAME="$0:t"

	# You must save this file first from the Mac App Store app
	# enable the 'debug' menu by:
	# 1. Quitting the App Store app
	# 2. In Terminal, enter:
	# 	defaults write com.apple.appstore ShowDebugMenu -bool true
	# 	(without the '#' obviously)
	# 3. Relaunch the App Store app
	# 4. Open the 'Purchases' tab (or button or whatever it is)
	# 5. Once the page has fully loaded, go to the Debug menu and choose
	#		"Save page source to disk"
	#
	# That will create this file.
FILE='/private/tmp/pageSource.html'

	# Where do you want the nicely-formatted version to be saved to?
	# The path will be created, if needed.
	#
	# I save it as an .xhtml file. If you don't like that
	# change it to something else.
	#
	# Also, I save mine in my Public Dropbox folder because of reasons.
	# Feel free to change that too.
SAVETO="$HOME/Dropbox/Public/$NAME.xhtml"

	# what browser do you want it opened in?
BROWSER="Safari"


	# if you use a different store (non US), change this
	# if you're not sure which one you use, check the pageSource.html
APP_STORE_BASE_URL='https://itunes.apple.com/us/app/'


####|####|####|####|####|####|####|####|####|####|####|####|####|####|####
#
# You do not need to edit anything below this line

#
# $SAVETO:h = `dirname $SAVETO`
#

if [[ ! -d "$SAVETO:h" ]]
then
		# if the directory isn't found, try to create it
		
		mkdir -p "$SAVETO:h" || exit 2
	
fi	

	# zsh needs this for strftime
zmodload zsh/datetime

DATE=$(strftime "%Y-%m-%d at %r %Z" "$EPOCHSECONDS")

FILE=($FILE(:A))

[[ ! -e "$FILE" ]] && echo "$FILE not found" && exit 1

[[ ! -r "$FILE" ]] && echo "$FILE is not readable" && exit 1

[[ ! -f "$FILE" ]] && echo "$FILE is not regular file" && exit 1

[[ ! -s "$FILE" ]] &&  echo "$FILE is empty" && exit 1


cat <<EOINPUT >$SAVETO
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
		<title>Mac App Store Purchases</title>
		<style type="text/css">
		img { vertical-align:middle ; margin-right: 1em; }
		p { font-size: small; } 
		</style>
	</head>
<body>

<h1>Mac App Store Purchases</h1>

<ol>
EOINPUT

#
# Grab only the lines that have the URL we want
# get rid of the <script line
# delete control characters (nasty little buggers)
# used sed to clean up the remaining HTML
# sort by 'key 5' which is the name of the app
# Add a </li> because we are making this an ordered 
# list so you can see how many apps you have.
#
fgrep "$APP_STORE_BASE_URL" "$FILE" |\
egrep -v '<script '  |\
tr -d '[:cntrl:]' |\
sed 's#^ *#<li>#g; s#</li></ul>    #\
<li>#g' |\
sed 's#</h2></li><li># by #g ; s#<div class="artwork">##g ; s###g ; s#<ul class="list info"><li><h2>##g ; s# class="artwork-link"##g; s# class="artwork"##g;  s#</div>##g ; s#    ##g; s#</li>##g; s#</ul>##g' |\
sort --key=5 --ignore-case --dictionary-order --ignore-leading-blanks |\
sed 's#$#</li>#g' >> "$SAVETO"

# Close up the HTML file

echo "</ol>

<p>Last updated: $DATE</p>

</body></html>" >> "$SAVETO"

	# open the file in the browser of your choice

open -a "$BROWSER" "$SAVETO"

	# Done!

exit 0

#
#EOF
