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