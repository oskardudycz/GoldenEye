using System;
using GoldenEye.Backend.Core.DDD.Events.Store;
using GoldenEye.Backend.Core.DDD.Events;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.General;
using System.Collections.Generic;
using Baseline;
using System.Linq;

namespace Backend.Core.DDD.Tests.Events.Store
{
    public partial class EventStorePipelineTests
    {
        public class EventStore : IEventStore
        {
            private IList<IEvent> events = new List<IEvent>();

            public void SaveChanges()
            {
            }

            public Task SaveChangesAsync(CancellationToken token = default(CancellationToken))
            {
                return Task.CompletedTask;
            }

            public Guid Store(Guid stream, params IEvent[] events)
            {
                this.events.AddRange(events);
                return stream;
            }

            public Task<Guid> StoreAsync(Guid stream, params IEvent[] events)
            {
                return Task.FromResult(Store(stream, events));
            }

            public TEntity Aggregate<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null)
                where TEntity : class, IHasGuidId, new()
            {
                return new TEntity();
            }

            public Task<TEntity> AggregateAsync<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null)
                where TEntity : class, IHasGuidId, new()
            {
                return Task.FromResult(Aggregate<TEntity>(streamId));
            }

            public Guid Store(Guid stream, int version, params IEvent[] events)
            {
                return Store(stream, events);
            }

            public Task<Guid> StoreAsync(Guid stream, int version, params IEvent[] events)
            {
                return StoreAsync(stream, events);
            }

            public IList<IEvent> Query(Guid? streamId = null, int? version = null, DateTime? timestamp = null)
            {
                var query = events.AsQueryable();

                if (streamId.HasValue)
                    query = query.Where(ev => ev.StreamId == streamId);

                return query.ToList();
            }

            public Task<IList<IEvent>> QueryAsync(Guid? streamId = null, int? version = null, DateTime? timestamp = null)
            {
                return Task.FromResult(Query(streamId, version, timestamp));
            }

            IList<TEvent> IEventStore.Query<TEvent>(Guid? streamId, int? version, DateTime? timestamp)
            {
                return Query(streamId, version, timestamp).OfType<TEvent>().ToList();
            }

            Task<IList<TEvent>> IEventStore.QueryAsync<TEvent>(Guid? streamId, int? version, DateTime? timestamp)
            {
                return Task.FromResult<IList<TEvent>>(Query(streamId, version, timestamp).OfType<TEvent>().ToList());
            }
        }
    }
}