using System;
using System.Collections.Generic;
using System.Linq;

namespace GoldenEye.Backend.Core.Context
{
    public interface IDataContext : IDisposable
    {
        TEntity Add<TEntity>(TEntity entity) where TEntity : class;
        IEnumerable<TEntity> AddRange<TEntity>(params TEntity[] entities) where TEntity : class;
        TEntity Update<TEntity>(TEntity entity) where TEntity : class;
        TEntity Remove<TEntity>(TEntity entity) where TEntity : class;
        IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class;

        int SaveChanges();
    }
}
