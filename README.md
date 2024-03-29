![GoldenEye Logo](assets/GoldenEye.png)

# GoldenEye

[![Twitter Follow](https://img.shields.io/twitter/follow/oskar_at_net?style=social)](https://twitter.com/oskar_at_net) [![Join the chat at https://gitter.im/oskardudycz/GoldenEye](https://badges.gitter.im/oskardudycz/GoldenEye.svg)](https://gitter.im/oskardudycz/GoldenEye?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
![Github Actions](https://github.com/oskardudycz/GoldenEye/actions/workflows/build.dotnet.yml/badge.svg?branch=main) [![blog](https://img.shields.io/badge/blog-event--driven.io-brightgreen)](https://event-driven.io/?utm_source=goldeneye)  [![blog](https://img.shields.io/badge/%F0%9F%9A%80-Architecture%20Weekly-important)](https://www.architecture-weekly.com/?utm_source=goldeneye) 

What is GoldenEye?
--------------------------------
**GoldenEye** is a Full Stack framework written in **.NET**. The main goal of **GoldenEye** is to speed up your development process. It gathers most widely used frameworks in .NET world and pack them into a simple bootstrap [Nuget packages](https://www.nuget.org/packages?q=GoldenEye). It also provide set of base classes, helpers, extensions that will help you with your daily work.

What do I get?
--------------------------------
Complete Solution bootstrap - bottom up:
- CQRS and Domain Driven Development stack - sending and handling commands, queries, events (with usage of [MediatR](https://github.com/jbogard/MediatR) library),
- Messaging infrastructure - both internal based on [MediatR](https://github.com/jbogard/MediatR) and external with [Kafka](https://kafka.apache.org/),
- [CRUD Repositories](https://github.com/oskardudycz/GoldenEye/tree/main/src/Core/Core/Repositories) and CRUD Application Services,
- [Entity Framework](https://github.com/aspnet/EntityFrameworkCore) (supports also [Dapper](https://github.com/StackExchange/Dapper), [Marten](https://github.com/JasperFx/marten))
- WebApi REST controllers,
- complete set up of dependency injection with automatic naming convention binding,
- [AutoMapper](https://github.com/AutoMapper/AutoMapper) preconfigured and automatic mappings registration,
- Validation flow with [FluentValidation.NET](https://github.com/JeremySkinner/FluentValidation),
- [Examples of complete usage (Cinema Ticket Reservations)](./samples/DDD/Tickets),
- document database and event store support in Postgres with [Marten](https://github.com/JasperFx/marten) framework,
- many more

How do I get started?
--------------------------------

Add package to your project:

`dotnet add package GoldenEye`
  

Where can I get it?
--------------------------------
Install packages from the Nuget package manager:

**Packages**:
* [GoldenEye](src/Core/Core/Readme.md) - full DDD flow for CQRS, DDD development. Basing on [MediatR](https://github.com/jbogard/MediatR) library gives the Command, Queries, Events handling. Repositories, Services, CRUD, helpers, extensions that will boost your development
* [GoldenEye.Marten](src/Marten/Marten/Readme.md) - extension to GoldenEye that gives possibility to use Postgres as Document Database and Event Store - thanks to Marten library
* [GoldenEye.WebApi](src/WebApi/WebApi/Readme.md) - base classes for API development like CRUD controllers, registration helpers, and many more
* [GoldenEye.EntityFramework](src/EntityFramework/EntityFramework/Readme.md) - extensions to GoldenEye for EntityFramework development (EF repositories, etc.)
* [GoldenEye.Dapper](src/Dapper/Dapper/Readme.md) - extensions to GoldenEye for Dapper development (Dapper repositories, etc.)
* [GoldenEye.ElasticSearch](src/ElasticSearch/ElasticSearch/Readme.md) - extensions to GoldenEye for ElasticSearch development (ElasticSearch repositories, etc.)
* [GoldenEye.Kafka](src/Kafka/Kafka/Readme.md) - extensions to GoldenEye for Kafka development (Kafka producer, concumer, etc.)

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

Support
--------------------------------
💖 If this repository helped you - I'd be more than happy if you **join** the group of **my official supporters** at:

👉 [Github Sponsors](https://github.com/sponsors/oskardudycz) 


**GoldenEye** is Copyright &copy; 2015-2021 [Oskar Dudycz](https://event-driven.io) and other contributors under the [MIT license](LICENSE.txt).
