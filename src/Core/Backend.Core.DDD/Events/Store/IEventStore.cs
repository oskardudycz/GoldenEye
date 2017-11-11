using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.Objects.General;
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;

namespace GoldenEye.Backend.Core.DDD.Events.Store
{
    public interface IEventStore
    {
        IEventProjectionStore Projections { get; }

        Guid Store(Guid streamId, params IEvent[] events);

        Guid Store(Guid streamId, int version, params IEvent[] events);

        Task<Guid> StoreAsync(Guid streamId, params IEvent[] events);

        Task<Guid> StoreAsync(Guid streamId, int version, params IEvent[] events);

        TEntity Aggregate<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null) where TEntity : class, new();

        Task<TEntity> AggregateAsync<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null) where TEntity : class, new();

        TEvent GetById<TEvent>(Guid id) where TEvent : class, IEvent, IHasGuidId;

        Task<TEvent> GetByIdAsync<TEvent>(Guid id) where TEvent : class, IEvent, IHasGuidId;

        IList<IEvent> Query(Guid? streamId = null, int? version = null, DateTime? timestamp = null);

        Task<IList<IEvent>> QueryAsync(Guid? streamId = null, int? version = null, DateTime? timestamp = null);

        IList<TEvent> Query<TEvent>(Guid? streamId = null, int? version = null, DateTime? timestamp = null) where TEvent : class, IEvent;

        Task<IList<TEvent>> QueryAsync<TEvent>(Guid? streamId = null, int? version = null, DateTime? timestamp = null) where TEvent : class, IEvent;

        void SaveChanges();

        Task SaveChangesAsync(CancellationToken token = default(CancellationToken));
    }

    public interface IEventProjectionStore
    {
        TProjection GetById<TProjection>(Guid id) where TProjection : class, IHasGuidId;

        Task<TProjection> GetByIdAsync<TProjection>(Guid id) where TProjection : class, IHasGuidId;

        IQueryable<TProjection> Query<TProjection>();
    }
}