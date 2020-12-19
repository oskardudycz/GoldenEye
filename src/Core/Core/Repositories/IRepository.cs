using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Objects.General;

namespace GoldenEye.Repositories
{
    public interface IRepository<TEntity> where TEntity : class, IHaveId
    {
        Task<TEntity> FindById(object id, CancellationToken cancellationToken = default);

        Task<TEntity> GetById(object id, CancellationToken cancellationToken = default);

        Task<TEntity> Add(TEntity entity, CancellationToken cancellationToken = default);

        Task<TEntity> Update(TEntity entity, CancellationToken cancellationToken = default);

        Task<TEntity> Delete(TEntity entity, CancellationToken cancellationToken = default);

        Task<bool> DeleteById(object id, CancellationToken cancellationToken = default);

        Task SaveChanges(CancellationToken cancellationToken = default);
    }
}
