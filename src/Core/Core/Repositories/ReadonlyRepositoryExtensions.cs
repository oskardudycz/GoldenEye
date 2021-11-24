using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Exceptions;
using GoldenEye.Objects.General;
using MediatR;

namespace GoldenEye.Repositories;

public static class ReadonlyRepositoryExtensions
{
    public static async Task<TEntity> GetById<TEntity>(
        this IReadonlyRepository<TEntity> repository,
        object id,
        CancellationToken cancellationToken = default
    )
        where TEntity : class, IHaveId
    {
        var entity = await repository.FindById(id, cancellationToken);

        return entity ?? throw NotFoundException.For<TEntity>(id);
    }
}