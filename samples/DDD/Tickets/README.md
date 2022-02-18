# Cinema Tickets Reservations with Marten

- typical Event Sourcing and CQRS flow,
- DDD using Aggregates,
- stores events to Marten.

## Dependecies

If you don't have postgress installed on-premies you can run it using docker.

```
docker pull postgres
docker run --name postgres -e POSTGRES_PASSWORD=Password12! -d -p 5432:5432 postgres
```
