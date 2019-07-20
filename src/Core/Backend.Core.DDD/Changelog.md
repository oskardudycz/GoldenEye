# v9.0.0 (20.07.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/71)

## Changes

* Added extension methods for registering command handlers (`AddAllCommandHandlers`), query handlers (`AddAllQueryHandlers`), event handlers (`AddAllEventHandlers`) and all handlers (`AddAllDDDHandlers`) by convention. See more [in Registration extensions](Registration/Registration.cs)
* Updated `Shared.Core` to `7.1.0` **[MINOR]**
* Updated `Backend.Core` to `7.1.0` **[MINOR]**
* Updated `Microsoft.Extensions.DependencyInjection` to `2.2.0` **[MINOR]**
* Updated `MediatR` to `8.0.0` **[MAJOR]**

# v8.0.0 (26.01.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/69)

## Changes

* Updated reference to `Shared.Core` **[MAJOR]**
* Updated reference to `Backend.Core` **[MAJOR]**
* Updated `Microsoft.Extensions.DependencyInjection` to `2.2.0` **[MINOR]**
* Updated `MediatR` to `6.0.0` **[MINOR]**

# v7.1.0 (23.06.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/65)

## Changes

* Updated reference to `Shared.Core` **[MINOR]**
* Updated reference to `Backend.Core` **[MINOR]**
* Updated `Microsoft.Extensions.DependencyInjection` to `2.1.0` **[MINOR]**

# v7.0.0 (19.06.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/64)

## Changes

* Updated reference to Shared.Core **[MAJOR]**
* Updated version of `MediatR` to `5.0.1`, changed commands, queries, events handler to support new `MediatR` usage with Unit **[MAJOR]**

# v6.1.0 (21.05.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/59)

## Changes

* Added CustomQuery support for EventStore **[MINOR]**

# v6.0.1 (12.05.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/61)

## Changes

* Updated reference to Backend.Core **[PATCH]**

# v6.0.0 (12.05.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/60)

## Changes

* Updated reference to Backend.Core **[MAJOR]**

# v5.0.0 (19.04.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/58)

## Changes

* Updated reference to Shared.Core **[MAJOR]**


# v4.0.0 (18.04.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/56)

## Changes

* Added Async sufix for Publish, Send methods of CommandBus, QueryBus, EventBus abd proper cancellation token handling **[MAJOR]**


# v3.0.8 (08.04.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/54)

## Changes

* Added package icon **[PATCH]**


# v3.0.7 (07.04.2019) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/53)

## Changes

* updated packages version to most recent **[PATCH]**C:\Repos\GoldenEye\src\Core\Backend.Core.DDD\Changelog.md


# v3.0.0 (29.12.2017) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/44)

## Changes

* updated packages version to most recent, breaking changes after migration to MediatR 4 **[MAJOR]**
* to be aligned with the MediatR convention removed synchronous handlers, renamed async handlers to "regular" without async in name (eg. `IAsyncCommandHandler` to `ICommandHandler`) **[MAJOR]**
* added proper handling of `CancellationToken` for async methods in Command, Query and Event Handlers, EventStore and Pipelines to be aligned with other async handling conventions **[MAJOR]**

# v2.2.0 (18.12.2017)

## Changes

* added [ValidationPipeline](Validation/ValidationPipeline.cs) to allow automatic command and queries validation **[MAJOR]**
* added [IView interface](Queries/IView.cs) - it's used to define Projection View classes, eg. [Marten projections](http://jasperfx.github.io/marten/documentation/events/projections/) needs to have Id with public get and set. Using this interface will make easier to not forget about the details **[MINOR]**

# v2.1.0 (20.11.2017)

## Changes

* added [IListQuery](Queries/IListQuery.cs) to simplify quering syntax, now instead `class GetUsers: IQuery<IReadonlyList<User>>` you can use `class GetUsers: IListQuery<User>` **[MAJOR]**

# v2.0.0

## Changes

* Refactored various interfaces, brought final, production ready version of classes **[MAJOR]**

# v1.0.0

## Changes

* Initial set of interfaces and base classes **[MAJOR]**
