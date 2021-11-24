using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Events.Store;

public interface IEventStore
{
    Task Append(Guid streamId, int? version, CancellationToken cancellationToken,
        params IEvent[] events);

    Task<TEntity> Aggregate<TEntity>(Guid streamId, CancellationToken cancellationToken = default,
        int version = 0, DateTime? timestamp = null) where TEntity : class, new();

    Task<IReadOnlyList<IEvent>> Query(
        Guid? streamId = null,
        CancellationToken cancellationToken = default,
        int? fromVersion = null,
        DateTime? fromTimestamp = null
    );

    Task<IReadOnlyList<TEvent>> Query<TEvent>(Guid? streamId = null,
        CancellationToken cancellationToken = default,
        int? fromVersion = null,
        DateTime? fromTimestamp = null
    ) where TEvent : class, IEvent;

    Task SaveChanges(CancellationToken token = default);
}