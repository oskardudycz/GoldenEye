# GoldenEye.Shared.Core
[![Stories in Ready](https://badge.waffle.io/oskardudycz/GoldenEye.png?label=ready&title=Ready)](https://waffle.io/oskardudycz/GoldenEye)
[![Build status](https://ci.appveyor.com/api/projects/status/1mtm4h33cvur6kob?svg=true)](https://ci.appveyor.com/project/oskardudycz/goldeneye-core)
[![NuGet version](https://badge.fury.io/nu/GoldenEye.Shared.Core.svg)](https://badge.fury.io/nu/GoldenEye.Shared.Core)

What is GoldenEye.Shared.Core?
--------------------------------
GoldenEye.Shared.Core is a library that brings you abstractions and implementations for common topics. It is written in .NET Core. It provides set of base and bootstrap classes that helps you to reduce boilerplate code and help you focus on writing business code.

What do I get?
--------------------------------

### Huge amount of extensions to make your life easier:
* General:
  * [Comparison](Extensions/Basic/CompareExtensions.cs)
  * [Date Ranges](Extensions/Basic/DateRangeExtensions.cs)
  * [DateTime](Extensions/Basic/DateTimeExtensions.cs)
  * [Object](Extensions/Basic/ObjectExtensions.cs)
  * [StringBuilder](Extensions/Basic/StringBuilderExtensions.cs)
  * [String](Extensions/Basic/StringExtensions.cs)
* Collections:
  * [Collection](Extensions/Collections/CollectionExtensions.cs)
  * [Dictionary](Extensions/Collections/DictionaryExtensions.cs)
  * [Enumerable](Extensions/Collections/EnumerableExtensions.cs)
  * [List](Extensions/Collections/ListExtensions.cs)
  * [Queryable](Extensions/Collections/QueryableExtensions.cs)
* [Dependency Injection Registration](Extensions/DependencyInjection/RegistrationExtensions.cs)
* [Dynamic](Extensions/Dynamic/DynamicExtensions.cs)
* [Enums](Extensions/Enums/EnumExtensions.cs)
* [Exceptions](Extensions/Exceptions/ExceptionExtensions.cs)
* Lambda
  * [Expression](Extensions/Lambda/ExpressionExtensions.cs)
  * [ParameterRebinder](Extensions/Lambda/ParameterRebinder.cs)
* [Auto Mapper mappings](Extensions/Mapping/AutoMapperExtensions.cs)
* [Convention names](Extensions/Naming/ConventionNamesExtensions.cs)
* Reflection
  * [Attribute](Extensions/Reflection/AttributeExtensions.cs)
  * [Reflection](Extensions/Reflection/ReflectionExtensions.cs)
* [Serialization](Extensions/Serialization/SerializationExtensions.cs)
* [Streams](Extensions/Streams/StreamExtensions.cs)

### Lot of util classes 
* [Assemblies Provider](Utils/Assemblies/AssembliesProvider.cs)
* [Fluent Switch statement](Utils/Coding/Switch.cs)
* [Collection to CSV Converter](Utils/Collections/CollectionToCSVConverter.cs)
* [String Encryption](Utils/Cryptography/Encryption.cs)
* [Exceptions formatter](Utils/Exceptions/ExceptionProvider.cs)
* [Exceptions formatter](Utils/Exceptions/ExceptionProvider.cs)
* [Guards for defensive programming](Utils/Exceptions/Guard.cs)
* [PropertyName](Utils/Lambda/PropertyName.cs)
* [Localization Utils](Utils/Localization/LocalizationUtils.cs)
* [Localized DisplayName Attribute](Utils/Localization/DisplayNameLocalizedAttribute.cs)
* [Localized DisplayName Attribute](Utils/Localization/DisplayNameLocalizedAttribute.cs)
* [Simple MessageBus](Utils/MessageBus/MessageBus.cs)
* [NoSynchronizationContextScope](Utils/Threading/NoSynchronizationContextScope.cs)

### Base classes and interfaces


How do I get started?
--------------------------------
Create new project and add [nuget package](https://www.nuget.org/packages/GoldenEye.Shared.Core):

`dotnet add package GoldenEye.Shared.Core`

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

For detailed list of changes see [Changelog](Changelog.md)  

GoldenEye is Copyright &copy; 2015-2018 [Oskar Dudycz](http://oskar-dudycz.pl) and other contributors under the [MIT license](../../../LICENSE.txt).
