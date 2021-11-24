using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events;
using GoldenEye.Events.Store;
using GoldenEye.Extensions.Collections;
using GoldenEye.Objects.General;

namespace GoldenEye.Tests.Events.Store;

public partial class EventStorePipelineTests
{
    public class EventStore: IEventStore
    {
        private readonly IList<IEvent> events = new List<IEvent>();

        public Task Append(Guid streamId, int? version, CancellationToken cancellationToken = default, params IEvent[] events)
        {
            this.events.AddRange(events);
            return Task.CompletedTask;
        }

        public Task<TEntity> Aggregate<TEntity>(Guid streamId, CancellationToken cancellationToken = default, int version = 0,
            DateTime? timestamp = null) where TEntity : class, new()
        {
            return Task.FromResult(new TEntity());
        }

        public Task<TEvent> FindById<TEvent>(Guid eventId, CancellationToken cancellationToken = default) where TEvent : class, IEvent, IHaveGuidId
        {
            throw new NotImplementedException();
        }

        public Task<IReadOnlyList<IEvent>> Query(Guid? streamId = null,
            CancellationToken cancellationToken = default, int? fromVersion = null,
            DateTime? fromTimestamp = null)
        {
            var query = events.AsQueryable();

            if (streamId.HasValue)
                query = query.Where(ev => ev.StreamId == streamId);

            var result = query.OfType<IEvent>().ToList();

            return Task.FromResult((IReadOnlyList<IEvent>) result);
        }

        public Task<IReadOnlyList<TEvent>> Query<TEvent>(Guid? streamId = null,
            CancellationToken cancellationToken = default, int? fromVersion = null,
            DateTime? fromTimestamp = null) where TEvent : class, IEvent
        {
            var query = events.AsQueryable();

            if (streamId.HasValue)
                query = query.Where(ev => ev.StreamId == streamId);

            var result = query.OfType<TEvent>().ToList();

            return Task.FromResult((IReadOnlyList<TEvent>) result);
        }

        public Task SaveChanges(CancellationToken token = default)
        {
            return Task.CompletedTask;
        }
    }
}