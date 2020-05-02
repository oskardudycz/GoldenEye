using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.General;

namespace GoldenEye.Backend.Core.DDD.Events.Store
{
    public interface IEventStore
    {
        IEventProjectionStore Projections { get; }

        Guid Store(Guid streamId, params IEvent[] events);

        Guid Store(Guid streamId, int version, params IEvent[] events);

        Task<Guid> StoreAsync(Guid streamId, params IEvent[] events);

        Task<Guid> StoreAsync(Guid streamId, CancellationToken cancellationToken = default(CancellationToken), params IEvent[] events);

        Task<Guid> StoreAsync(Guid streamId, int version, params IEvent[] events);

        Task<Guid> StoreAsync(Guid streamId, int version, CancellationToken cancellationToken = default(CancellationToken), params IEvent[] events);

        TEntity Aggregate<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null) where TEntity : class, new();

        Task<TEntity> AggregateAsync<TEntity>(Guid streamId, int version = 0, DateTime? timestamp = null) where TEntity : class, new();

        Task<TEntity> AggregateAsync<TEntity>(Guid streamId, CancellationToken cancellationToken = default(CancellationToken), int version = 0, DateTime? timestamp = null) where TEntity : class, new();

        TEvent GetById<TEvent>(Guid id) where TEvent : class, IEvent, IHaveGuidId;

        Task<TEvent> GetByIdAsync<TEvent>(Guid id, CancellationToken cancellationToken = default(CancellationToken)) where TEvent : class, IEvent, IHaveGuidId;

        IList<IEvent> Query(Guid? streamId = null, int? version = null, DateTime? timestamp = null);

        Task<IList<IEvent>> QueryAsync(Guid? streamId = null, int? version = null, DateTime? timestamp = null);

        Task<IList<IEvent>> QueryAsync(CancellationToken cancellationToken = default(CancellationToken), Guid? streamId = null, int? version = null, DateTime? timestamp = null);

        IList<TEvent> Query<TEvent>(Guid? streamId = null, int? version = null, DateTime? timestamp = null) where TEvent : class, IEvent;

        Task<IList<TEvent>> QueryAsync<TEvent>(Guid? streamId = null, int? version = null, DateTime? timestamp = null) where TEvent : class, IEvent;

        Task<IList<TEvent>> QueryAsync<TEvent>(CancellationToken cancellationToken = default(CancellationToken), Guid? streamId = null, int? version = null, DateTime? timestamp = null) where TEvent : class, IEvent;

        void SaveChanges();

        Task SaveChangesAsync(CancellationToken token = default(CancellationToken));
    }

    public interface IEventProjectionStore
    {
        TProjection GetById<TProjection>(Guid id) where TProjection : class, IHaveGuidId;

        Task<TProjection> GetByIdAsync<TProjection>(Guid id, CancellationToken cancellationToken = default(CancellationToken)) where TProjection : class, IHaveGuidId;

        IQueryable<TProjection> Query<TProjection>();

        IQueryable<TProjection> CustomQuery<TProjection>(string query);
    }
}