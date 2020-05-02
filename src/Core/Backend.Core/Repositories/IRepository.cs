using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.Repositories
{
    public interface IRepository<TEntity>: IReadonlyRepository<TEntity> where TEntity : class, IHaveId
    {
        TEntity Add(TEntity entity, bool shouldSaveChanges = true);

        Task<TEntity> AddAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default);

        Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken);

        IQueryable<TEntity> AddAll(IEnumerable<TEntity> entities, bool shouldSaveChanges = true);

        TEntity Update(TEntity entity, bool shouldSaveChanges = true);

        Task<TEntity> UpdateAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default);

        Task<TEntity> UpdateAsync(TEntity entity, CancellationToken cancellationToken);

        TEntity Delete(TEntity entity, bool shouldSaveChanges = true);

        Task<TEntity> DeleteAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default);

        Task<TEntity> DeleteAsync(TEntity entity, CancellationToken cancellationToken);

        bool DeleteById(object id, bool shouldSaveChanges = true);

        Task<bool> DeleteByIdAsync(object id, bool shouldSaveChanges = true, CancellationToken cancellationToken = default);

        Task<bool> DeleteByIdAsync(object id, CancellationToken cancellationToken);

        int SaveChanges();

        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken));
    }
}
