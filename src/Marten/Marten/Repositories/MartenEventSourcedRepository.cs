using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events;
using GoldenEye.Events.Store;
using GoldenEye.Exceptions;
using GoldenEye.Extensions.Collections;
using GoldenEye.Marten.Events.Storage;
using GoldenEye.Objects.General;
using GoldenEye.Repositories;
using Marten;

namespace GoldenEye.Marten.Repositories
{
    public class MartenEventSourcedRepository<TEntity>:
        IRepository<TEntity>,
        IReadonlyRepository<TEntity>
        where TEntity : class, IHaveId, IEventSource, new()
    {
        private readonly IDocumentSession documentSession;
        private readonly IEventStore eventStore;

        public MartenEventSourcedRepository(IDocumentSession documentSession, MartenEventStore eventStore)
        {
            this.documentSession = documentSession ?? throw new ArgumentException(nameof(documentSession));
            this.eventStore = eventStore ?? throw new ArgumentException(nameof(eventStore));
        }

        public async Task<TEntity> FindById(object id, CancellationToken cancellationToken = default)
        {
            if (!(id is Guid guidId))
                throw new NotSupportedException("Id of the Event Sourced aggregate has to be Guid");

            return (await documentSession.Events.FetchStreamStateAsync(guidId, cancellationToken)) != null
                ? await eventStore.AggregateAsync<TEntity>(guidId, cancellationToken: cancellationToken)
                : null;
        }

        public async Task<TEntity> GetById(object id, CancellationToken cancellationToken = default)
        {
            var entity = await FindById(id, cancellationToken);

            return entity ?? throw NotFoundException.For<TEntity>(id);
        }

        public IQueryable<TEntity> Query()
        {
            return documentSession.Query<TEntity>();
        }

        public async Task<IReadOnlyCollection<TEntity>> RawQuery(string query,
            CancellationToken cancellationToken = default, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return await documentSession.QueryAsync<TEntity>(query, cancellationToken, queryParams);
        }

        public Task<TEntity> Add(TEntity entity, CancellationToken cancellationToken)
        {
            return Store(entity, cancellationToken);
        }

        public Task<TEntity> Update(TEntity entity, CancellationToken cancellationToken = default)
        {
            return Store(entity, cancellationToken);
        }

        public Task<TEntity> Update(TEntity entity, object expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<TEntity> Delete(TEntity entity, CancellationToken cancellationToken = default)
        {
            return Store(entity, null, cancellationToken);
        }

        public Task<TEntity> Delete(TEntity entity, object expectedVersion, CancellationToken cancellationToken = default)
        {
            return Store(entity, expectedVersion, cancellationToken);
        }

        public Task<bool> DeleteById(object id, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException(
                $"{nameof(DeleteById)} is not supported by Event Source repository. Use method with entity object.");
        }

        public Task<bool> DeleteById(object id, object expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException(
                $"{nameof(DeleteById)} is not supported by Event Source repository. Use method with entity object.");
        }

        public Task SaveChanges(CancellationToken cancellationToken = default)
        {
            return documentSession.SaveChangesAsync(cancellationToken);
        }

        private async Task<TEntity> Store(TEntity entity, object expectedVersion, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            if (expectedVersion != null)
            {
                if (!(expectedVersion is int intExpectedVersion))
                    throw new ArgumentOutOfRangeException(nameof(expectedVersion),
                        $"{nameof(MartenEventSourcedRepository<TEntity>)} supports only version of type int");

                await eventStore.AppendAsync(entity.Id, intExpectedVersion, cancellationToken, entity.PendingEvents.ToArray());
            }

            await eventStore.AppendAsync(entity.Id, cancellationToken, entity.PendingEvents.ToArray());

            return entity;
        }
    }
}
