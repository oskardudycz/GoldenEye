# v6.1.0 (23.06.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/65)

## Changes

* Updated reference to `Shared.Core` **[MINOR]**
* Updated reference to `Backend.Core` **[MINOR]**
* Updated `IdentityServer4.EntityFramework` to `2.1.0` **[PATCH]**
* Updated `Microsoft.AspNetCore.Identity.EntityFrameworkCore` to `2.1.0` **[PATCH]**

# v6.0.0 (19.06.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/64)

## Changes

* Updated reference to Shared.Core **[MAJOR]**

# v5.2.0 (21.05.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/59)

## Changes

* Added CustomQuery support for Repositories and DataContexts **[MINOR]**

# v5.1.0 (12.05.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/61)

## Changes

* Fixed bug with stackoverflow during `AddAsync` method of `Repository` **[PATCH]**
* Added `Remove` and `RemoveAsync` methods by id to `IDataContext` **[MINOR]**

# v5.0.0 (12.05.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/60)

## Changes

* Fixed wrong type of id in Delete method in `IRepository` and `IRestService` **[MAJOR]**
* Added overloads with cancellation token only of async `IRepository` methods **[MINOR]**

# v4.0.0 (19.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/58)

## Changes

* Updated reference to Shared.Core **[MAJOR]**


# v3.0.8 (08.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/54)

## Changes

* Added package icon **[PATCH]**


# v3.0.7 (07.04.2018) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/53)

## Changes

* updated packages version to most recent **[PATCH]**

# v3.0.0 (29.12.2017) [Pull Request](https://github.com/oskardudycz/GoldenEye/pull/44)

## Changes

* updated packages version to most recent, breaking changes after migration to MediatR 4 **[MAJOR]**
* added proper handling of `CancellationToken` for async methods in Repositories, Services, Contexts to be aligned with other async handling conventions **[MAJOR]**

# v2.3.0 (28.12.2017)

## Changes

* added [AddAllValidators](Registration/Registration.cs) method for registering all validators in the DI container **[MAJOR]**

# v2.0.0

## Changes

* Refactored various interfaces, brought final, production ready version of classes **[MAJOR]**

# v1.0.0

## Changes

* Initial set of interfaces and base classes **[MAJOR]**