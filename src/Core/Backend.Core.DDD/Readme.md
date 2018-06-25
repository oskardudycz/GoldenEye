# GoldenEye.DDD
[![Stories in Ready](https://badge.waffle.io/oskardudycz/GoldenEye.png?label=ready&title=Ready)](https://waffle.io/oskardudycz/GoldenEye)
[![Build status](https://ci.appveyor.com/api/projects/status/1mtm4h33cvur6kob?svg=true)](https://ci.appveyor.com/project/oskardudycz/goldeneye-core)
[![NuGet version](https://badge.fury.io/nu/GoldenEye.Backend.Core.DDD.svg)](https://badge.fury.io/nu/GoldenEye.Backend.Core.DDD)

What is GoldenEye.DDD?
--------------------------------
GoldenEye.DDD is a library that helps to write code in Domain Driven Design and CQRS. It is written in .NET Core. It provides set of base and bootstrap classes that helps you to reduce boilerplate code and help you focus on writing business code.

What do I get?
--------------------------------
Complete DDD and CQRS helpers and bootstrap for:
- [Command definition and handling](Commands)
- [Queries definition and handling](Queries)
- [Events definition, publishing and handling](Events)
- [Aggregates definition](Aggregates)
- [Registration helpers to reduce boilerplate](Registration/Registration.cs)
- [Validation helpers for commands and queries](Validation)
- many more

How do I get started?
--------------------------------
You can either go and check [Sample project](../../Sample/DDD/Backend.DDD.Sample/Readme.md),
**Install the [project template](https://github.com/oskardudycz/GoldenEye/tree/master/src/Templates/SimpleDDD/content) by running**

`dotnet new -i GoldenEye.WebApi.Template.SimpleDDD`

**and then create new project based on it:**

`dotnet new SimpleDDD -n NameOfYourProject`

Or manually add packages to your project, eg:
create new project and add [nuget package](https://www.nuget.org/packages/GoldenEye.Backend.Core.DDD):

`dotnet add package GoldenEye.Backend.Core.DDD`

You can also check my ***[Github Tutorial](https://github.com/oskardudycz/EventSourcing.NetCore)*** about CQRS and Event Sourcing.

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

For detailed list of changes see [Changelog](Changelog.md)  

GoldenEye is Copyright &copy; 2015-2018 [Oskar Dudycz](http://oskar-dudycz.pl) and other contributors under the [MIT license](LICENSE.txt).
