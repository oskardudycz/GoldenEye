# v4.1.0 (23.06.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/65)

## Changes

* Updated reference to `Shared.Core` **[MINOR]**
* Updated reference to `Backend.Core` **[MINOR]**
* Updated `FluentAssertions` to `5.4.1` **[PATCH]**
* Updated `Microsoft.Extensions.DependencyInjection` to `2.1.0` **[MINOR]**
* Updated `Microsoft.NET.Test.Sdk` to `15.7.2` **[MINOR]**

# v4.0.0 (19.06.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/64)

## Changes

* Updated version of `MediatR` to `5.0.1` **[MAJOR]**
* Added [tests](Registration/EventHandlerRegistrationTests.cs) for [EventHandler registration](../Backend.Core.DDD/Registration/Registration.cs) **[MINOR]**


# v3.0.0 (29.12.2017) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/44)

## Changes

* updated packages version to most recent, breaking changes after migration to MediatR 4 **[MAJOR]**
* updated tests after alignment with the MediatR convention removed synchronous handlers, renamed async handlers to "regular" without async in name (eg. `IAsyncCommandHandler` to `ICommandHandler`) **[MAJOR]**
* updated tests after adding proper handling of `CancellationToken` for async methods in Command, Query and Event Handlers, EventStore and Pipelines to be aligned with other async handling conventions **[MAJOR]**

# v2.2.0 (18.12.2017)

## Changes

* Added [tests](Validation/ValidationPipelineTests.cs) for [EventStorePipeline](../Backend.Core.DDD/Validation/ValidationPipeline.cs) **[MAJOR]**

# v2.0.0

## Changes

* Aded [tests](Events/Store/EventStorePipelineTests.cs) for [EventStorePipeline](../Backend.Core.DDD/Events/Store/EventStorePipeline.cs) **[MAJOR]**

# v1.0.0

## Changes

* Initial structure of project **[MAJOR]**