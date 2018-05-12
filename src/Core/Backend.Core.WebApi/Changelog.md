# v5.0.0 (12.05.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/60)

## Changes

* Updated reference to Backend.Core **[MAJOR]**

# v4.0.0 (19.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/58)

## Changes

* Renamed Module Base classes to don't have `Base` suffix **[MAJOR]**
* Removed IConfiguration from base classes constructors **[MAJOR]**
* Moved modules creation to DI **[MAJOR]**
* Added registration helpers for configuring and Using modules **[MINOR]**
* Renamed OnStartup method of module to Use to be aligned with DI conventions **[MAJOR]**
* Added registration of configuration **[MAJOR]**

# v3.0.9 (18.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/57)

## Changes

* updated packages version to most recent **[PATCH]**

# v3.0.8 (08.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/54)

## Changes

* Added package icon **[PATCH]**


# v3.0.7 (07.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/53)

## Changes

* updated packages version to most recent **[PATCH]**


# v3.0.0 (29.12.2017) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/44)

## Changes

* updated packages version to most recent, breaking changes after migration to MediatR 4 **[MAJOR]**
* added proper handling of `CancellationToken` for async methods in Controllers base classes to be aligned with other async handling conventions **[MAJOR]**

# v2.3.0 (28.12.2017)

## Changes

* added [ExceptionHandlingMiddleware](Exceptions/ExceptionHandlingMiddleware.cs) and [ExceptionToHttpStatusMapper](Exceptions/ExceptionToHttpStatusMapper.cs) for mapping exception to proper HttpStatus **[MAJOR]**

# v2.0.0

## Changes

* Refactored various interfaces, brought final, production ready version of classes **[MAJOR]**

# v1.0.0

## Changes

* Initial set of interfaces and base classes **[MAJOR]**