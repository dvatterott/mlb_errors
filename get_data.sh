#!/bin/bash

YEAR=$1
FILE_LOC=https://www.retrosheet.org/events/${YEAR}eve.zip

echo "---------DOWNLOAD----------"
wget $FILE_LOC -O ./raw_data/${YEAR}.zip

echo "---------UNPACK----------"
mkdir raw_data/${YEAR}/
unzip -o raw_data/${YEAR}.zip -d raw_data/${YEAR}/

# export playbyplay to single file
mkdir processed_data/${YEAR}/
find raw_data/${YEAR}/ -regex '.*EV[A|N]' | xargs grep play > ./processed_data/${YEAR}/playbyplay.out

# get all plate appearances from data (and hitter). remove all non plate appearance rows
cat ./processed_data/${YEAR}/playbyplay.out | \
	awk -F',' '{print $4","$7}' | \
	grep -Ev ',(NP|BK|CS|DI|OA|PB|WP|PO|POCS|SB)' > \
	./processed_data/${YEAR}/batters.out

# one giant roster file
find raw_data/${YEAR}/ -name '*ROS' | xargs awk -F',' '{print $1" "$2" "$3}' > ./processed_data/${YEAR}/players.out

echo "---------PLAYERS WITH MOST PLATE APPEARANCES----------"
cat ./processed_data/${YEAR}/batters.out | awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' | sort -k2 -nr | head > ./processed_data/${YEAR}/most_pa.out
join <(sort -k 1 ./processed_data/${YEAR}/players.out) <(sort -k 1 ./processed_data/${YEAR}/most_pa.out) | uniq | sort -k 4 -nr | head | awk '{print $3", "$2", "$4}'


echo "---------PLAYERS WITH MOST HITS----------"
cat ./processed_data/${YEAR}/batters.out | grep -E ',(S|D|T|HR)' | awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' | sort -k2 -nr | head

echo "---------PLAYERS WITH MOST AT BATS----------"
cat ./processed_data/${YEAR}/batters.out | grep -Ev 'SF|SH' | grep -E ',(S|D|T|HR|K|[0-9]|E|DGR|FC)' | awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > ./processed_data/${YEAR}/abs.out
cat ./processed_data/${YEAR}/abs.out | sort -k2 -nr | head

echo "---------PLAYERS WHO HIT INTO THE MOST ERRORS----------"
cat ./processed_data/${YEAR}/batters.out | grep ',E[0-9]' | awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > ./processed_data/${YEAR}/errors.out
cat ./processed_data/${YEAR}/errors.out | sort -k2 -nr | head

echo "---------PLAYERS WITH MOST ERRORS PER AT BAT----------"
join <(sort -k 1 ./processed_data/${YEAR}/abs.out) <(sort -k 1 ./processed_data/${YEAR}/errors.out) | uniq | awk -v OFS=', ' '$2 > 250 {print $1, $3, $2, $3/$2}' >  ./processed_data/${YEAR}/errors_abs.out
cat ./processed_data/${YEAR}/errors_abs.out | sort -k 4 -nr | head


echo "---------PLAYERS WITH MOST ERRORS PER BALL IN PLAY----------"
cat ./processed_data/${YEAR}/batters.out | grep -Ev 'SF|SH' | grep -E ',(S|D|T|HR|[0-9]|E|DGR|FC)' | awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > ./processed_data/${YEAR}/bip.out
join <(sort -k 1 ./processed_data/${YEAR}/bip.out) <(sort -k 1 ./processed_data/${YEAR}/errors.out) | uniq | awk -v OFS=', ' '$2 > 250 {print $1, $3, $2, $3/$2}' >  ./processed_data/${YEAR}/errors_bip.out
cat ./processed_data/${YEAR}/errors_bip.out | sort -k 4 -nr | head
#cat ./processed_data/${YEAR}/errors_bip.out | awk -F', ' '{ error_total += $2; bip_total += $3; avg_total += $4; count++ } END { print error_total, bip_total, avg_total/count }'

