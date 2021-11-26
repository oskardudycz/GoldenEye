using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events;
using GoldenEye.Events.Store;
using Marten;
using MartenEvents = Marten.Events;

namespace GoldenEye.Marten.Events.Storage;

public class MartenEventStore: IEventStore
{
    private readonly IDocumentSession documentSession;

    public MartenEventStore(IDocumentSession documentSession)
    {
        this.documentSession = documentSession ?? throw new ArgumentException(nameof(documentSession));
    }

    public Task Append(Guid streamId, int? version, CancellationToken cancellationToken = default, params IEvent[] events)
    {
        if(version.HasValue)
            documentSession.Events.Append(streamId, version, events.Cast<object>().ToArray());
        else
            documentSession.Events.Append(streamId, events.Cast<object>().ToArray());
        return Task.CompletedTask;
    }

    public Task<TEntity> Aggregate<TEntity>(Guid streamId, CancellationToken cancellationToken = default, int version = 0,
        DateTime? timestamp = null) where TEntity : class, new()
    {
        return documentSession.Events.AggregateStreamAsync<TEntity>(streamId, version, timestamp, token: cancellationToken);
    }

    public async Task<IReadOnlyList<IEvent>> Query(Guid? streamId = null,
        CancellationToken cancellationToken = default, int? fromVersion = null,
        DateTime? fromTimestamp = null)
    {
        var events = await Filter(streamId, fromVersion, fromTimestamp)
            .ToListAsync(cancellationToken);

        return events
            .Select(ev => ev.Data)
            .OfType<IEvent>()
            .ToList();
    }

    public async Task<IReadOnlyList<TEvent>> Query<TEvent>(Guid? streamId = null,
        CancellationToken cancellationToken = default,
        int? fromVersion = null,
        DateTime? fromTimestamp = null) where TEvent : class, IEvent
    {
        var events = await Filter(streamId, fromVersion, fromTimestamp)
            .ToListAsync(cancellationToken);

        return events
            .Select(ev => ev.Data)
            .OfType<TEvent>()
            .ToList();
    }

    private IQueryable<MartenEvents.IEvent> Filter(Guid? streamId, int? version, DateTime? timestamp)
    {
        var query = documentSession.Events.QueryAllRawEvents().AsQueryable();

        if (streamId.HasValue)
            query = query.Where(ev => ev.StreamId == streamId);

        if (version.HasValue)
            query = query.Where(ev => ev.Version >= version);

        if (timestamp.HasValue)
            query = query.Where(ev => ev.Timestamp >= timestamp);

        return query;
    }

    public Task SaveChanges(CancellationToken token = default)
    {
        return documentSession.SaveChangesAsync(token);
    }
}