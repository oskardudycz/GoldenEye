# GoldenEye
[![Stories in Ready](https://badge.waffle.io/oskardudycz/GoldenEye.png?label=ready&title=Ready)](https://waffle.io/oskardudycz/GoldenEye)
[![Build status](https://ci.appveyor.com/api/projects/status/1mtm4h33cvur6kob?svg=true)](https://ci.appveyor.com/project/oskardudycz/goldeneye-core)
[![NuGet version](https://badge.fury.io/nu/GoldenEye.svg)](https://badge.fury.io/nu/GoldenEye)

What is GoldenEye?
--------------------------------
GoldenEye is a library that brings you abstractions and implementations for common topics. It is written in .NET Core. It provides set of base and bootstrap classes that helps you to reduce boilerplate code and help you focus on writing business code.

What do I get?
--------------------------------

Complete DDD and CQRS helpers and bootstrap for:
- [Command definition and handling](Commands/Readme.md)
- [Queries definition and handling](Queries)
- [Events definition, publishing and handling](Events)
- [Aggregates definition](Aggregates)
- [Registration helpers to reduce boilerplate](Registration/Registration.cs)
- [Validation helpers for commands and queries](Validation/Readme.md)
- [CRUD Repositories](Repositories)
- [CRUD Services](Services)
- [Entities definition](Entities)

### Extension methods to make your life easier:
- General:
  - [Comparison](Extensions/Basic/CompareExtensions.cs)
  - [Date Ranges](Extensions/Basic/DateRangeExtensions.cs)
  - [DateTime](Extensions/Basic/DateTimeExtensions.cs)
  - [Object](Extensions/Basic/ObjectExtensions.cs)
  - [StringBuilder](Extensions/Basic/StringBuilderExtensions.cs)
  - [String](Extensions/Basic/StringExtensions.cs)
- Collections:
  - [Collection](Extensions/Collections/CollectionExtensions.cs)
  - [Dictionary](Extensions/Collections/DictionaryExtensions.cs)
  - [Enumerable](Extensions/Collections/EnumerableExtensions.cs)
  - [List](Extensions/Collections/ListExtensions.cs)
  - [Queryable](Extensions/Collections/QueryableExtensions.cs)
- [Dependency Injection Registration](Extensions/DependencyInjection/RegistrationExtensions.cs)
- [Dynamic](Extensions/Dynamic/DynamicExtensions.cs)
- [Enums](Extensions/Enums/EnumExtensions.cs)
- [Exceptions](Extensions/Exceptions/ExceptionExtensions.cs)
- Lambda
  - [Expression](Extensions/Lambda/ExpressionExtensions.cs)
  - [ParameterRebinder](Extensions/Lambda/ParameterRebinder.cs)
- [Auto Mapper mappings](Extensions/Mapping/AutoMapperExtensions.cs)
- [Convention names](Extensions/Naming/ConventionNamesExtensions.cs)
- Reflection
  - [Attribute](Extensions/Reflection/AttributeExtensions.cs)
  - [Reflection](Extensions/Reflection/ReflectionExtensions.cs)
- [Serialization](Extensions/Serialization/SerializationExtensions.cs)
- [Streams](Extensions/Streams/StreamExtensions.cs)

### Lot of util classes 
- [Assemblies Provider](Utils/Assemblies/AssembliesProvider.cs)
- [Fluent Switch statement](Utils/Coding/Switch.cs)
- [Collection to CSV Converter](Utils/Collections/CollectionToCSVConverter.cs)
- [String Encryption](Utils/Cryptography/Encryption.cs)
- [Exceptions formatter](Utils/Exceptions/ExceptionProvider.cs)
- [Exceptions formatter](Utils/Exceptions/ExceptionProvider.cs)
- [Guards for defensive programming](Utils/Exceptions/Guard.cs)
- [PropertyName](Utils/Lambda/PropertyName.cs)
- [Localization Utils](Utils/Localization/LocalizationUtils.cs)
- [Localized DisplayName Attribute](Utils/Localization/DisplayNameLocalizedAttribute.cs)
- [Localized DisplayName Attribute](Utils/Localization/DisplayNameLocalizedAttribute.cs)
- [Simple MessageBus](Utils/MessageBus/MessageBus.cs)
- [NoSynchronizationContextScope](Utils/Threading/NoSynchronizationContextScope.cs)

### Built-in Modules handling

To make easier dependency resolution inside library package `GoldenEye` provides prossibility to define modules.
Thanks for that you don't need to remember to register everything in runtime assembly. You can just `AddModule` and rest will be done automatically.

To define module you need to implement `IModule` interface.

```csharp
public class CustomModule: IModule
{
    public virtual void Configure(IServiceCollection services)
    {
        services.AddScoped<SomeDbContext>();
    }

    public virtual void Use()
    {
        service.UseSomething();
    } 
}
```

or derive from `Module` class and override only what you need:

```csharp
public class CustomModule: Module
{
    public override void Configure(IServiceCollection services)
    {
        services.AddScoped<SomeDbContext>();
    }
}
```

Then in your startup class call `AddModule` and `UseModules` extension methods:

```csharp
    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddModule<CustomModule>();
        }

        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            app.UseModules(env);
        }
    }
```

You can also add all of your defined modules by calling `AddAllModules` extension method:

```csharp
    public class Startup
    {
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddAllModules();
        }

        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            app.UseModules(env);
        }
    }
```

 

How do I get started?
--------------------------------
Create new project and add [nuget package](https://www.nuget.org/packages/GoldenEye):

`dotnet add package GoldenEye`

You can either go and check [Sample project](../../Sample/DDD/Backend.DDD.Sample/Readme.md),
**Install the [project template](https://github.com/oskardudycz/GoldenEye/tree/main/src/Templates/SimpleDDD/content) by running**

`dotnet new -i GoldenEye.WebApi.Template.SimpleDDD`

**and then create new project based on it:**

`dotnet new SimpleDDD -n NameOfYourProject`

Or manually add packages to your project, eg:
create new project and add [nuget package](https://www.nuget.org/packages/GoldenEye):

`dotnet add package GoldenEye`

You can also check my **[Github Tutorial](https://github.com/oskardudycz/EventSourcing.NetCore)** about CQRS and Event Sourcing.

I found an issue or I have a change request
--------------------------------
Feel free to create an issue on GitHub. Contributions, pull requests are more than welcome!

For detailed list of changes see [Changelog](Changelog.md)  

GoldenEye is Copyright &copy; 2015-2020 [Oskar Dudycz](http://oskar-dudycz.pl) and other contributors under the [MIT license](../../../LICENSE.txt).
