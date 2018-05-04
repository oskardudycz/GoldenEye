![GoldenEye Logo](assets/GoldenEye.png)

# GoldenEye

[![Join the chat at https://gitter.im/oskardudycz/GoldenEye](https://badges.gitter.im/oskardudycz/GoldenEye.svg)](https://gitter.im/oskardudycz/GoldenEye?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Stories in Ready](https://badge.waffle.io/oskardudycz/GoldenEye.png?label=ready&title=Ready)](https://waffle.io/oskardudycz/GoldenEye)
[![Build status](https://ci.appveyor.com/api/projects/status/1mtm4h33cvur6kob/branch/master?svg=true)](https://ci.appveyor.com/project/oskardudycz/goldeneye-core/branch/master)
[![NuGet version](https://badge.fury.io/nu/GoldenEye.Shared.Core.svg)](https://badge.fury.io/nu/GoldenEye.Shared.Core)

What is GoldenEye?
--------------------------------
GoldenEye is a Full Stack framework written in .NET Core. The main goal of GoldenEye is to speed up your development process. It gathers most widely used frameworks in .NET world and pack them into a simple bootstrap Nuget packages. It also provide set of base classes, helpers, extensions that will help you with your daily work.

What do I get?
--------------------------------
Complete Solution bootstrap - bottom up:
- [Entity Framework](https://github.com/aspnet/EntityFrameworkCore) (supports also [Dapper](https://github.com/StackExchange/Dapper), [Marten](https://github.com/JasperFx/marten))
- CRUD Repositories and CRUD Application Services
- WebApi REST controllers
- Authorization with OAuth ([Identity Server](https://github.com/IdentityServer/IdentityServer4)
- complete set up of dependency injection with automatic naming convention binding
- AutoMapper preconfigured and class mappings automatic registration
- Validation flow with [FluentValidation.NET](https://github.com/JeremySkinner/FluentValidation)
- Examples of complete usage (Task list functionality)
- CQRS and Domain Driven Development stack - sending and handling commands, queries, events
- document database and event store support in Postgres with [Marten](https://github.com/JasperFx/marten) framework
- many more

How do I get started?
--------------------------------
1. Create new solution with "ASP.NET Core Web Application" project name it eg. "API"
2. Add new Class libraries projects to newly created solution:
  * Backend
  * Shared
3. Add following references
  * Backend and Shared to API project
  * Shared to Backend project
4. Install following Nuget packages to the projects:
  * Shared - GoldenEye.Shared.Core    
  * Backend - GoldenEye.Backend.Core
5. Run the frontend project.

If you're feeling comportable enough with polish language you can read my [blog post](http://oskar-dudycz.pl/2017/01/06/metallica-skonczyla-sie-na-kill-em-all-a-ja-ide-w-open-sourcey/#comment-44) where I annouced GoldenEye and explained the main goals.

Where can I get it?
--------------------------------
Install packages from the Nuget package manager:

**Core packages**:
* [GoldenEye.Shared.Core](src/Core/Shared.Core/Readme.md) - base classes, helpers, extensions that will boost your development
* [GoldenEye.Shared.Core.Validation](src/Core/Shared.Core.Validation/Readme.md) - validation based on FluentValidation.NET
* [GoldenEye.Backend.Core](src/Core/Backend.Core/Readme.md) - classes suited for the backend development - Repositories, Services, CRUD, mappings, etc.
* [GoldenEye.Backend.Core.WebApi](src/Core/Backend.Core.WebApi/Readme.md) - base classes for API development like CRUD controllers, registration helpers, and many more
* [GoldenEye.Backend.Core.EntityFramework](src/Core/Backend.Core.EntityFramework/Readme.md) - extensions to GoldenEye.Backend.Core for EntityFramework development (EF repositories, etc.)
* [GoldenEye.Backend.Core.Dapper](src/Core/Backend.Core.Dapper/Readme.md) - extensions to GoldenEye.Backend.Core for Dapper development (Dapper repositories, etc.)

**DDD package**:
* [GoldenEye.Backend.Core.DDD](src/Core/Backend.Core.DDD/Readme.md) - full DDD flow for CQRS, DDD development. Basing on MediatR library gives the Command, Queries, Events handling, routing

**Document database and Event Store with Marten package**:
* [GoldenEye.Backend.Core.Marten](src/Core/Backend.Core.Marten/Readme.md) - extension to GoldenEye.Backend.Core and GoldenEye.Backend.DDD that gives possibility to use Postgres as Document Database and Event Store - thanks to Marten library

**Security related packages (User management, OAuth etc.)**
* [GoldenEye.Shared.Security](src/Security/Shared.Security/Readme.md) - base classes to make security management easier
* [GoldenEye.Backend.Identity](src/Security/Backend.Identity/Readme.md) - helpers and extensions for Backend OAuth management with IdentityServer
* [GoldenEye.Frontend.Identity](src/Security/Frontend.Identity/Readme.md) - helpers and extensions for Frontend OAuth management with IdentityServer

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

**GoldenEye** is Copyright &copy; 2015-2018 [Oskar Dudycz](http://oskar-dudycz.pl) and other contributors under the [MIT license](LICENSE.txt).
