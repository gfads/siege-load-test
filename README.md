Siege script for load testing the Sock Shop microservices app giving us more
control over tested endpoints (as we commonly focus on the orders endpoint).

### Dependencies

- Siege: https://www.joedog.org/siege-home/ (experimented against v4.0.4)

### Usage

    $ ./siege.sh

### Configuration

#### Available options

- CONCURRENT: siege's concurrent option
- REPS: siege's reps option
- SERVER: server to siege
- OPTS: any aditional siege's option

#### Examples

Custom number for concurrency and replication

    $ CONCURRENT=10 REPS=15 ./siege.sh

Make siege quiet

    $ OPTS=-q ./siege.sh

Siege localhost port 8080

    $ SERVER=localhost:8080 ./siege.sh

### Related repositories

- https://github.com/microservices-demo/microservices-demo
- https://github.com/microservices-demo/load-test
