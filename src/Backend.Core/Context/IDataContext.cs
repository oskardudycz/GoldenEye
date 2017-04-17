using System;
using System.Linq;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.Context
{
    public interface IDataContext : IDisposable
    {
        TEntity Add<TEntity>(TEntity entity) where TEntity : class;
        Task<TEntity> AddAsync<TEntity>(TEntity entity) where TEntity : class;

        IQueryable<TEntity> AddRange<TEntity>(params TEntity[] entities) where TEntity : class;

        TEntity Update<TEntity>(TEntity entity) where TEntity : class;
        Task<TEntity> UpdateAsync<TEntity>(TEntity entity) where TEntity : class;

        TEntity Remove<TEntity>(TEntity entity) where TEntity : class;
        Task<TEntity> RemoveAsync<TEntity>(TEntity entity) where TEntity : class;

        TEntity GetById<TEntity>(object id) where TEntity : class;
        Task<TEntity> GetByIdAsync<TEntity>(object id) where TEntity : class;
        IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class;

        int SaveChanges();
        Task<int> SaveChangesAsync();
    }
}
