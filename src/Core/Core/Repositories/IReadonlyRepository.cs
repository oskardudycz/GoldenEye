using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Core.Objects.General;

namespace GoldenEye.Core.Repositories
{
    public interface IReadonlyRepository<TEntity> where TEntity : class, IHaveId
    {
        TEntity FindById(object id);

        Task<TEntity> FindByIdAsync(object id, CancellationToken cancellationToken = default);

        TEntity GetById(object id);

        Task<TEntity> GetByIdAsync(object id, CancellationToken cancellationToken = default);

        IQueryable<TEntity> Query();

        IReadOnlyCollection<TEntity> Query(string query, params object[] queryParams);

        Task<IReadOnlyCollection<TEntity>> QueryAsync(string query, CancellationToken cancellationToken = default,
            params object[] queryParams);
    }
}
