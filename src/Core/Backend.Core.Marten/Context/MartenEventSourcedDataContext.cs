using GoldenEye.Backend.Core.Context;
using Marten;
using System;
using System.Linq;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.DDD.Events.Store;
using GoldenEye.Backend.Core.DDD.Events;

namespace GoldenEye.Backend.Core.Marten.Context
{
    public class MartenEventSourcedDataContext : IDataContext
    {
        private readonly IDocumentSession documentSession;
        private readonly IEventStore eventStore;

        private int ChangesCount
        {
            get
            {
                return documentSession.PendingChanges.Deletions().Count()
                + documentSession.PendingChanges.Inserts().Count()
                + documentSession.PendingChanges.Patches().Count()
                + documentSession.PendingChanges.Updates().Count();
            }
        }

        public MartenEventSourcedDataContext(IDocumentSession documentSession, IEventStore eventStore)
        {
            this.documentSession = documentSession ?? throw new ArgumentException(nameof(documentSession));
            this.eventStore = eventStore ?? throw new ArgumentException(nameof(eventStore));
        }

        public TEntity Add<TEntity>(TEntity entity) where TEntity : class
        {
            if (!(entity is IEventSource esEntity))
                throw new ArgumentException($"Entity {typeof(TEntity)} does not implement IEventSource! It's needed for  usage in MartenEventSourcedDataContext.");

            eventStore.Store(esEntity.Id, esEntity.PendingEvents.ToArray());

            return entity;
        }

        public async Task<TEntity> AddAsync<TEntity>(TEntity entity) where TEntity : class
        {
            if (!(entity is IEventSource esEntity))
                throw new ArgumentException($"Entity {typeof(TEntity)} does not implement IEventSource! It's needed for  usage in MartenEventSourcedDataContext.");

            await eventStore.StoreAsync(esEntity.Id, esEntity.PendingEvents.ToArray());

            return entity;
        }

        public IQueryable<TEntity> AddRange<TEntity>(params TEntity[] entities) where TEntity : class
        {
            foreach (var entity in entities)
                Add(entity);

            return entities.AsQueryable();
        }

        public void Dispose()
        {
        }

        public TEntity GetById<TEntity>(object id) where TEntity : class, new()
        {
            if (!(id is Guid guidId))
                throw new NotSupportedException("Id of the Event Sourced aggregate has to be Guid");

            return eventStore.Aggregate<TEntity>(guidId);
        }

        public async Task<TEntity> GetByIdAsync<TEntity>(object id) where TEntity : class, new()
        {
            if (!(id is Guid guidId))
                throw new NotSupportedException("Id of the Event Sourced aggregate has to be Guid");

            if ((await documentSession.Events.FetchStreamStateAsync((Guid)id)) == null)
                return null;

            return await eventStore.AggregateAsync<TEntity>(guidId);
        }

        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
        {
            return eventStore.Projections.Query<TEntity>();
        }

        public TEntity Remove<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            return Update(entity);
        }

        public Task<TEntity> RemoveAsync<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            return UpdateAsync(entity);
        }

        public int SaveChanges()
        {
            var changesCount = ChangesCount;
            documentSession.SaveChanges();

            return changesCount;
        }

        public async Task<int> SaveChangesAsync()
        {
            var changesCount = ChangesCount;
            await documentSession.SaveChangesAsync();

            return changesCount;
        }

        public TEntity Update<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            if (!(entity is IEventSource esEntity))
                throw new ArgumentException($"Entity {typeof(TEntity)} does not implement IEventSource! It's needed for  usage in MartenEventSourcedDataContext.");

            eventStore.Store(esEntity.Id, esEntity.PendingEvents.ToArray());

            return entity;
        }

        public async Task<TEntity> UpdateAsync<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            if (!(entity is IEventSource esEntity))
                throw new ArgumentException($"Entity {typeof(TEntity)} does not implement IEventSource! It's needed for  usage in MartenEventSourcedDataContext.");

            await eventStore.StoreAsync(esEntity.Id, esEntity.PendingEvents.ToArray());

            return entity;
        }

        //private async Task CheckVersion<TEntity>(TEntity entity, long? originVersion)
        //{
        //    try
        //    {
        //        var entry = await FindAsync(aggregate.Id);
        //        if (entry != null)
        //        {
        //            if (entry.Version != originVersion)
        //                throw new OptimisticConcurrencyException(entityName, aggregateId);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        if (ex is OptimisticConcurrencyException)
        //        {
        //            throw;
        //        }
        //    }
        //}
    }
}