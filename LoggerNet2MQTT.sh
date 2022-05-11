lnfilename=`ls -dr /mnt/c/Campbellsci/LoggerNet/* | head -n1`

jsonstr=`sed -e '1d' -e '3,4d' $lnfilename | python3 -c 'import csv, json, sys;  print(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)]))'`

echo $jsonstr | mosquitto_pub -h cfsr.bse.vt.edu -t usdajson -u usdadev -P U5DAPa55 -s
#echo $jsonstr | ./websocat_linux64 ws://servport.wildsong.lan:6180/test
echo $jsonstr

