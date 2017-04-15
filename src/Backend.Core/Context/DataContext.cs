using System;
using System.Linq;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using System.Collections.Generic;

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

        public abstract IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class;

        public abstract TEntity Add<TEntity>(TEntity entity) where TEntity : class;
        public abstract IEnumerable<TEntity> AddRange<TEntity>(params TEntity[] entities) where TEntity : class;

        public abstract TEntity Update<TEntity>(TEntity entity) where TEntity : class;

        public abstract TEntity Remove<TEntity>(TEntity entity) where TEntity : class;
    }
}