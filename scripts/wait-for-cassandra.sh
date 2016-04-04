#!/bin/bash
echo "describe cluster;" > /tmp/dc
for i in 1 2 3 4 5; do
  echo Attempt $i
  if nodetool status | grep "^UN"; then
    exit 0
  else
    sleep 10
  fi
done

echo ""
echo "Cassandra failed to start!!"
echo ""
echo "------ Cassandra info -------"
bash -x -c "ps ax | grep -i cassandra"
bash -x -c "sudo lsof -i4TCP:9042"
echo ""
exit 1
