# v3.0.0 (29.12.2017)

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