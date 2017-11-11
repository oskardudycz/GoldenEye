# GoldenEye
[![Stories in Ready](https://badge.waffle.io/oskardudycz/GoldenEye.png?label=ready&title=Ready)](https://waffle.io/oskardudycz/GoldenEye)
[![Build status](https://ci.appveyor.com/api/projects/status/1mtm4h33cvur6kob?svg=true)](https://ci.appveyor.com/project/oskardudycz/goldeneye-core)
[![NuGet version](https://badge.fury.io/nu/GoldenEye.Shared.Core.svg)](https://badge.fury.io/nu/GoldenEye.Shared.Core)

What is GoldenEye?
--------------------------------
GoldenEye is a Full Stack framework written in .NET Core. The main goal of GoldenEye is to speed up your development process. It gathers most widely used frameworks in .NET world and pack them into a simple bootstrap Nuget packages. It also provide set of base classes, helpers, extensions that will help you with your daily work.

What do I get?
--------------------------------
Complete Solution bootstrap - bottom up:
- Entity Framework
- CRUD Repositories and CRUD Application Services
- WebApi REST controllers with OData being set up
- Authorization with OAuth
- complete set up of dependency injection with automatic naming convention binding (Ninject)
- Automapper preconfigured and class mappings automatic registration
- Validation flow with FluentValidation.NET
- Examples of complete usage (Task list funcionality)
- CQRS and Domain Driven Development stack - sending and handling commands, queries, events
- document postgres and event store support with Marten framework
- many more

How do I get started?
--------------------------------
1. Create new solution with "ASP.NET Core Web Application" project name it eg. "Frontend"
2. Add new Class libraries projects to newly created solution:
  * Backend
  * Shared
3. Add following references
  * Backend and Shared to Frontend project
  * Shared to Backend project
4. Install following Nuget packages to the projects:
  * Shared - GoldenEye.Shared.Core    
  * Backend - GoldenEye.Backend.Core
5. Run the frontend project.

If you're feeling comportable enough with polish language you can read my [blog post](http://oskar-dudycz.pl/2017/01/06/metallica-skonczyla-sie-na-kill-em-all-a-ja-ide-w-open-sourcey/#comment-44) where I annouced GoldenEye and explained the main goals.

Where can I get it?
--------------------------------
Install packages from the Nuget package manager:

Core packages:
* [GoldenEye.Shared.Core](https://www.nuget.org/packages/GoldenEye.Shared.Core/) - base classes, helpers, extensions that will boost your development
* [GoldenEye.Shared.Core.Validation](https://www.nuget.org/packages/GoldenEye.Shared.Core.Validation/) - validastion based on FluentValidation.NET
* [GoldenEye.Backend.Core](https://www.nuget.org/packages/GoldenEye.Backend.Core/) - classes suited for the backend development - Repositories, Services, CRUD, mappings, etc.
* [GoldenEye.Backend.Core.WebApi](https://www.nuget.org/packages/GoldenEye.Backend.Core.WebApi/) - base classes for API development like CRUD controllers, registration helpers, and many more
* [GoldenEye.Backend.Core.EntityFramework](https://www.nuget.org/packages/GoldenEye.Backend.Core.EntityFramework/) - extensions to GoldenEye.Backend.Core for EntityFramework development (EF repositories, etc.)

DDD package:
* [GoldenEye.Backend.Core.DDD](https://www.nuget.org/packages/GoldenEye.Backend.Core.DDD/) - full DDD flow for CQRS, DDD development. Basing on MediatR library gives the Command, Queries, Events handling, routing

Document database and Event Store with Marten package:
* [GoldenEye.Backend.Core.Marten](https://www.nuget.org/packages/GoldenEye.Backend.Core.Marten/) - extension to GoldenEye.Backend.Core and GoldenEye.Backend.DDD that gives possibility to use Postgres as Document Database and Event Store - thanks to Marten library

Security related packages (User management, OAuth etc.)
* [GoldenEye.Shared.Security](https://www.nuget.org/packages/GoldenEye.Shared.Security/) - base classes to make security management easier
* [GoldenEye.Backend.Identity](https://www.nuget.org/packages/GoldenEye.Backend.Identity/) - helpers and extensions for Backend OAuth management with IdentityServer
* [GoldenEye.Frontend.Identity](https://www.nuget.org/packages/GoldenEye.Frontend.Identity/) - helpers and extensions for Frontend OAuth management with IdentityServer

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

GoldenEye is Copyright &copy; 2015-2017 [Oskar Dudycz](http://oskar-dudycz.pl) and other contributors under the [MIT license](LICENSE.txt).
