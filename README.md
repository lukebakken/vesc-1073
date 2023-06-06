# vesc-1073

https://pivotal-esc.atlassian.net/browse/VESC-1073

# Reproduction steps

## Setup

```
mvn exec:java '-Dexec.mainClass=com.rabbitmq.perf.PerfTest' '-Dexec.args=--uris amqp://dsch:5672,amqp://dsch:5673,amqp://dsch:5674 --producers 2000 --consumers 0 --quorum-queue --queue-pattern delete-me-1073-%d --queue-pattern-from 1 --queue-pattern-to 2000 --pmessages 1'
```

```
mvn exec:java '-Dexec.mainClass=com.rabbitmq.perf.PerfTest' '-Dexec.args=--uris amqp://dsch:5672,amqp://dsch:5673,amqp://dsch:5674 --producers 5000 --consumers 5000 --quorum-queue --queue-pattern vesc-1073-%d --queue-pattern-from 1 --queue-pattern-to 5000 --publishing-interval 10'
```
