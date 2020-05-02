using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.Repositories
{
    public interface IReadonlyRepository<TEntity> where TEntity : class, IHaveId
    {
        TEntity FindById(object id);

        Task<TEntity> FindByIdAsync(object id, CancellationToken cancellationToken = default);

        TEntity GetById(object id);

        Task<TEntity> GetByIdAsync(object id, CancellationToken cancellationToken = default);

        IQueryable<TEntity> Query();

        IQueryable<TEntity> Query(string query);
    }
}
