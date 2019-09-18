#!/bin/bash

set -e

LIGHT_PID=$(ps -ef | grep "syncmode light" | grep -v "grep" | awk '{print $1}')
curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'  http://localhost:8645 | grep 'false'
if [ $? = 0 ];then
    sleep 60;
    curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'  http://localhost:8645 | grep 'false'
    if [ $? = 1 ];then
        exit 0;
    fi
    if [ ! -z "$LIGHT_PID" ]; then
        kill $LIGHT_PID
    fi
    cp /etc/nginx/nginx.conf.full /etc/nginx/nginx.conf
    nginx -s reload
    pkill crond
    rm -rf /root/.ethereum/geth-light
elif [ -z "$LIGHT_PID" ]; then        
    cp /etc/nginx/nginx.conf.light /etc/nginx/nginx.conf
    nginx -s reload
    geth --syncmode light --datadir /root/.ethereum/geth-light --port 31313 --nousb --rpc --rpcaddr 0.0.0.0 --rpcport 8745 --rpccorsdomain "*" --rpcvhosts "*" --ws --wsorigins "*" --wsaddr 0.0.0.0 --wsport 8746 &
fi