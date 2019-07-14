# GoldenEye.Backend.Core.Marten
[![Stories in Ready](https://badge.waffle.io/oskardudycz/GoldenEye.png?label=ready&title=Ready)](https://waffle.io/oskardudycz/GoldenEye)
[![Build status](https://ci.appveyor.com/api/projects/status/1mtm4h33cvur6kob?svg=true)](https://ci.appveyor.com/project/oskardudycz/goldeneye-core)
[![NuGet version](https://badge.fury.io/nu/GoldenEye.Backend.Core.Marten.svg)](https://badge.fury.io/nu/GoldenEye.Backend.Core.Marten)

What is GoldenEye.Backend.Core.Marten?
--------------------------------
GoldenEye.Backend.Core is a library that brings you abstractions and implementations for common backend topics. It is written in .NET Core. It provides set of base and bootstrap classes that helps you to reduce boilerplate code and help you focus on writing business code.

What do I get?
--------------------------------
Complete helpers and bootstrap for:
- [Event Store](Events/Storage/MartenEventStore.cs)
- [Data contexts definition and usage](Context)
- [Registration helpers to reduce boilerplate](Registration/Registration.cs)
- many more

How do I get started?
--------------------------------
You can create new project and add [nuget package](https://www.nuget.org/packages/GoldenEye.Backend.Core.Marten):

`dotnet add package GoldenEye.Backend.Core.Marten`

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

For detailed list of changes see [Changelog](Changelog.md)  

GoldenEye is Copyright &copy; 2015-2019 [Oskar Dudycz](http://oskar-dudycz.pl) and other contributors under the [MIT license](LICENSE.txt).
