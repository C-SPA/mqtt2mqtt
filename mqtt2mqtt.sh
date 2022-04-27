# Requires python3 and geohash2 library
# pip3 install geohash2
mosquitto_sub -h cfsr.bse.vt.edu -t VTSFIN/HalterSenders/data -u vtsmart01 -P 'Sm@rtF@rm' | \
               while read i;do
               if echo $i | grep -vE 'GH([a-z0-9]{5,})';then echo junk;continue;fi
               jsonstr=`echo $i | \
                       sed -E -e 's/(.*)ID(.*)(TS[0-9].*)/ID:\2::\3/' \
                       -e 's/(.*)TS([0-9]{4,10})([A-Z].*)/\1:TimeSinceEpoch:\2::\3/' \
                       -e 's/(.*)GH([a-z0-9]{5,})([A-Z].*)/\1:GeoHash:\2::\3/' \
                       -e 's/(.*)T([0-9]{1,}.[0-9]{0,})([A-Z].*)/\1:Temperature:\2::\3/' \
                       -e 's/(.*[0-9]|:)P([0-9]{1,}.[0-9]{0,})(:|[A-Z].*)/\1:Pressure:\2::\3/' \
                       -e 's/(.*[0-9]|:)RH([0-9]*\.?[0-9]+)(:|[A-Z].*)/\1:RelativeHumidity:\2::\3/' \
                       -e 's/(.*[0-9]|:)TV([0-9]*\.?[0-9]+)(:|[A-Z].*)/\1:TotalVolitile:\2::\3/' \
                       -e 's/(.*[0-9])LD([0-9]{1,}.[0-9]{0,})([A-Z].*)/\1:LidarDistance:\2::\3/' \
                       -e 's/(.*[0-9])CO([0-9]{1,}.[0-9]{0,})(:|[A-Z].*)/\1:CarbonDioxide:\2::\3/' \
                       -e 's/(.*[0-9])GR([0-9]{1,}.[0-9]{0,})(:|[A-Z].*)/\1:GasResistance:\2::\3/' \
                       -e 's/(.*[0-9])VLD([0-9]{1,}.[0-9]{0,})(:|[A-Z].*)/\1:LidarDistance:\2::\3/' \
                       -e 's/(.*[0-9])V([0-9]{1,}.[0-9]{0,})([A-Z].*)/\1:Velocity:\2::\3/' \
                       -Ee 's@(.*[a-z0-9]|:)A([0-9]+\.?[0-9]+?)([A-Z]|:)@\1:Altitude:\2::\3@' \
                       -e 's/(.*[0-9]|:)C([0-9])/\1:LocalIndex:\2::/'
                       `
                       GeoHash=`echo $jsonstr | sed -E -e 's/.*GeoHash:([a-z0-9]+):.*/\1/'`
                       pystr="import geohash2;print(geohash2.decode(\"${GeoHash}\"))"
                       latlon=`python3 -c "$pystr"`
#('35.10686881', '-106.686096')
#declat=`echo $latlon | sed "s@[\(\',\)]@@g" | IFS=\  read Declat Declon`
                       echo $latlon | sed "s@[\(\',\)]@@g" | IFS=" " read Declat Declon
                       IFS=" "; read Lat Lon <<<`echo $latlon | sed "s@[\(\',\)]@@g" `
                       jsonstr="Lat:"$Lat":::Lon:"$Lon":::"${jsonstr}
                       jsonstr="[{\"RegExref:"${i}":::"${jsonstr}"\"}]"
                       jsonstr=`echo ${jsonstr} | sed -E 's/:{3,3}/,/g'`
                       jsonstr=`echo ${jsonstr} | sed -E 's/:{2,2}//g'`
                       jsonstr=`echo ${jsonstr} | sed -E 's/:/\":\"/g'`
                       jsonstr=`echo ${jsonstr} | sed -E 's/,/\",\"/g'`
                       echo $jsonstr | mosquitto_pub -h cfsr.bse.vt.edu -t usdajson -u usdadev -P U5DAPa55 -s

                       done
