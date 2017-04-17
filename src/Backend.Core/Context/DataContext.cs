using System;
using System.Linq;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.Context
{
    public abstract class DataContext : IDataContext
    {
        protected DataContext()
        {
        }

        public void Dispose()
        {
            GC.SuppressFinalize(this);
        }

        public int SaveChanges()
        {
            SaveChangesProcessor.Instance.RunAll(this);
            return 0;
        }
        public virtual Task<int> SaveChangesAsync()
        {
            return Task.Run(() => SaveChanges());
        }

        public abstract TEntity Add<TEntity>(TEntity entity) where TEntity : class;

        public abstract Task<TEntity> AddAsync<TEntity>(TEntity entity) where TEntity : class;

        public abstract IQueryable<TEntity> AddRange<TEntity>(params TEntity[] entities) where TEntity : class;

        public abstract TEntity Update<TEntity>(TEntity entity) where TEntity : class;

        public abstract Task<TEntity> UpdateAsync<TEntity>(TEntity entity) where TEntity : class;

        public abstract TEntity Remove<TEntity>(TEntity entity) where TEntity : class;

        public abstract Task<TEntity> RemoveAsync<TEntity>(TEntity entity) where TEntity : class;

        public abstract TEntity GetById<TEntity>(object id) where TEntity : class;

        public abstract Task<TEntity> GetByIdAsync<TEntity>(object id) where TEntity : class;

        public abstract IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class;
    }
}