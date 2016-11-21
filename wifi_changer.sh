
NewPassword=`openssl rand -base64 6 | md5sum | cut -c 1-9`
echo "New Password: $NewPassword"

CurrentMouth=`cal | head -n 1`
echo "Current Mouth: $CurrentMouth"

weeknumber=`date +%V`
echo "Week number:$weeknumber"

dateofcurrentweek=`date +%w`
echo "Week day:$dateofcurrentweek"

###################
currentunixtime=`date +%s`
weekinseconds="1209600"

addedweektime=$(expr $currentunixtime + $weekinseconds)

echo "currentunixtime:$currentunixtime"
echo "addedweektime:$addedweektime"

CURRENTWEEK=`date -d@"$currentunixtime"`
NEXTWEEK=`date -d @"$addedweektime"`

echo "CURRENTWEEK $CURRENTWEEK"
echo "NEXTWEEK $NEXTWEEK"

CURRENTWEEK_RIGHTFORMAT=`date -d @"$currentunixtime" +%Y-%m-%d`
NEXTWEEK_RIGHTFORMAT=`date -d @"$addedweektime" +%Y-%m-%d`

echo "NEXTWEEK_RIGHTFORMAT $NEXTWEEK_RIGHTFORMAT"
echo "CURRENTWEEK_RIGHTFORMAT $CURRENTWEEK_RIGHTFORMAT"

echo "PASSWORD FROM DATE: $CURRENTWEEK_RIGHTFORMAT to DATE: $NEXTWEEK_RIGHTFORM$

#########

DATE=`date +%Y-%m-%d`

mkdir /wrk/tmp

WIRELESS_CURRENT_ETC_CONFIG="/etc/config/wireless"

cp $WIRELESS_CURRENT_TEMPLATE $WIRELESS_WORKING_TEMPLATE

ORIGINAL_MAIL_TEMPLATE="/wrk/wifi_email_template.html"
WORKING_MAIL_TEMPLATE="/wrk/tmp/wifi_email_working.html"

cp $ORIGINAL_MAIL_TEMPLATE $WORKING_MAIL_TEMPLATE

sed -i -e "s/NEWPASSWORD/$NewPassword/g" $WORKING_MAIL_TEMPLATE

sed -i -e "s/CURRENTWEEK/$CURRENTWEEK_RIGHTFORMAT/g" $WORKING_MAIL_TEMPLATE
sed -i -e "s/NEXTWEEK/$NEXTWEEK_RIGHTFORMAT/g" $WORKING_MAIL_TEMPLATE

sed -i -e "s/NEWPASSWORD/$NewPassword/g" $WIRELESS_WORKING_TEMPLATE

cp $WIRELESS_WORKING_TEMPLATE $WIRELESS_CURRENT_ETC_CONFIG

rcptto="yourmail@companyname.ru"

ORIGINAL_MAIL_ATTACH="/wrk/email_attachment.rtf"
WORKING_MAIL_ATTACH="/wrk/tmp/email_attachment.rtf"

cp $ORIGINAL_MAIL_ATTACH $WORKING_MAIL_ATTACH

sed -i -e "s/NEWPASSWORD/$NewPassword/g" $WORKING_MAIL_ATTACH
sed -i -e "s/CURRENTWEEK/$CURRENTWEEK_RIGHTFORMAT/g" $WORKING_MAIL_ATTACH
sed -i -e "s/NEXTWEEK/$NEXTWEEK_RIGHTFORMAT/g" $WORKING_MAIL_ATTACH

sleep 3

boundary=$(uuidgen -t)

sendmail -t <<EOF!
From: wifi@companyname.ru
To: admins@companyname.ru
Subject: ▒^▒а▒^▒ол▒^▒ на го▒^▒▒^▒евой WiFi
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="${boundary}"

--${boundary}
Content-type: text/html; charset=utf-8
Content-Disposition: inline

$(cat $WORKING_MAIL_TEMPLATE)
--${boundary}
content-type: text/richtext
content-transfer-encoding: base64
content-disposition: attachment; filename="WORKING_MAIL_ATTACH"

$(openssl base64 < $WORKING_MAIL_ATTACH)
--${boundary}--
EOF!

#cat $WORKING_MAIL_TEMPLATE | sendmail -t

#####################

sleep 3

/etc/init.d/network restart

sleep 3

rm -rf /wrk/tmp/*
rmdir /wrk/tmp