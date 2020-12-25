using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events;
using GoldenEye.Events.Aggregate;
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
        private readonly IAggregateEventsPublisher aggregateEventsPublisher;

        public EntityFrameworkRepository(TDbContext dbContext, IAggregateEventsPublisher aggregateEventsPublisher)
        {
            this.dbContext = dbContext ?? throw new ArgumentException(nameof(dbContext));
            this.aggregateEventsPublisher = aggregateEventsPublisher ?? throw new ArgumentException(nameof(aggregateEventsPublisher));
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

            aggregateEventsPublisher.TryEnqueueEventsFrom(entity, out var pendingEvents);

            return entry.Entity;
        }

        public Task<TEntity> Update(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var entry = dbContext.Update(entity);

            aggregateEventsPublisher.TryEnqueueEventsFrom(entity, out _);

            return Task.FromResult(entry.Entity);
        }

        public Task<TEntity> Update(TEntity entity, int expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<TEntity> Delete(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var entry = dbContext.Remove(entity);

            aggregateEventsPublisher.TryEnqueueEventsFrom(entity, out _);

            return Task.FromResult(entry.Entity);
        }

        public Task<TEntity> Delete(TEntity entity, int expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public async Task<bool> DeleteById(object id, CancellationToken cancellationToken = default)
        {
            await Delete(await GetById(id, cancellationToken), cancellationToken);

            return true;
        }

        public Task<bool> DeleteById(object id, int expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public async Task SaveChanges(CancellationToken cancellationToken = default)
        {
            await dbContext.SaveChangesAsync(cancellationToken);

            await aggregateEventsPublisher.Publish(cancellationToken);
        }


        //TODO: Add optimistic concurrency support
        private void CheckVersion(TEntity entity, long? originVersion)
        {
            if (!originVersion.HasValue || !(entity is IHaveVersion versionedEntity))
                return;

            var readVersion = dbContext.Entry(versionedEntity).Property(x => x.Version).OriginalValue;

            if (originVersion != readVersion)
                throw new ArgumentException($"Optimistic Concurrency Version Mismatch for ${typeof(TEntity).Name}");
        }
    }
}
