using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Backend.Core.Context;
using Marten;

namespace GoldenEye.Backend.Core.Marten.Context
{
    public class MartenDocumentDataContext : IDataContext
    {
        private readonly IDocumentSession _documentSession;

        private int ChangesCount
        {
            get
            {
                return _documentSession.PendingChanges.Deletions().Count()
                + _documentSession.PendingChanges.Inserts().Count()
                + _documentSession.PendingChanges.Patches().Count()
                + _documentSession.PendingChanges.Updates().Count();
            }
        }

        public MartenDocumentDataContext(IDocumentSession documentSession)
        {
            _documentSession = documentSession ?? throw new ArgumentException(nameof(documentSession));
        }

        public TEntity Add<TEntity>(TEntity entity) where TEntity : class
        {
            _documentSession.Insert(entity);

            return entity;
        }

        public Task<TEntity> AddAsync<TEntity>(TEntity entity, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            _documentSession.Store(entity);

            return Task.FromResult(entity);
        }

        public IQueryable<TEntity> AddRange<TEntity>(params TEntity[] entities) where TEntity : class
        {
            _documentSession.Store(entities);

            return entities.AsQueryable();
        }

        public void Dispose()
        {
        }

        public TEntity GetById<TEntity>(object id) where TEntity : class, new()
        {
            if (id is Guid)
                return _documentSession.Load<TEntity>((Guid)id);
            if (id is long)
                return _documentSession.Load<TEntity>((long)id);
            if (id is int)
                return _documentSession.Load<TEntity>((int)id);

            return _documentSession.Load<TEntity>(id.ToString());
        }

        public Task<TEntity> GetByIdAsync<TEntity>(object id, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class, new()
        {
            if (id is Guid)
                return _documentSession.LoadAsync<TEntity>((Guid)id, cancellationToken);
            if (id is long)
                return _documentSession.LoadAsync<TEntity>((long)id, cancellationToken);
            if (id is int)
                return _documentSession.LoadAsync<TEntity>((int)id, cancellationToken);

            return _documentSession.LoadAsync<TEntity>(id.ToString(), cancellationToken);
        }

        public IQueryable<TEntity> GetQueryable<TEntity>() where TEntity : class
        {
            return _documentSession.Query<TEntity>();
        }

        public IQueryable<TEntity> CustomQuery<TEntity>(string query) where TEntity : class
        {
            return _documentSession.Query<TEntity>(query).AsQueryable();
        }

        public TEntity Remove<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            _documentSession.Delete(entity);
            return entity;
        }

        public Task<TEntity> RemoveAsync<TEntity>(TEntity entity, int? version = null, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            _documentSession.Delete(entity);
            return Task.FromResult(entity);
        }

        public int SaveChanges()
        {
            var changesCount = ChangesCount;
            _documentSession.SaveChanges();

            return changesCount;
        }

        public async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default(CancellationToken))
        {
            var changesCount = ChangesCount;
            await _documentSession.SaveChangesAsync(cancellationToken);

            return changesCount;
        }

        public TEntity Update<TEntity>(TEntity entity, int? version = null) where TEntity : class
        {
            _documentSession.Store(entity);
            return entity;
        }

        public Task<TEntity> UpdateAsync<TEntity>(TEntity entity, int? version = null, CancellationToken cancellationToken = default(CancellationToken)) where TEntity : class
        {
            _documentSession.Store(entity);
            return Task.FromResult(entity);
        }
    }
}