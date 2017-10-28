using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.Objects.General;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace GoldenEye.Backend.Core.DDD.Events.Store
{
    public interface IEventStore
    {
        Guid Store(Guid stream, params IEvent[] events);

        Guid Store(Guid stream, int version, params IEvent[] events);

        Task<Guid> StoreAsync(Guid stream, params IEvent[] events);

        Task<Guid> StoreAsync(Guid stream, int version, params IEvent[] events);

        TEntity Aggregate<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null) where TEntity : class, IHasGuidId, new();

        Task<TEntity> AggregateAsync<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null) where TEntity : class, IHasGuidId, new();

        IList<IEvent> Query(Guid? streamId = null, int? version = null, DateTime? timestamp = null);

        Task<IList<IEvent>> QueryAsync(Guid? streamId = null, int? version = null, DateTime? timestamp = null);

        IList<TEvent> Query<TEvent>(Guid? streamId = null, int? version = null, DateTime? timestamp = null) where TEvent : class, IEvent;

        Task<IList<TEvent>> QueryAsync<TEvent>(Guid? streamId = null, int? version = null, DateTime? timestamp = null) where TEvent : class, IEvent;

        void SaveChanges();

        Task SaveChangesAsync(CancellationToken token = default(CancellationToken));
    }
}