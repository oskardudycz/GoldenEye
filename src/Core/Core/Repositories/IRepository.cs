using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Core.Objects.General;

namespace GoldenEye.Core.Repositories
{
    public interface IRepository<TEntity>: IReadonlyRepository<TEntity> where TEntity : class, IHaveId
    {
        TEntity Add(TEntity entity);

        Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken);

        IReadOnlyCollection<TEntity> AddAll(params TEntity[] entities);

        Task<IReadOnlyCollection<TEntity>> AddAllAsync(CancellationToken cancellationToken = default,
            params TEntity[] entities);

        TEntity Update(TEntity entity);

        Task<TEntity> UpdateAsync(TEntity entity, CancellationToken cancellationToken = default);

        TEntity Delete(TEntity entity);

        Task<TEntity> DeleteAsync(TEntity entity, CancellationToken cancellationToken = default);

        bool DeleteById(object id);

        Task<bool> DeleteByIdAsync(object id, CancellationToken cancellationToken = default);

        void SaveChanges();

        Task SaveChangesAsync(CancellationToken cancellationToken = default);
    }
}
