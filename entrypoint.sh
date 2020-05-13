#!/bin/bash

echo "[ INFO ] Subsituting all the environment variables"

# Setting database name
PROPERTIES_FILE="/app/apache-druid-0.17.0/conf/druid/single-server/micro-quickstart/_common/common.runtime.properties"
DATABASE="${MYSQL_DATABASE:-druid}"
MYSQL_CONNECTION_PORT="${MYSQL_PORT:-3306}"
MYSQL_CONNECTION_STRING=""
ZOOKEEPER_CONNECTION_HOST="${ZOOKEEPER_HOST:-localhost}"
DRUID_HOST="${DRUID_HOSTNAME:-localhost}"

if [ -z "$MYSQL_HOST" ]
then
  echo "[ ERROR ] Mysql url is not provided, exiting process"
  exit 1
fi

if [ -n "$MYSQL_HOST" ]
then
  # Mysql username and password is required to connect to db
  if [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ]
  then
    echo "[ ERROR ] MYSQL_USER or MYSQL_PASSWORD not provided, exiting process"
    sleep 3
    exit 1
  fi
  MYSQL_CONNECTION_STRING="jdbc:mysql://$MYSQL_HOST:$MYSQL_CONNECTION_PORT/$DATABASE"
  echo "[ INFO ] Mysql connection string : $MYSQL_CONNECTION_STRING"
fi

cat << EOF >> $PROPERTIES_FILE
  #
  # Hostname
  #
  druid.host=$DRUID_HOST

  # Zookeeper connection
  druid.zk.service.host=$ZOOKEEPER_CONNECTION_HOST
  druid.zk.paths.base=/druid

  # For MySQL (make sure to include the MySQL JDBC driver on the classpath):
  druid.metadata.storage.type=mysql
  druid.metadata.storage.connector.connectURI=$MYSQL_CONNECTION_STRING
  druid.metadata.storage.connector.user=$MYSQL_USER
  druid.metadata.storage.connector.password=$MYSQL_PASSWORD
EOF

if [ -z "$SERVICE_NAME" ]
then
  echo "[ ERROR ] Service name not provided"
  exit 1
fi

/app/apache-druid-0.17.0/bin/supervise -c /app/apache-druid-0.17.0/conf/supervise/single-server/"${SERVICE_NAME}".conf
