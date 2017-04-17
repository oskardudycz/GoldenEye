using System.Collections.Generic;
using System.Linq;
using GoldenEye.Backend.Core.Entity;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.Repositories
{
    public interface IRepository<TEntity> : IReadonlyRepository<TEntity> where TEntity : class, IEntity
    {
        TEntity Add(TEntity entity, bool shouldSaveChanges = true);
        Task<TEntity> AddAsync(TEntity entity, bool shouldSaveChanges = true);
        IQueryable<TEntity> AddAll(IEnumerable<TEntity> entities, bool shouldSaveChanges = true);
        TEntity Update(TEntity entity, bool shouldSaveChanges = true);
        Task<TEntity> UpdateAsync(TEntity entity, bool shouldSaveChanges = true);
        int SaveChanges();
        Task<int> SaveChangesAsync();
        TEntity Delete(TEntity entity, bool shouldSaveChanges = true);
        Task<TEntity> DeleteAsync(TEntity entity, bool shouldSaveChanges = true);
        bool Delete(int id, bool shouldSaveChanges = true);
        Task<bool> DeleteAsync(int id, bool shouldSaveChanges = true);
    }
}