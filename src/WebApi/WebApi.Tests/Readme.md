# GoldenEye.WebApi
[![Stories in Ready](https://badge.waffle.io/oskardudycz/GoldenEye.png?label=ready&title=Ready)](https://waffle.io/oskardudycz/GoldenEye)
[![Build status](https://ci.appveyor.com/api/projects/status/1mtm4h33cvur6kob?svg=true)](https://ci.appveyor.com/project/oskardudycz/goldeneye-core)
[![NuGet version](https://badge.fury.io/nu/GoldenEye.svg)](https://badge.fury.io/nu/GoldenEye.WebApi)

What is GoldenEye.WebApi?
--------------------------------
GoldenEye.WebApi is a library that brings you abstractions and implementations for common WebApi topics. It is written in .NET Core. It provides set of base and bootstrap classes that helps you to reduce boilerplate code and help you focus on writing business code.

Tests structure
--------------------------------
Tests reflects the structure of the project. Eg. tests for [Backend.Core.WebApi/Exceptions/ExceptionHandlingMiddleware.cs](../Backend.Core.WebApi/Exceptions/ExceptionHandlingMiddleware.cs) can be found in [Exceptions/ExceptionHandlingMiddleware.cs](Exceptions/ExceptionHandlingMiddlewareTests.cs)

Tests are written with [XUnit](https://xunit.github.io/) and [Fluent Assertions](http://fluentassertions.com/).

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

For detailed list of changes see [Changelog](Changelog.md)  

GoldenEye is Copyright &copy; 2015-2019 [Oskar Dudycz](http://oskar-dudycz.pl) and other contributors under the [MIT license](LICENSE.txt).
