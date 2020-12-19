using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Objects.General;

namespace GoldenEye.Repositories
{
    public interface IRepository<TEntity> where TEntity : class, IHaveId
    {
        TEntity FindById(object id);

        Task<TEntity> FindByIdAsync(object id, CancellationToken cancellationToken = default);

        TEntity GetById(object id);

        Task<TEntity> GetByIdAsync(object id, CancellationToken cancellationToken = default);
        
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
