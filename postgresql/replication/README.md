1 - Deploy docker-compose on primary:

        docker run -d -it\
            --name postgres-1 \
            --net postgres \
            -e POSTGRES_USER=cmennens \
            -e POSTGRES_PASSWORD=secret \
            -e POSTGRES_DB=zoo \
            -e PGDATA="/data" \
            -v ${PWD}/postgres-1/pgdata:/data \
            -v ${PWD}/postgres-1/config:/config \
            -v ${PWD}/postgres-1/archive:/mnt/server/archive \
            -p 5432:5432\
            postgres:latest \
            -c 'config_file=/config/postgresql.conf'

2 - Create replication role:

    2.1 - `docker exec -it postgres-1 /bin/bash`
    2.2 - `createuser -U cmennens -P -c 5 --replication replicationUser`

3 - Deploy an ephemeral postgres container with data dir mounted to postgres-2 volume:

        ```docker run \
            -it   \
            --net postgres \
            -v ${PWD}/postgres-2/pgdata:/data \
            --entrypoint /bin/bash \
            postgres:latest```

4 - While in bash from above step, perform a pg_basebackup of the primary from the ephemeral container:

        `pg_basebackup -h postgres-1 -p 5432 -U replicationUser -D /data/ -Fp -Xs -R`

5 - Deploy docker-compose for secondary instance of postgres:

       ``` docker run -d \
            --name postgres-2 \
            --net postgres \
            -e POSTGRES_USER=cmennens \
            -e POSTGRES_PASSWORD=secret \
            -e POSTGRES_DB=zoo \
            -e PGDATA="/data" \
            -v ${PWD}/postgres-2/pgdata:/data \
            -v ${PWD}/postgres-2/config:/config \
            -v ${PWD}/postgres-2/archive:/mnt/server/archive \
            -p 5433:5432\
            postgres:latest \
            -c 'config_file=/config/postgresql.conf'```

### REPLICATION SHOULD BE WORKING !!! ###

### FAILOVER INSTRUCTIONS ###

1 - Stop postgres-1 container to simulate an outage:

        `docker stop postgres-1`

2 - Connect to the bash shell of the secondary to promote it:

        `runuser -u postgres -- pg_ctl promote`

3 - Repeat steps above to repair streaming replication with postgres-2 as primary.
