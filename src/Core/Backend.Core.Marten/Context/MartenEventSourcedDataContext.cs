//using GoldenEye.Backend.Core.Context;
//using Marten;
//using System;
//using System.Linq;
//using System.Threading.Tasks;

//namespace GoldenEye.Backend.Core.Marten.Context
//{
//    public class MartenEventSourcedDataContext : IDataContext
//    {
//        private readonly IDocumentSession _documentSession;
//        private int ChangesCount
//        {
//            get
//            {
//                return _documentSession.PendingChanges.Deletions().Count()
//                + _documentSession.PendingChanges.Inserts().Count()
//                + _documentSession.PendingChanges.Patches().Count()
//                + _documentSession.PendingChanges.Updates().Count();
//            }
//        }

//        public MartenEventSourcedDataContext(IDocumentSession documentSession)
//        {
//            _documentSession = documentSession ?? throw new ArgumentException(nameof(documentSession));
//        }

//        public TEntity Add<TEntity>(TEntity entity) where TEntity : class
//        {
//            _documentSession.Insert(entity);

//            return entity;
//        }

//        public Task<TEntity> AddAsync<TEntity>(TEntity entity) where TEntity : class
//        {
//            _documentSession.Insert(entity);

//            return Task.FromResult(entity);
//        }

//        public IQueryable<TEntity> AddRange<TEntity>(params TEntity[] entities) where TEntity : class
//        {
//            _documentSession.Insert(entities);

//            return entities.AsQueryable();
//        }

//        public void Dispose()
//        {
//            _documentSession.Dispose();
//        }

//        public TEntity GetById<TEntity>(object id) where TEntity : class
//        {
//            if (!(id is Guid))
//                throw new NotSupportedException("Id of the Event Sourced aggregate has to be Guid");
            
//            if ((await _documentSession.Events.FetchStreamStateAsync((Guid)id)) == null)
//                return null;

//            return await _documentSession.Events.AggregateStreamAsync<TEntity>((Guid)id);
//        }

//        public async Task<TEntity> GetByIdAsync<TEntity>(object id) where TEntity : class
//        {
//            if (!(id is Guid))
//                throw new NotSupportedException("Id of the Event Sourced aggregate has to be Guid");
            
//            if ((await _documentSession.Events.FetchStreamStateAsync((Guid)id)) == null)
//                return null;

//            return await _documentSession.Events.AggregateStreamAsync<TEntity>((Guid)id);
//        }

//        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
//        {
//            return _documentSession.Query<TEntity>();
//        }

//        public TEntity Remove<TEntity>(TEntity entity) where TEntity : class
//        {
//            _documentSession.Delete(entity);
//            return entity;
//        }

//        public Task<TEntity> RemoveAsync<TEntity>(TEntity entity) where TEntity : class
//        {
//            _documentSession.Delete(entity);
//            return Task.FromResult(entity);
//        }

//        public int SaveChanges()
//        {
//            var changesCount = ChangesCount;
//            _documentSession.SaveChanges();

//            return changesCount;
//        }

//        public async Task<int> SaveChangesAsync()
//        {
//            var changesCount = ChangesCount;
//            await _documentSession.SaveChangesAsync();

//            return changesCount;
//        }

//        public TEntity Update<TEntity>(TEntity entity) where TEntity : class
//        {
//            _documentSession.Update(entity);
//            return entity;
//        }

//        public Task<TEntity> UpdateAsync<TEntity>(TEntity entity) where TEntity : class
//        {
//            _documentSession.Update(entity);
//            return Task.FromResult(entity);
//        }
//    }
//}
