# v5.0.0 (19.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/58)

## Changes

Updated samples to show:
* Renamed Module Base classes to don't have `Base` suffix **[MAJOR]**
* Removed IConfiguration from base classes constructors **[MAJOR]**
* Moved modules creation to DI **[MAJOR]**
* Added registration helpers for configuring and Using modules **[MINOR]**
* Renamed OnStartup method of module to Use to be aligned with DI conventions **[MAJOR]**
* Added registration of configuration **[MAJOR]**

# v4.0.0 (18.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/56)

## Changes

* Added Async sufix for Publish, Send methods of CommandBus, QueryBus, EventBus abd proper cancellation token handling **[MAJOR]**

# v3.0.7 (07.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/53)

## Changes

* Fixed failing `GetIssues` sample **[PATCH]**


# v3.0.0 (29.12.2017) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/44)

## Changes

* updated packages version to most recent, breaking changes after migration to MediatR 4 **[MAJOR]**
* added proper handling of `CancellationToken` for async methods in command and query handlers to be aligned with other async handling conventions **[MAJOR]**

# v2.2.0 (18.12.2017)

## Changes

* added samples **[MAJOR]**
