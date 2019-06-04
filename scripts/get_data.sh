#!/bin/bash

YEAR=$1
FILE_LOC=https://www.retrosheet.org/events/${YEAR}eve.zip

echo "---------DOWNLOAD----------"
wget -nc $FILE_LOC -O ./raw_data/${YEAR}.zip

echo "---------UNPACK----------"
mkdir raw_data/${YEAR}/
unzip -o raw_data/${YEAR}.zip -d raw_data/${YEAR}/

# export playbyplay to single file
mkdir processed_data/${YEAR}/
find raw_data/${YEAR}/ -regex '.*EV[A|N]' | xargs grep play > ./processed_data/${YEAR}/playbyplay.out

# get all plate appearances from data (and hitter). remove all non plate appearance rows
cat ./processed_data/${YEAR}/playbyplay.out | \
    awk -F',' '{print $4","$7}' | \
    grep -Ev ',[A-Z]{3}[0-9]{2}' | \
    grep -Ev ',(NP|BK|CS|DI|OA|PB|WP|PO|POCS|SB|FLE)' > \
	 ./processed_data/${YEAR}/batters.out

# one giant roster file
find raw_data/${YEAR}/ -name '*ROS' | \
    xargs awk -F',' '{print $1" "$2" "$3}' > \
	  ./processed_data/${YEAR}/players.out

echo "---------PLAYERS WITH MOST PLATE APPEARANCES----------"
cat ./processed_data/${YEAR}/batters.out | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' | \
    sort -k2 -nr > \
	 ./processed_data/${YEAR}/most_pa.out
join <(sort -k 1 ./processed_data/${YEAR}/players.out) <(sort -k 1 ./processed_data/${YEAR}/most_pa.out) | \
    uniq | \
    sort -k 4 -nr | \
    head | \
    awk '{print $3", "$2", "$4}'


echo "---------PLAYERS WITH MOST HITS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -E ',(S|D|T|HR)' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/hits.out

echo "---------PLAYERS WITH MOST AT BATS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -Ev 'SF|SH' | \
    grep -E ',(S|D|T|HR|K|[0-9]|E|DGR|FC)' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/abs.out
cat ./processed_data/${YEAR}/abs.out | \
    sort -k2 -nr | \
    head

echo "---------PLAYERS WITH THE MOST KS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep ',K' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/strikeouts.out
cat ./processed_data/${YEAR}/strikeouts.out | \
    sort -k2 -nr | \
    head

echo "---------PLAYERS WITH THE MOST BBS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -E ',(I|IW|W)' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/walks.out
cat ./processed_data/${YEAR}/walks.out | \
    sort -k2 -nr | \
    head

echo "---------PLAYERS WITH MOST KS PER PLATE APPEARANCE----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/most_pa.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/strikeouts.out) | \
    join - <(sort -k 1 ./processed_data/${YEAR}/players.out) | \
    uniq | \
    awk -v OFS=', ' '{print $1, $5" "$4, $3, $2}' > \
	./processed_data/${YEAR}/strikeouts_pa.out
cat ./processed_data/${YEAR}/strikeouts_pa.out | \
    sort -k 4 -nr | \
    head

echo "---------PLAYERS WITH MOST BBS PER PLATE APPEARANCE----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/most_pa.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/walks.out) | \
    join - <(sort -k 1 ./processed_data/${YEAR}/players.out) | \
    uniq | \
    awk -v OFS=', ' '{print $1, $5" "$4, $3, $2}' > \
	./processed_data/${YEAR}/walks_pa.out
cat ./processed_data/${YEAR}/walks_pa.out | \
    sort -k 4 -nr | \
    head

echo "---------PLAYERS WHO HIT INTO THE MOST ERRORS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -Ev 'SF|SH' | \
    grep ',E[0-9]' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/errors.out
cat ./processed_data/${YEAR}/errors.out | \
    sort -k2 -nr | \
    head

echo "---------PLAYERS WITH MOST ERRORS PER AT BAT----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/abs.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/errors.out) | \
    uniq | \
    awk -v OFS=', ' '{print $1, $3, $2, $3/$2}' > \
	./processed_data/${YEAR}/errors_abs.out
cat ./processed_data/${YEAR}/errors_abs.out | \
    sort -k 4 -nr | \
    head

echo "---------PLAYERS WITH MOST ERRORS PER BALL IN PLAY----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -Ev 'SF|SH' | \
    grep -E ',(S|D|T|HR|[0-9]|E|DGR|FC)' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/bip.out

echo "---------PLAYERS WITH HITS PER BALL IN PLAY----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/bip.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/hits.out) | \
    join - <(sort -k 1 ./processed_data/${YEAR}/players.out) | \
    uniq | \
    awk -v OFS=', ' '{print $1, $5" "$4, $3, $2}' > \
	./processed_data/${YEAR}/hits_bip.out


echo "---------PLAYERS WITH MOST ERRORS PER BALL IN PLAY----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/bip.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/errors.out) | \
    join - <(sort -k 1 ./processed_data/${YEAR}/players.out) | \
    uniq | \
        grep -Ev ',(NP|BK|CS|DI|OA|PB|WP|PO|POCS|SB|FLE)' > \
	 ./processed_data/${YEAR}/batt.out

