using System;
using System.Collections.Generic;
using System.Linq;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using GoldenEye.Backend.Core.Entity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;
using System.Threading.Tasks;
using System.Threading;
using GoldenEye.Shared.Core.Objects.Versioning;

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
                    .Select(e => new EntityEntry((EntityEntryState)(int)e.State, (IEntity)e.Entity));
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

        TEntity IDataContext.Update<TEntity>(TEntity entity, int? version = null)
        {
            CheckVersion(entity, version);
            var entry = dbContext.Update(entity);

            return entry.Entity;
        }

        Task<TEntity> IDataContext.UpdateAsync<TEntity>(TEntity entity, int? version = null)
        {
            CheckVersion(entity, version);
            return Task.Run(() => ((IDataContext)this).Update(entity));
        }

        TEntity IDataContext.Remove<TEntity>(TEntity entity, int? version = null)
        {
            CheckVersion(entity, version);
            var entry = dbContext.Remove(entity);

            return entry.Entity;
        }

        Task<TEntity> IDataContext.RemoveAsync<TEntity>(TEntity entity, int? version = null)
        {
            CheckVersion(entity, version);
            return Task.Run(() => ((IDataContext)this).Remove(entity));
        }

        public TEntity GetById<TEntity>(object id) where TEntity : class, new()
        {
            return dbContext.Find<TEntity>(id);
        }

        public Task<TEntity> GetByIdAsync<TEntity>(object id) where TEntity : class, new()
        {
            return dbContext.FindAsync<TEntity>(id);
        }

        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
        {
            return dbContext.Set<TEntity>();
        }

        private void CheckVersion<TEntity>(TEntity entity, long? originVersion) where TEntity : class
        {
            if (!originVersion.HasValue || !(entity is IVersioned versionedEntity))
                return;

            var readVersion = dbContext.Entry(versionedEntity).Property(x => x.Version).OriginalValue;

            if (originVersion != readVersion)
                throw new ArgumentException($"Optimistic Concurrency Version Mistmatch for ${typeof(TEntity).Name}");
        }
    }
}