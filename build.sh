#/bin/bash

while true
do
    for f in *.md
    do
        base="${f%.*}"
        cat head.html > $base.html
        markdown $f >> $base.html
        echo "</article></body></html>" >> $base.html
    done
    sleep 1
done
