using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.Context.SaveChangesHandlers;
using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.Objects.Versioning;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Storage;

namespace GoldenEye.Backend.Core.Context
{
    public class EFDataContext<T>: IDataContext, IProvidesAuditInfo where T : DbContext
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
            return SaveChangesAsync(default(CancellationToken));
        }

        public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken))
        {
            SaveChangesProcessor.Instance.RunAll(this);
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

        async Task<TEntity> IDataContext.AddAsync<TEntity>(TEntity entity, CancellationToken cancellationToken)
        {
            var entry = await dbContext.AddAsync(entity, cancellationToken);

            return entry.Entity;
        }

        IQueryable<TEntity> IDataContext.AddRange<TEntity>(params TEntity[] entities)
        {
            dbContext.AddRange(entities);

            return entities.AsQueryable();
        }

        TEntity IDataContext.Update<TEntity>(TEntity entity, int? version)
        {
            CheckVersion(entity, version);
            var entry = dbContext.Update(entity);

            return entry.Entity;
        }

        Task<TEntity> IDataContext.UpdateAsync<TEntity>(TEntity entity, int? version, CancellationToken cancellationToken)
        {
            CheckVersion(entity, version);
            return Task.FromResult(((IDataContext)this).Update(entity, version));
        }

        TEntity IDataContext.Remove<TEntity>(TEntity entity, int? version)
        {
            CheckVersion(entity, version);
            var entry = dbContext.Remove(entity);

            return entry.Entity;
        }

        Task<TEntity> IDataContext.RemoveAsync<TEntity>(TEntity entity, int? version, CancellationToken cancellationToken)
        {
            CheckVersion(entity, version);
            return Task.FromResult(((IDataContext)this).Remove(entity, version));
        }

        bool IDataContext.Remove<TEntity>(object id, int? version)
        {
            var entity = dbContext.Find<TEntity>(id);

            CheckVersion(entity, version);
            dbContext.Remove(id);

            return true;
        }

        Task<bool> IDataContext.RemoveAsync<TEntity>(object id, int? version, CancellationToken cancellationToken)
        {
            return Task.FromResult(((IDataContext)this).Remove<TEntity>(id, version));
        }

        public TEntity GetById<TEntity>(object id) where TEntity : class, new()
        {
            return dbContext.Find<TEntity>(id);
        }

        public async Task<TEntity> GetByIdAsync<TEntity>(object id, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class, new()
        {
            return await dbContext.FindAsync<TEntity>(new[] { id }, cancellationToken);
        }

        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
        {
            return dbContext.Set<TEntity>();
        }

        public IQueryable<TEntity> CustomQuery<TEntity>(string query) where TEntity : class
        {
            return dbContext.Set<TEntity>().FromSqlRaw(query);
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
