#!/bin/bash
set -x

set +e
sudo rm -fr /data/*
sudo mkdir -p /data
docker system prune -a -f
DIR="$(cd "$(dirname "$0")" && pwd)"

set -e
if [ -z "$1" ]; then echo no ip specified; exit 1;fi
# prepare cert ...
sudo ./tests/generateCerts.sh $1

python --version
pip -V
cat /etc/issue
cat /proc/version
sudo apt-get update -y && sudo apt-get install -y zbar-tools libzbar-dev python-zbar python3.7
sudo rm /usr/bin/python && sudo ln -s /usr/bin/python3.7 /usr/bin/python
sudo apt-get install -y python3-pip
pip -V
sudo -H pip install --ignore-installed urllib3 chardet requests --upgrade
python --version

sudo ./tests/hostcfg.sh

if [ "$2" = 'LDAP' ]; then
    cd tests && sudo ./ldapprepare.sh && cd ..
fi

if [ $GITHUB_TOKEN ];
then
    sed "s/# github_token: xxx/github_token: $GITHUB_TOKEN/" -i make/harbor.yml
fi
sudo make install COMPILETAG=compile_golangimage CLARITYIMAGE=goharbor/harbor-clarity-ui-builder:1.6.0 BUILDBIN=true NOTARYFLAG=true CLAIRFLAG=true TRIVYFLAG=true CHARTFLAG=true GEN_TLS=true

# waiting 5 minutes to start
for((i=1;i<=30;i++)); do
  echo $i waiting 10 seconds...
  sleep 10
  curl -k -L -f 127.0.0.1/api/v2.0/systeminfo && break
  docker ps
done
