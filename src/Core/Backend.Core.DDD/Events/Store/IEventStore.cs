using GoldenEye.Backend.Core.Entity;
using GoldenEye.Shared.Core.Objects.General;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace GoldenEye.Backend.Core.DDD.Events.Store
{
    public interface IEventStore
    {
        Guid Store(Guid stream, params IEvent[] events);
        Task<Guid> StoreAsync(Guid stream, params IEvent[] events);

        TEntity Aggregate<TEntity>(Guid streamId) where TEntity : class, IHasGuidId, new();
        Task<TEntity> AggregateAsync<TEntity>(Guid streamId) where TEntity : class, IHasGuidId, new();

        void SaveChanges();
        Task SaveChangesAsync(CancellationToken token = default(CancellationToken));
    }
}
