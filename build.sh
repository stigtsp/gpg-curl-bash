#!/bin/bash
set -e

### Configure these parameters ###

SCRIPT_URL=https://stig.io/ssh
SSH_KEY_FILE=public/id_rsa.pub
GPG_KEY_FILE=public/pubkey.asc

##################################

GPG_FINGERPRINT=$(gpg --with-colons --import-options show-only --import $GPG_KEY_FILE | head -1 | cut -f5 -d':')

for f in ssh keys.html; do
	echo "[$0] Generating public/$f";
	cp $f.template $f.tmp
	perl -pi -e "s|\#\#\#SSH_KEY\#\#\#|chomp(my \$a=qx(cat $SSH_KEY_FILE));\$a|egs" $f.tmp
	perl -pi -e "s|\#\#\#GPG_KEY\#\#\#|qx(cat $GPG_KEY_FILE)|egs" $f.tmp
	perl -pi -e "s|\#\#\#GPG_FINGERPRINT\#\#\#|$GPG_FINGERPRINT|gs" $f.tmp
	perl -pi -e "s|\#\#\#SCRIPT_URL\#\#\#|$SCRIPT_URL|gs" $f.tmp
	gpg --yes --armor --output public/$f --local-user $GPG_FINGERPRINT --clearsign $f.tmp
	rm $f.tmp
done
echo -e "#!/bin/bash\n<<ENDOFSIGSTART=\n$(cat public/ssh)" > public/ssh
echo "[$0] Done"
