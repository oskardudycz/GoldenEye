using System;
using System.Collections.Generic;
using System.Linq;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using GoldenEye.Backend.Core.Entity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System.Threading.Tasks;
using System.Threading;

namespace GoldenEye.Backend.Core.Context
{
    public class EFDataContext<T> : IDataContext, IProvidesAuditInfo where T : DbContext
    {
        private readonly DbContext dbContext;
        private bool wasDisposed;

        public EFDataContext(T dbContext)
        {
            this.dbContext = dbContext ?? throw new ArgumentException(nameof(dbContext));
        }

        public void Dispose()
        {
            if (wasDisposed)
                return;

            wasDisposed = true;
            dbContext.Dispose();
            GC.SuppressFinalize(this);
        }

        public IDbContextTransaction BeginTransaction()
        {
            return dbContext.Database.BeginTransaction();
        }

        public int SaveChanges()
        {
            SaveChangesProcessor.Instance.RunAll(this);
            return dbContext.SaveChanges();
        }

        public Task<int> SaveChangesAsync()
        {
            SaveChangesProcessor.Instance.RunAll(this);
            return dbContext.SaveChangesAsync();
        }

        public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken))
        {
            return dbContext.SaveChangesAsync(cancellationToken);
        }

        public IEnumerable<IEntityEntry> Changes
        {
            get
            {
                return dbContext.ChangeTracker.Entries()
                    .Select(e=> new EntityEntry((EntityEntryState)(int)e.State, (IEntity)e.Entity));
            }
        }

        TEntity IDataContext.Add<TEntity>(TEntity entity)
        {
            var entry = dbContext.Add(entity);

            return entry.Entity;
        }

        async Task<TEntity> IDataContext.AddAsync<TEntity>(TEntity entity)
        {
            var entry = await dbContext.AddAsync(entity);

            return entry.Entity;
        }

        IQueryable<TEntity> IDataContext.AddRange<TEntity>(params TEntity[] entities)
        {
            dbContext.AddRange(entities);

            return entities.AsQueryable();
        }

        TEntity IDataContext.Update<TEntity>(TEntity entity)
        {
            var entry = dbContext.Add(entity);

            return entry.Entity;
        }

        Task<TEntity> IDataContext.UpdateAsync<TEntity>(TEntity entity)
        {
            return Task.Run(() => ((IDataContext)this).Update(entity));
        }

        TEntity IDataContext.Remove<TEntity>(TEntity entity)
        {
            var entry = dbContext.Remove(entity);

            return entry.Entity;
        }

        Task<TEntity> IDataContext.RemoveAsync<TEntity>(TEntity entity)
        {
            return Task.Run(() => ((IDataContext)this).Remove(entity));
        }

        public TEntity GetById<TEntity>(object id) where TEntity : class
        {
            return dbContext.Find<TEntity>(id);
        }

        public Task<TEntity> GetByIdAsync<TEntity>(object id) where TEntity : class
        {
            return dbContext.FindAsync<TEntity>(id);
        }

        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
        {
            return dbContext.Set<TEntity>();
        }
    }
}