# one giant roster file
find raw_data/${YEAR}/ -name '*ROS' | \
    xargs awk -F',' '{print $1" "$2" "$3}' > \
	  ./processed_data/${YEAR}/players.out

echo "---------PLAYERS WITH MOST PLATE APPEARANCES----------"
cat ./processed_data/${YEAR}/batters.out | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' | \
    sort -k2 -nr > \
	 ./processed_data/${YEAR}/most_pa.out
join <(sort -k 1 ./processed_data/${YEAR}/players.out) <(sort -k 1 ./processed_data/${YEAR}/most_pa.out) | \
    uniq | \
    sort -k 4 -nr | \
    head | \
    awk '{print $3", "$2", "$4}'


echo "---------PLAYERS WITH MOST HITS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -E ',(S|D|T|HR)' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/hits.out

echo "---------PLAYERS WITH MOST AT BATS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -Ev 'SF|SH' | \
    grep -E ',(S|D|T|HR|K|[0-9]|E|DGR|FC)' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/abs.out
cat ./processed_data/${YEAR}/abs.out | \
    sort -k2 -nr | \
    head

echo "---------PLAYERS WITH THE MOST KS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep ',K' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/strikeouts.out
cat ./processed_data/${YEAR}/strikeouts.out | \
    sort -k2 -nr | \
    head

echo "---------PLAYERS WITH THE MOST BBS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -E ',(I|IW|W)' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/walks.out
cat ./processed_data/${YEAR}/walks.out | \
    sort -k2 -nr | \
    head

echo "---------PLAYERS WITH MOST KS PER PLATE APPEARANCE----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/most_pa.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/strikeouts.out) | \
    join - <(sort -k 1 ./processed_data/${YEAR}/players.out) | \
    uniq | \
    awk -v OFS=', ' '{print $1, $5" "$4, $3, $2}' > \
	./processed_data/${YEAR}/strikeouts_pa.out
cat ./processed_data/${YEAR}/strikeouts_pa.out | \
    sort -k 4 -nr | \
    head

echo "---------PLAYERS WITH MOST BBS PER PLATE APPEARANCE----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/most_pa.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/walks.out) | \
    join - <(sort -k 1 ./processed_data/${YEAR}/players.out) | \
    uniq | \
    awk -v OFS=', ' '{print $1, $5" "$4, $3, $2}' > \
	./processed_data/${YEAR}/walks_pa.out
cat ./processed_data/${YEAR}/walks_pa.out | \
    sort -k 4 -nr | \
    head

echo "---------PLAYERS WHO HIT INTO THE MOST ERRORS----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -Ev 'SF|SH' | \
    grep ',E[0-9]' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/errors.out
cat ./processed_data/${YEAR}/errors.out | \
    sort -k2 -nr | \
    head

echo "---------PLAYERS WITH MOST ERRORS PER AT BAT----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/abs.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/errors.out) | \
    uniq | \
    awk -v OFS=', ' '{print $1, $3, $2, $3/$2}' > \
	./processed_data/${YEAR}/errors_abs.out
cat ./processed_data/${YEAR}/errors_abs.out | \
    sort -k 4 -nr | \
    head

echo "---------PLAYERS WITH MOST ERRORS PER BALL IN PLAY----------"
cat ./processed_data/${YEAR}/batters.out | \
    grep -Ev 'SF|SH' | \
    grep -E ',(S|D|T|HR|[0-9]|E|DGR|FC)' | \
    awk -F, '{a[$1]++;}END{for (i in a)print i, a[i];}' > \
	./processed_data/${YEAR}/bip.out

echo "---------PLAYERS WITH HITS PER BALL IN PLAY----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/bip.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/hits.out) | \
    join - <(sort -k 1 ./processed_data/${YEAR}/players.out) | \
    uniq | \
    awk -v OFS=', ' '{print $1, $5" "$4, $3, $2}' > \
	./processed_data/${YEAR}/hits_bip.out


echo "---------PLAYERS WITH MOST ERRORS PER BALL IN PLAY----------"
join -e"0" -a1 -a2 <(sort -k 1 ./processed_data/${YEAR}/bip.out) -o 0 1.2 2.2 <(sort -k 1 ./processed_data/${YEAR}/errors.out) | \
    join - <(sort -k 1 ./processed_data/${YEAR}/players.out) | \
    uniq | \
    awk -v OFS=', ' '{print $1, $5" "$4, $3, $2}' > \
	./processed_data/${YEAR}/errors_bip.out
cat ./processed_data/${YEAR}/errors_bip.out | \
    sort -k 4 -nr | \
    head
join <(sort -k 1 ./processed_data/${YEAR}/players.out) <(sort -k 1 ./processed_data/${YEAR}/errors_bip.out) | \
    awk '{print $3", "$2", "$4}' 

echo "--------Python Hypothesis Test------------"
python ./scripts/analysis.py ${YEAR}

