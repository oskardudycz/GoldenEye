using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Exceptions;
using GoldenEye.Objects.General;

namespace GoldenEye.Repositories;

public class InMemoryReadonlyRepository<TEntity>: IReadonlyRepository<TEntity> where TEntity : class, IHaveId
{
    protected readonly IList<TEntity> Context = new List<TEntity>();

    public virtual Task<TEntity> FindById(object id, CancellationToken cancellationToken = default)
    {
        return Task.FromResult(Context.SingleOrDefault(r => r.Id == id));
    }

    public virtual IQueryable<TEntity> Query()
    {
        return Context.AsQueryable();
    }

    public Task<IReadOnlyCollection<TEntity>> RawQuery(string query,
        CancellationToken cancellationToken = default, params object[] queryParams)
    {
        throw new NotImplementedException(
            $"Custom query is not supported for {typeof(InMemoryReadonlyRepository<>).Name}");
    }
}