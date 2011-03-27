for line in "`cat $1 | node runjslint.js`"
do
    echo $1:$line
done
