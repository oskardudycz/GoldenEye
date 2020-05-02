using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using Baseline;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.DDD.Events.Store;

namespace Backend.Core.DDD.Tests.Events.Store
{
    public partial class EventStorePipelineTests
    {
        public class EventStore: IEventStore
        {
            private IList<IEvent> events = new List<IEvent>();

            public IEventProjectionStore Projections => throw new NotImplementedException();

            public void SaveChanges()
            {
            }

            public Task SaveChangesAsync(CancellationToken token = default(CancellationToken))
            {
                return Task.CompletedTask;
            }

            public Guid Store(Guid streamId, params IEvent[] events)
            {
                this.events.AddRange(events);
                return streamId;
            }

            public Task<Guid> StoreAsync(Guid streamId, params IEvent[] events)
            {
                return Task.FromResult(Store(streamId, events));
            }

            public TEntity Aggregate<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null)
                where TEntity : class, new()
            {
                return new TEntity();
            }

            public Task<TEntity> AggregateAsync<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null)
                where TEntity : class, new()
            {
                return Task.FromResult(Aggregate<TEntity>(streamId));
            }

            public Guid Store(Guid streamId, int version, params IEvent[] events)
            {
                return Store(streamId, events);
            }

            public Task<Guid> StoreAsync(Guid streamId, int version, params IEvent[] events)
            {
                return StoreAsync(streamId, events);
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

            TEvent IEventStore.FindById<TEvent>(Guid id)
            {
                throw new NotImplementedException();
            }

            public Task<Guid> StoreAsync(Guid streamId, CancellationToken cancellationToken = default(CancellationToken), params IEvent[] events)
            {
                return StoreAsync(streamId, events);
            }

            public Task<Guid> StoreAsync(Guid streamId, int version, CancellationToken cancellationToken = default(CancellationToken), params IEvent[] events)
            {
                return StoreAsync(streamId, version, events);
            }

            public Task<TEntity> AggregateAsync<TEntity>(Guid streamId, CancellationToken cancellationToken = default(CancellationToken), int version = 0, DateTime? timestamp = null) where TEntity : class, new()
            {
                throw new NotImplementedException();
            }

            Task<TEvent> IEventStore.FindByIdAsync<TEvent>(Guid id, CancellationToken cancellationToken)
            {
                throw new NotImplementedException();
            }

            public Task<IList<IEvent>> QueryAsync(CancellationToken cancellationToken = default(CancellationToken), Guid? streamId = null, int? version = null, DateTime? timestamp = null)
            {
                throw new NotImplementedException();
            }

            Task<IList<TEvent>> IEventStore.QueryAsync<TEvent>(CancellationToken cancellationToken, Guid? streamId, int? version, DateTime? timestamp)
            {
                throw new NotImplementedException();
            }
        }
    }
}
