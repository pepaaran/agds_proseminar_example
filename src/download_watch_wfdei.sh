#!/bin/bash
# This script gets the WATCH-WFDEI data via lftp
# Run the script on the terminal, from the folder where you want to 
# download the data

# Create subdirectories for WFDEI data
for i in PSurf_daily Qair_daily Tair_daily
do
  mkdir ${i}
done

# Open ftp connection to IIASA database
lftp -u rfdata,forceDATA ftp://ftp.iiasa.ac.at << EOF
cd WFDEI

mirror PSurf_daily_WFDEI  PSurf_daily
mirror Qair_daily_WFDEI Qair_daily
mirror Tair_daily_WFDEI Tair_daily
get WFDEI-elevation.nc.gz -o WFDEI-elevation.nc.gz

bye
EOF

gzip -d PSurf_daily/*.gz
gzip -d Qair_daily/*.gz
gzip -d Tair_daily/*.gz
gzip -d WFDEI-elevation.nc.gz