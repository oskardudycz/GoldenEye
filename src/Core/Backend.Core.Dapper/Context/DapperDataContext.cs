using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.Context;

namespace GoldenEye.Backend.Core.Dapper.Context
{
    internal class DapperDataContext : IDataContext
    {
        public TEntity Add<TEntity>(TEntity entity) where TEntity : class
        {
            throw new NotImplementedException();
        }

        public Task<TEntity> AddAsync<TEntity>(TEntity entity, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            throw new NotImplementedException();
        }

        public IQueryable<TEntity> AddRange<TEntity>(params TEntity[] entities) where TEntity : class
        {
            throw new NotImplementedException();
        }

        public void Dispose()
        {
            throw new NotImplementedException();
        }

        public TEntity GetById<TEntity>(object id) where TEntity : class, new()
        {
            throw new NotImplementedException();
        }

        public Task<TEntity> GetByIdAsync<TEntity>(object id, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class, new()
        {
            throw new NotImplementedException();
        }

        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
        {
            throw new NotImplementedException();
        }

        public TEntity Remove<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            throw new NotImplementedException();
        }

        public bool Remove<TEntity>(object id, int? version = null) where TEntity : class
        {
            throw new NotImplementedException();
        }

        public Task<TEntity> RemoveAsync<TEntity>(TEntity entity, int? version = null, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            throw new NotImplementedException();
        }

        public Task<bool> RemoveAsync<TEntity>(object id, int? version = null, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            throw new NotImplementedException();
        }

        public int SaveChanges()
        {
            throw new NotImplementedException();
        }

        public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken))
        {
            throw new NotImplementedException();
        }

        public TEntity Update<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            throw new NotImplementedException();
        }

        public Task<TEntity> UpdateAsync<TEntity>(TEntity entity, int? version = null, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            throw new NotImplementedException();
        }
    }
}