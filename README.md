[![Stories in Ready](https://badge.waffle.io/oskardudycz/GoldenEye.png?label=ready&title=Ready)](https://waffle.io/oskardudycz/GoldenEye)
# GoldenEye
[![Build status](https://ci.appveyor.com/api/projects/status/1mtm4h33cvur6kob?svg=true)](https://ci.appveyor.com/project/oskardudycz/goldeneye-core)
[![NuGet version](https://badge.fury.io/nu/GoldenEye.Shared.SPA.svg)](https://badge.fury.io/nu/GoldenEye.Shared.SPA)

What is GoldenEye?
--------------------------------
GoldenEye is a Full Stack framework written in .NET and JavaScript. The main goal of GoldenEye is to speed up your development process. It gathers most widely used frameworks in .NET world and pack them into a simple bootstrap Nuget packages. It also provide set of base classes, helpers, extensions that will help you with your daily work.

What do I get?
--------------------------------
Complete Solution bootstrap - bottom up:
- Entity Framework
- CRUD Repositories and CRUD Application Services
- WebApi REST controllers with OData being set up
- Authorization with OAuth
- Simple SPA Web Frontend Written in Knockout.JS and Sammy.JS
- complete set up of dependency injection with automatic naming convention binding (Ninject)
- Automapper preconfigured and class mappings automatic registration
- Validation flow with FluentValidation.NET and Knockout.Validation
- Examples of complete usage (Task list funcionality)
- logging with NLog
- many more

How do I get started?
--------------------------------
Checkout [sample project](https://github.com/oskardudycz/GoldenEye-Sample) build it and play around. If you prefer to do it from scratch follow the steps:

1. Create new solution with "ASP.NET Empty Web Site" project name it eg. "Frontend"
2. Add new Class libraries projects to newly created solution:
  * Backend
  * Shared
3. Add following references
  * Backend and Shared to Frontend project
  * Shared to Backend project
4. Install following Nuget packages to the projects:
  * Shared - GoldenEye.Shared.SPA    
  * Backend - GoldenEye.Backend.SPA.Business
  * Frontend - GoldenEye.Frontend.SPA.Web
5. Run the frontend project.

If you're feeling comportable enough with polish language you can read my [blog post](http://oskar-dudycz.pl/2017/01/06/metallica-skonczyla-sie-na-kill-em-all-a-ja-ide-w-open-sourcey/#comment-44) where I annouced GoldenEye and explained the main goals.

Where can I get it?
--------------------------------
Install packages from the Nuget package manager:
Main bootstrap packages:
* [GoldenEye.Shared.SPA](https://www.nuget.org/packages/GoldenEye.Shared.SPA/)
* [GoldenEye.Backend.SPA.Business](https://www.nuget.org/packages/GoldenEye.Backend.SPA.Business/)
* [Goldeneye.SPA.Web](https://www.nuget.org/packages/GoldenEye.Frontend.SPA.Web/)

Core packages:
* [GoldenEye.Shared.Core](https://www.nuget.org/packages/GoldenEye.Shared.Core/)
* [GoldenEye.Backend.Core](https://www.nuget.org/packages/GoldenEye.Backend.Core/)
* [GoldenEye.Frontend.Core.Web](https://www.nuget.org/packages/GoldenEye.Frontend.Core.Web/)

Security related packages (User management, OAuth etc.)
* [GoldenEye.Backend.Security](https://www.nuget.org/packages/GoldenEye.Backend.Security/)
* [GoldenEye.Frontend.Security.Web](https://www.nuget.org/packages/GoldenEye.Frontend.Security.Web/)

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

GoldenEye is Copyright &copy; 2015-2017 [Oskar Dudycz](http://oskar-dudycz.pl) and other contributors under the [MIT license](LICENSE.txt).
