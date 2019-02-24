Spark Elastic Search Loader
===========================

### Introduction

This application is a proof of concept for indexing data to Elastic Search using Apache Spark. 

It uses the `sample.log` file in the `$PROJECT_HOME/data` directory as the input. It reads the 
input as a data frame and uses `elasticsearch-spark` library to load it to Elastic Search cluster.

### How to Run the App

##### Requirements for Containerized Env
You need `docker` daemon running to be able to run the application in containers.

You can check the `docker` daemon and `docker-compose` by running:

    $ docker --version
    Docker version 18.06.0-ce, build 0ffa825

    $ docker-compose --version
    docker-compose version 1.22.0, build f46880f

You can read this [documentation](https://docs.docker.com/docker-for-mac/install/) for installing Docker for Mac in your local box.


### Nodes Structure

- Spark Cluster
    * Master
    * Worker
    
- Elastic Search Cluster
    * ElasticSearch
    * ElasticSearch2
    * ElasticSearch3
    * Kibana
    * Head (ES Web Frontend)
    

The running containers are:

              Name                        Command               State                              Ports
    --------------------------------------------------------------------------------------------------------------------------------
    elasticsearch              /usr/local/bin/docker-entr ...   Up      0.0.0.0:9200->9200/tcp, 9300/tcp
    elasticsearch2             /usr/local/bin/docker-entr ...   Up      9200/tcp, 9300/tcp
    elasticsearch3             /usr/local/bin/docker-entr ...   Up      9200/tcp, 9300/tcp
    head                       /bin/sh -c grunt server          Up      0.0.0.0:9100->9100/tcp
    kibana                     /usr/local/bin/kibana-docker     Up      0.0.0.0:5601->5601/tcp
    spark-es-loader_master_1   bin/spark-class org.apache ...   Up      0.0.0.0:4040->4040/tcp, 6066/tcp, 7001/tcp, 7002/tcp,
                                                                        7003/tcp, 7004/tcp, 7005/tcp, 7077/tcp,
                                                                        0.0.0.0:8080->8080/tcp
    spark-es-loader_worker_1   bin/spark-class org.apache ...   Up      7012/tcp, 7013/tcp, 7014/tcp, 7015/tcp,
                                                                        0.0.0.0:8081->8081/tcp, 8881/tcp

### Using Docker Environment

You can use `Makefile` to interact with the cluster.

    $ cd $PROJECT_HOME
    $ make help

    Commands:
    start                          Start cluster [ex. make start]
    run                            Run the application in the cluster [ex. make run]
    stop                           Stop all the nodes in the cluster. [ex. make stop]
    list                           List all the nodes in the cluster. [ex. make list]
    logs                           Show logs for a host. [ex. make logs 
    HOSTNAME=master|worker|elasticsearch|elasticsearch2|elasticsearch3]


Then, run a command using `make $command`. For example, to start Spark cluster and initialize it,
just run the command below. If everything goes well, you should see the success message like this:

    $ make start
    docker-compose up -d
    Creating network "spark-es-loader_spark_es_net" with the default driver
    Creating head                     ... done
    Creating spark-es-loader_master_1 ... done
    Creating elasticsearch2           ... done
    Creating elasticsearch3           ... done
    Creating kibana                   ... done
    Creating elasticsearch            ... done
    Creating spark-es-loader_worker_1 ... done
    Cluster is ready
    Check the application status from:
    - Spark Master UI: http://localhost:8080
    - Spark Worker UI: http://localhost:8081
    - Spark App UI: http://localhost:4040 (When app is running)
    Check ES status from:
    - ES UI: http://localhost:9100
    - Kibana UI: http://localhost:5601


#### Accessing the Spark Cluster

You can access cluster UIs using:

    http://localhost:8080 (Master)
    http://localhost:8081 (Worker)
    http://localhost:4040 (You can access this UI when the application is running)

    PS: Please make sure that above ports are not used by other applications.

#### Accessing the ES Cluster

You can access cluster UIs using:

    http://localhost:9100 (Head UI)
    http://localhost:5601 (Kibana UI)

    PS: Please make sure that above ports are not used by other applications.

### Running the Application 

You can run the application using the `make run` command. When you run this command, it first 
builds the application with `maven`, creates the `jar` file and then it is going to submit the 
application to spark master using the `spark-submit` command.

    $ make run
