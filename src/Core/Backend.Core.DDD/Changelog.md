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