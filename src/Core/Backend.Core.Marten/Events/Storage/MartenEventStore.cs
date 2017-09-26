using System;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.DDD.Events.Store;
using Marten;
using GoldenEye.Shared.Core.Objects.General;
using System.Linq;

namespace GoldenEye.Backend.Core.Marten.Events.Storage
{
    public class MartenEventStore : IEventStore
    {
        private readonly IDocumentSession documentSession;

        public MartenEventStore(IDocumentSession documentSession)
        {
            this.documentSession = documentSession ?? throw new ArgumentException(nameof(documentSession));
        }

        public void SaveChanges()
        {
            documentSession.SaveChanges();
        }

        public Task SaveChangesAsync(CancellationToken token = default(CancellationToken))
        {
            return documentSession.SaveChangesAsync(token);
        }

        public Guid Store(Guid stream, params IEvent[] events)
        {
            return documentSession.Events.Append(stream, events.Cast<object>().ToArray()).Id;
        }

        public Task<Guid> StoreAsync(Guid stream, params IEvent[] events)
        {
            return Task.FromResult(Store(stream, events));
        }

        public TEntity Aggregate<TEntity>(Guid streamId) where TEntity : class, IHasGuidId, new()
        {
            return documentSession.Events.AggregateStream<TEntity>(streamId);
        }

        public Task<TEntity> AggregateAsync<TEntity>(Guid streamId) where TEntity : class, IHasGuidId, new()
        {
            return documentSession.Events.AggregateStreamAsync<TEntity>(streamId);
        }
    }
}
