using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Objects.General;

namespace GoldenEye.Repositories;

public interface IReadonlyRepository<TEntity> where TEntity : class, IHaveId
{
    Task<TEntity> FindById(object id, CancellationToken cancellationToken = default);

    IQueryable<TEntity> Query();

    Task<IReadOnlyCollection<TEntity>> RawQuery(string query, CancellationToken cancellationToken = default,
        params object[] queryParams);
}