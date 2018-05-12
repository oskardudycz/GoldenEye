using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.Repositories
{
    public interface IRepository<TEntity> : IReadonlyRepository<TEntity> where TEntity : class, IHasId
    {
        TEntity Add(TEntity entity, bool shouldSaveChanges = true);

        Task<TEntity> AddAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken));

        Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken);

        IQueryable<TEntity> AddAll(IEnumerable<TEntity> entities, bool shouldSaveChanges = true);

        TEntity Update(TEntity entity, bool shouldSaveChanges = true);

        Task<TEntity> UpdateAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken));

        Task<TEntity> UpdateAsync(TEntity entity, CancellationToken cancellationToken);

        TEntity Delete(TEntity entity, bool shouldSaveChanges = true);

        Task<TEntity> DeleteAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken));

        Task<TEntity> DeleteAsync(TEntity entity, CancellationToken cancellationToken);

        bool Delete(object id, bool shouldSaveChanges = true);

        Task<bool> DeleteAsync(object id, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken));

        Task<bool> DeleteAsync(object id, CancellationToken cancellationToken);

        int SaveChanges();

        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken));
    }
}