using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events;
using GoldenEye.Events.Store;
using GoldenEye.Exceptions;
using GoldenEye.Marten.Events.Storage;
using GoldenEye.Objects.General;
using GoldenEye.Repositories;
using Marten;

namespace GoldenEye.Marten.Repositories
{
    public class MartenEventSourcedRepository<TEntity>: IRepository<TEntity>
        where TEntity : class, IHaveId, IEventSource, new()
    {
        private readonly IDocumentSession documentSession;
        private readonly IEventStore eventStore;

        public MartenEventSourcedRepository(IDocumentSession documentSession, MartenEventStore eventStore)
        {
            this.documentSession = documentSession ?? throw new ArgumentException(nameof(documentSession));
            this.eventStore = eventStore ?? throw new ArgumentException(nameof(eventStore));
        }

        public TEntity FindById(object id)
        {
            if (!(id is Guid guidId))
                throw new NotSupportedException("Id of the Event Sourced aggregate has to be Guid");

            return documentSession.Events.FetchStreamState(guidId) != null
                ? eventStore.Aggregate<TEntity>(guidId)
                : null;
        }

        public async Task<TEntity> FindByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            if (!(id is Guid guidId))
                throw new NotSupportedException("Id of the Event Sourced aggregate has to be Guid");

            return (await documentSession.Events.FetchStreamStateAsync(guidId, cancellationToken)) != null
                ? await eventStore.AggregateAsync<TEntity>(guidId, cancellationToken: cancellationToken)
                : null;
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
            return documentSession.Query<TEntity>();
        }

        public IReadOnlyCollection<TEntity> Query(string query, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return documentSession.Query<TEntity>(query, queryParams);
        }

        public async Task<IReadOnlyCollection<TEntity>> QueryAsync(string query,
            CancellationToken cancellationToken = default, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return await documentSession.QueryAsync<TEntity>(query, cancellationToken, queryParams);
        }

        public TEntity Add(TEntity entity)
        {
            return Store(entity);
        }

        public Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken)
        {
            return StoreAsync(entity, cancellationToken);
        }

        public IReadOnlyCollection<TEntity> AddAll(params TEntity[] entities)
        {
            if (entities == null)
                throw new ArgumentNullException(nameof(entities));

            if (entities.Length == 0)
                throw new ArgumentOutOfRangeException(nameof(entities), entities.Length,
                    $"{nameof(AddAll)} needs to have at least one entity provided.");

            documentSession.Insert(entities);

            return entities;
        }

        public Task<IReadOnlyCollection<TEntity>> AddAllAsync(CancellationToken cancellationToken = default,
            params TEntity[] entities)
        {
            var result = AddAll(entities);

            return Task.FromResult(result);
        }

        public TEntity Update(TEntity entity)
        {
            return Store(entity);
        }

        public Task<TEntity> UpdateAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            return StoreAsync(entity, cancellationToken);
        }

        public TEntity Delete(TEntity entity)
        {
            return Store(entity);
        }

        public Task<TEntity> DeleteAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            return StoreAsync(entity, cancellationToken);
        }

        public bool DeleteById(object id)
        {
            throw new NotImplementedException(
                $"{nameof(DeleteById)} is not supported by Event Source repository. Use method with entity object.");
        }

        public Task<bool> DeleteByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException(
                $"{nameof(DeleteByIdAsync)} is not supported by Event Source repository. Use method with entity object.");
        }

        public void SaveChanges()
        {
            documentSession.SaveChanges();
        }

        public Task SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            return documentSession.SaveChangesAsync(cancellationToken);
        }

        private TEntity Store(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            documentSession.Delete(entity);

            return entity;
        }

        private async Task<TEntity> StoreAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            await eventStore.AppendAsync(entity.Id, cancellationToken, entity.PendingEvents.ToArray());

            return entity;
        }
    }
}
