#!/bin/bash
set -e
#set -x
TIDY_OUT=/tmp/tidy_out.$$

CASECOUNT_HERE=$( ls _cases/*/*.md|wc -l )
CASECOUNT_THERE=$( ls csirt.divd.nl/_cases/*/*.md|wc -l )
if [[ $CASECOUNT_HERE -le 0 || $CASECOUNT_HERE -ne $CASECOUNT_THERE ]]; then
	echo "_cases directory is not updated, run ./update.sh"
	exit 1
fi
POSTCOUNT_HERE=$( ls _csirt_posts|wc -l )
POSTCOUNT_THERE=$( ls csirt.divd.nl/_posts|wc -l )
if [[ $POSTCOUNT_HERE -le 0 || $POSTCOUNT_HERE -ne $POSTCOUNT_THERE ]]; then
	echo "_csirt_posts directory is not updated, run ./update.sh"
	exit 1
fi
CVECOUNT_HERE=$( ls _cves|wc -l )
CVECOUNT_THERE=$( ls csirt.divd.nl/_cves|wc -l )
if [[ $CVECOUNT_HERE -le 0 || $CVECOUNT_HERE -ne $CVECOUNT_THERE ]]; then
	echo "_cves directory is not updated, run ./update.sh"
	exit 1
fi
echo "*** Internal link check ***"
htmlproofer \
	--disable_external \
	--allow-hash-href  \
	--ignore-urls="/#menu/" \
	--no-enforce-https \
	_site
echo "*** External link check ***"
#(set +e ; htmlproofer \
#	--allow-hash-href \
#	--url-ignore="/www.linkedin.com/","/twitter.com/","/#menu/" _site || exit 0 )
(
	html5validator _site/*.html _site/*/*.html _site/*/*/*.html _site/*/*/*/*.html _site/*/*/*/*.html | grep -v '/weesjes/index.html'
) | tee $TIDY_OUT
ERRORS=$( grep 'error:' $TIDY_OUT | wc -l )
if [[ $ERRORS -gt 0 ]] ; then
	echo "------------------------------------------------------------------------------------"
	echo "There are $ERRORS errors in html files, not good enough!"
	grep 'Error:' $TIDY_OUT
	exit 1
else
	echo "------------------------------------------------------------------------------------"
	echo " HTML checked and found flawles, \0/ \0/ \0/ \0/ \0/ \0/ "
	echo "------------------------------------------------------------------------------------"
fi
WEESJES=$( grep 'Wees:' _site/weesjes/index.html | wc -l )
if [[ $WEESJES -gt 0 ]]; then
	echo "------------------------------------------------------------------------------------"
	echo " There are $WEESJES orphaned team members, they have contributed to a case, report "
	echo " or blog post, but don't have a team page"
	cat _site/weesjes/index.html
	echo "------------------------------------------------------------------------------------"
	#exit 1
fi