using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.Exceptions;
using GoldenEye.Shared.Core.Objects.General;
using GoldenEye.Shared.Core.Objects.Versioning;
using Microsoft.EntityFrameworkCore;

namespace GoldenEye.Backend.Core.Repositories
{
    public class EntityFrameworkRepository<TDbContext, TEntity>: IRepository<TEntity>
        where TDbContext : DbContext where TEntity : class, IHaveId
    {
        private readonly TDbContext dbContext;

        public EntityFrameworkRepository(TDbContext dbContext)
        {
            this.dbContext = dbContext ?? throw new ArgumentException(nameof(dbContext));
        }

        public TEntity FindById(object id)
        {
            if (id == null)
                throw new ArgumentNullException("Id needs to have value");

            return dbContext.Find<TEntity>(id);
        }

        public async Task<TEntity> FindByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            if (id == null)
                throw new ArgumentNullException("Id needs to have value");


            return await dbContext.FindAsync<TEntity>(id);
        }

        public TEntity GetById(object id)
        {
            return FindById(id) ?? throw NotFoundException.For<TEntity>(id);
        }

        public async Task<TEntity> GetByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            var entity = await FindByIdAsync(id, cancellationToken);

            return entity ?? throw NotFoundException.For<TEntity>(id);
        }

        public IQueryable<TEntity> Query()
        {
            return dbContext.Set<TEntity>();
        }

        public IReadOnlyCollection<TEntity> Query(string query, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return dbContext.Set<TEntity>().FromSqlRaw(query, queryParams).ToList();
        }

        public async Task<IReadOnlyCollection<TEntity>> QueryAsync(string query,
            CancellationToken cancellationToken = default, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return await dbContext.Set<TEntity>().FromSqlRaw(query, queryParams).ToListAsync(cancellationToken);
        }

        public TEntity Add(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var entry = dbContext.Add(entity);

            return entry.Entity;
        }

        public async Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var entry = await dbContext.AddAsync(entity, cancellationToken);

            return entry.Entity;
        }

        public IReadOnlyCollection<TEntity> AddAll(params TEntity[] entities)
        {
            if (entities == null)
                throw new ArgumentNullException(nameof(entities));

            if (entities.Length == 0)
                throw new ArgumentOutOfRangeException(nameof(entities), entities.Length,
                    $"{nameof(AddAll)} needs to have at least one entity provided.");

            dbContext.AddRange(entities);

            return entities;
        }

        public async Task<IReadOnlyCollection<TEntity>> AddAllAsync(CancellationToken cancellationToken = default,
            params TEntity[] entities)
        {
            if (entities == null)
                throw new ArgumentNullException(nameof(entities));

            if (entities.Length == 0)
                throw new ArgumentOutOfRangeException(nameof(entities), entities.Length,
                    $"{nameof(AddAll)} needs to have at least one entity provided.");

            await dbContext.AddRangeAsync(entities);

            return entities;
        }

        public TEntity Update(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var entry = dbContext.Update(entity);

            return entry.Entity;
        }

        public Task<TEntity> UpdateAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(Update(entity));
        }

        public TEntity Delete(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var entry = dbContext.Remove(entity);

            return entry.Entity;
        }

        public Task<TEntity> DeleteAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(Delete(entity));
        }

        public bool DeleteById(object id)
        {
            Delete(GetById(id));

            return true;
        }

        public async Task<bool> DeleteByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            await DeleteAsync(await GetByIdAsync(id, cancellationToken), cancellationToken);

            return true;
        }

        public void SaveChanges()
        {
            dbContext.SaveChanges();
        }

        public Task SaveChangesAsync(CancellationToken cancellationToken = default)
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
                throw new ArgumentException($"Optimistic Concurrency Version Mistmatch for ${typeof(TEntity).Name}");
        }
    }
}
