#!/bin/bash
cd "d:/PEILIAODIAN/vs1/playmate_app/backend"
java -jar target/backend-0.0.1-SNAPSHOT.jar --debug > ../debug.log 2>&1 &
echo $! > backend.pid
sleep 10
cat ../debug.log