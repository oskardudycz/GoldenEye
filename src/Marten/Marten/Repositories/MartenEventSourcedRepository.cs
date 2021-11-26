using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Aggregates;
using GoldenEye.Events.Aggregate;
using GoldenEye.Marten.Events.Storage;
using GoldenEye.Objects.General;
using GoldenEye.Repositories;
using Marten;
using IEventStore = GoldenEye.Events.Store.IEventStore;

namespace GoldenEye.Marten.Repositories;

public class MartenEventSourcedRepository<TEntity>:
    IRepository<TEntity>,
    IReadonlyRepository<TEntity>
    where TEntity : class, IHaveId, IAggregate, new()
{
    private readonly IDocumentSession documentSession;
    private readonly IEventStore eventStore;
    private readonly IAggregateEventsPublisher aggregateEventsPublisher;

    public MartenEventSourcedRepository(IDocumentSession documentSession, MartenEventStore eventStore, IAggregateEventsPublisher aggregateEventsPublisher)
    {
        this.documentSession = documentSession ?? throw new ArgumentException(nameof(documentSession));
        this.eventStore = eventStore ?? throw new ArgumentException(nameof(eventStore));
        this.aggregateEventsPublisher = aggregateEventsPublisher ?? throw new ArgumentException(nameof(aggregateEventsPublisher));
    }

    public async Task<TEntity> FindById(object id, CancellationToken cancellationToken = default)
    {
        if (id is not Guid guidId)
            throw new NotSupportedException("Id of the Event Sourced aggregate has to be Guid");

        return (await documentSession.Events.FetchStreamStateAsync(guidId, cancellationToken)) != null
            ? await eventStore.Aggregate<TEntity>(guidId, cancellationToken)
            : null;
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
        return Store(entity, null, cancellationToken);
    }

    public Task<TEntity> Update(TEntity entity, int? expectedVersion, CancellationToken cancellationToken = default)
    {
        return Store(entity, expectedVersion, cancellationToken);
    }

    public Task<TEntity> Delete(TEntity entity, int? expectedVersion, CancellationToken cancellationToken = default)
    {
        return Store(entity, expectedVersion, cancellationToken);
    }

    public Task<bool> DeleteById(object id, int? expectedVersion, CancellationToken cancellationToken = default)
    {
        throw new NotImplementedException(
            $"{nameof(DeleteById)} is not supported by Event Source repository. Use method with entity object.");
    }

    public async Task SaveChanges(CancellationToken cancellationToken = default)
    {
        await documentSession.SaveChangesAsync(cancellationToken);

        await aggregateEventsPublisher.Publish(cancellationToken);
    }

    private async Task<TEntity> Store(TEntity entity, int? expectedVersion, CancellationToken cancellationToken = default)
    {
        if (entity == null)
            throw new ArgumentNullException(nameof(entity));

        var entityEvents = aggregateEventsPublisher.EnqueueEventsFrom(entity);

        await eventStore.Append(entity.Id, expectedVersion, cancellationToken, entityEvents);

        return entity;
    }
}
