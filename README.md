![GoldenEye Logo](assets/GoldenEye.png)

# GoldenEye

![Twitter Follow](https://img.shields.io/twitter/follow/oskar_at_net?style=social) [![Join the chat at https://gitter.im/oskardudycz/GoldenEye](https://badges.gitter.im/oskardudycz/GoldenEye.svg)](https://gitter.im/oskardudycz/GoldenEye?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build status](https://ci.appveyor.com/api/projects/status/1mtm4h33cvur6kob/branch/main?svg=true)](https://ci.appveyor.com/project/oskardudycz/goldeneye-core/branch/main)

What is GoldenEye?
--------------------------------
**GoldenEye** is a Full Stack framework written in **.NET Core**. The main goal of **GoldenEye** is to speed up your development process. It gathers most widely used frameworks in .NET world and pack them into a simple bootstrap [Nuget packages](https://www.nuget.org/packages?q=GoldenEye). It also provide set of base classes, helpers, extensions that will help you with your daily work.

What do I get?
--------------------------------
Complete Solution bootstrap - bottom up:
- CQRS and Domain Driven Development stack - sending and handling commands, queries, events (with usage of [MediatR](https://github.com/jbogard/MediatR) library)
- [CRUD Repositories](https://github.com/oskardudycz/GoldenEye/tree/main/src/Core/Core/Repositories) and CRUD Application Services
- [Entity Framework](https://github.com/aspnet/EntityFrameworkCore) (supports also [Dapper](https://github.com/StackExchange/Dapper), [Marten](https://github.com/JasperFx/marten))
- WebApi REST controllers
- complete set up of dependency injection with automatic naming convention binding
- [AutoMapper](https://github.com/AutoMapper/AutoMapper) preconfigured and automatic mappings registration
- Validation flow with [FluentValidation.NET](https://github.com/JeremySkinner/FluentValidation)
- Examples of complete usage (Task list functionality)
- document database and event store support in Postgres with [Marten](https://github.com/JasperFx/marten) framework
- many more

How do I get started?
--------------------------------

**Install the [project template](https://github.com/oskardudycz/GoldenEye/tree/main/src/Templates/SimpleDDD/content) by running**

`dotnet new -i GoldenEye.WebApi.Template.SimpleDDD`

**and then create new project based on it:**

`dotnet new SimpleDDD -n NameOfYourProject`


Or manually add packages to your project, eg:

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

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

Support
--------------------------------
💖 If this repository helped you - I'd be more than happy if you **join** the group of **my official supporters** at:

👉 [Github Sponsors](https://github.com/sponsors/oskardudycz) 


**GoldenEye** is Copyright &copy; 2015-2020 [Oskar Dudycz](http://oskar-dudycz.pl) and other contributors under the [MIT license](LICENSE.txt).
