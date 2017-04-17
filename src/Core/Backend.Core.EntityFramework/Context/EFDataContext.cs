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
    public abstract class DataContext<T> : DbContext, IDataContext, IProvidesAuditInfo where T : DbContext
    {
        protected DataContext(DbContextOptions<T> options) : base(options)
        {
        }

        public new void Dispose()
        {
            base.Dispose();
            GC.SuppressFinalize(this);
        }

        public IDbContextTransaction BeginTransaction()
        {
            return Database.BeginTransaction();
        }

        public override int SaveChanges()
        {
            SaveChangesProcessor.Instance.RunAll(this);
            return base.SaveChanges();
        }

        public Task<int> SaveChangesAsync()
        {
            SaveChangesProcessor.Instance.RunAll(this);
            return base.SaveChangesAsync();
        }

        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken))
        {
            return SaveChangesAsync();
        }

        public IEnumerable<IEntityEntry> Changes
        {
            get
            {
                return ChangeTracker.Entries()
                    .Select(e=> new EntityEntry((EntityEntryState)(int)e.State, (IEntity)e.Entity));
            }
        }

        TEntity IDataContext.Add<TEntity>(TEntity entity)
        {
            var entry = base.Add(entity);

            return entry.Entity;
        }

        async Task<TEntity> IDataContext.AddAsync<TEntity>(TEntity entity)
        {
            var entry = await base.AddAsync(entity);

            return entry.Entity;
        }

        IQueryable<TEntity> IDataContext.AddRange<TEntity>(params TEntity[] entities)
        {
            base.AddRange(entities);

            return entities.AsQueryable();
        }

        TEntity IDataContext.Update<TEntity>(TEntity entity)
        {
            var entry = base.Add(entity);

            return entry.Entity;
        }

        Task<TEntity> IDataContext.UpdateAsync<TEntity>(TEntity entity)
        {
            return Task.Run(() => ((IDataContext)this).Update(entity));
        }

        TEntity IDataContext.Remove<TEntity>(TEntity entity)
        {
            var entry = base.Remove(entity);

            return entry.Entity;
        }

        Task<TEntity> IDataContext.RemoveAsync<TEntity>(TEntity entity)
        {
            return Task.Run(() => ((IDataContext)this).Remove(entity));
        }

        public TEntity GetById<TEntity>(object id) where TEntity : class
        {
            return base.Find<TEntity>(id);
        }

        public Task<TEntity> GetByIdAsync<TEntity>(object id) where TEntity : class
        {
            return base.FindAsync<TEntity>(id);
        }

        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
        {
            return Set<TEntity>();
        }
    }
}