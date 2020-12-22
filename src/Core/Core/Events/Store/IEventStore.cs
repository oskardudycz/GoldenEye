﻿using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Objects.General;

namespace GoldenEye.Events.Store
{
    public interface IEventStore
    {
        Task Append(Guid streamId, CancellationToken cancellationToken = default, params IEvent[] events);

        Task Append(Guid streamId, int version, CancellationToken cancellationToken = default,
            params IEvent[] events);

        Task<TEntity> Aggregate<TEntity>(Guid streamId, CancellationToken cancellationToken = default,
            int version = 0, DateTime? timestamp = null) where TEntity : class, new();

        Task<TEvent> FindById<TEvent>(Guid eventId, CancellationToken cancellationToken = default)
            where TEvent : class, IEvent, IHaveGuidId;

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
}
