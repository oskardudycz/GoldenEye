using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Exceptions;
using GoldenEye.Objects.General;
using GoldenEye.Objects.Versioning;
using GoldenEye.Repositories;
using Microsoft.EntityFrameworkCore;

namespace GoldenEye.EntityFramework.Repositories
{
    public class EntityFrameworkRepository<TDbContext, TEntity>:
        IRepository<TEntity>,
        IReadonlyRepository<TEntity>
        where TDbContext : DbContext
        where TEntity : class, IHaveId
    {
        private readonly TDbContext dbContext;

        public EntityFrameworkRepository(TDbContext dbContext)
        {
            this.dbContext = dbContext ?? throw new ArgumentException(nameof(dbContext));
        }

        public async Task<TEntity> FindById(object id, CancellationToken cancellationToken = default)
        {
            if (id == null)
                throw new ArgumentNullException(nameof(id), "Id needs to have value");


            return await dbContext.FindAsync<TEntity>(id);
        }

        public async Task<TEntity> GetById(object id, CancellationToken cancellationToken = default)
        {
            var entity = await FindById(id, cancellationToken);

            return entity ?? throw NotFoundException.For<TEntity>(id);
        }

        public IQueryable<TEntity> Query()
        {
            return dbContext.Set<TEntity>();
        }

        public async Task<IReadOnlyCollection<TEntity>> RawQuery(string query,
            CancellationToken cancellationToken = default, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return await dbContext.Set<TEntity>().FromSqlRaw(query, queryParams).ToListAsync(cancellationToken);
        }

        public async Task<TEntity> Add(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var entry = await dbContext.AddAsync(entity, cancellationToken);

            return entry.Entity;
        }

        public Task<TEntity> Update(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var entry = dbContext.Update(entity);

            return Task.FromResult(entry.Entity);
        }

        public Task<TEntity> Delete(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var entry = dbContext.Remove(entity);

            return Task.FromResult(entry.Entity);
        }

        public async Task<bool> DeleteById(object id, CancellationToken cancellationToken = default)
        {
            await Delete(await GetById(id, cancellationToken), cancellationToken);

            return true;
        }

        public Task SaveChanges(CancellationToken cancellationToken = default)
        {
            return dbContext.SaveChangesAsync(cancellationToken);
        }


        //TODO: Add optimistic concurrency support
        private void CheckVersion(TEntity entity, long? originVersion)
        {
            if (!originVersion.HasValue || !(entity is IVersioned versionedEntity))
                return;

            var readVersion = dbContext.Entry(versionedEntity).Property(x => x.Version).OriginalValue;

            if (originVersion != readVersion)
                throw new ArgumentException($"Optimistic Concurrency Version Mismatch for ${typeof(TEntity).Name}");
        }
    }
}
