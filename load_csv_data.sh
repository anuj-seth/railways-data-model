pguser=$1
pgdb=$2
pgpassword=$3

[ -a Train_details_22122017.csv.gz ] &&   gunzip Train_details_22122017.csv.gz

export PGPASSWORD=${pgpassword}

psql -U $pguser -d $pgdb -h 127.0.0.1 <<EOF

\copy staging_trains from 'Train_details_22122017.csv' csv header;

EOF

gzip Train_details_22122017.csv
