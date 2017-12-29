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

        IQueryable<TEntity> AddAll(IEnumerable<TEntity> entities, bool shouldSaveChanges = true);

        TEntity Update(TEntity entity, bool shouldSaveChanges = true);

        Task<TEntity> UpdateAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken));

        int SaveChanges();

        Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken));

        TEntity Delete(TEntity entity, bool shouldSaveChanges = true);

        Task<TEntity> DeleteAsync(TEntity entity, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken));

        bool Delete(int id, bool shouldSaveChanges = true);

        Task<bool> DeleteAsync(int id, bool shouldSaveChanges = true, CancellationToken cancellationToken = default(CancellationToken));
    }
}