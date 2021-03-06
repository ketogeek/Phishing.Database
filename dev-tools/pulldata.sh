#!/bin/bash
# Generator Script for Phishing.Database
# REPO: https://github.com/mitchellkrogza/Phishing.Database
# Copyright Mitchell Krog - mitchellkrog@gmail.com

# *******************************
# Input and Output File Variables
# *******************************

inputA=${TRAVIS_BUILD_DIR}/input-source/ALL-feeds.list
input1=${TRAVIS_BUILD_DIR}/input-source/openphish-feed.list
input2=${TRAVIS_BUILD_DIR}/input-source/illegalfawn-feed.list
input3=${TRAVIS_BUILD_DIR}/input-source/phishtank-feed.list
output=${TRAVIS_BUILD_DIR}/dev-tools/phishing-domains-ALL.list
output2=${TRAVIS_BUILD_DIR}/dev-tools/phishing-domains-IDNA.list

# **************
# Temp Variables
# **************

outputtmp=${TRAVIS_BUILD_DIR}/phishing.tmp
feed1=${TRAVIS_BUILD_DIR}/input-source/openphish.list
feed2=${TRAVIS_BUILD_DIR}/input-source/phishtank.list
tmp=${TRAVIS_BUILD_DIR}/input-source/tmp.list

# **********************************************
# Fetch our feed(s) and append to our input file
# **********************************************

fetch () {
sudo wget https://hosts.ubuntu101.co.za/openphish/openphish-feed.list -O ${feed1}
cat ${feed1} >> ${input1}
sudo rm ${feed1}
sudo wget https://hosts.ubuntu101.co.za/openphish/phishtank-feed.list -O ${feed2}
cat ${feed2} >> ${input3}
sudo rm ${feed2}
}

# *************************************************
# Prepare our input lists and remove any duplicates
# *************************************************

initiate () {

# Prepare Feed 1 / OpenPhish
sort -u ${input1} -o ${input1}
grep '[^[:blank:]]' < ${input1} > ${tmp}
sudo mv ${tmp} ${input1}

# Prepare Feed 2 / IllegalFawn
sort -u ${input2} -o ${input2}
grep '[^[:blank:]]' < ${input2} > ${tmp}
sudo mv ${tmp} ${input2}

# Prepare Feed 3 / Phishtank
sort -u ${input3} -o ${input3}
grep '[^[:blank:]]' < ${input3} > ${tmp}
sudo mv ${tmp} ${input3}

}

# ***************************************
# Prepare our list for PyFunceble Testing
# ***************************************

prepare () {
sudo truncate -s 0 ${output}
sudo cp ${input1} ${output}
cat ${input2} >> ${output}
cat ${input3} >> ${output}
sudo cp ${output} ${inputA}
cut -d'/' -f3 ${output} > ${outputtmp}
sort -u ${outputtmp} -o ${outputtmp}
grep '[^[:blank:]]' < ${outputtmp} > ${output}
sudo rm ${outputtmp}
dos2unix ${output}
sort -u ${inputA} -o ${inputA}
dos2unix ${inputA}
}


# *********************************
# Prepare our list into IDNA format
# *********************************

idna () {
cd ${TRAVIS_BUILD_DIR}/dev-tools/domain2idna/
python setup.py test
pip install -e .
domain2idna -f ${output} -o ${output2}
sort -u ${output2} -o ${output2}
tr '[:upper:]' '[:lower:]' < ${output2} > ${tmp}
sudo mv ${tmp} ${output2}
dos2unix ${output2}
}

fetch
initiate
prepare
idna


# **********************
# Exit With Error Number
# **********************

exit ${?}
