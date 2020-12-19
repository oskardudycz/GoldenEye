using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Exceptions;
using GoldenEye.Objects.General;
using GoldenEye.Repositories;
using Marten;

namespace GoldenEye.Marten.Repositories
{
    public class MartenDocumentRepository<TEntity>:
        IRepository<TEntity>,
        IReadonlyRepository<TEntity>
        where TEntity : class, IHaveId
    {
        private readonly IDocumentSession documentSession;

        public MartenDocumentRepository(IDocumentSession documentSession)
        {
            this.documentSession = documentSession ?? throw new ArgumentException(nameof(documentSession));
        }

        public TEntity FindById(object id)
        {
            if (id == null)
                throw new ArgumentNullException("Id needs to have value");

            return id switch
            {
                Guid guid => documentSession.Load<TEntity>(guid),
                long l => documentSession.Load<TEntity>(l),
                int i => documentSession.Load<TEntity>(i),
                _ => documentSession.Load<TEntity>(id.ToString())
            };
        }

        public Task<TEntity> FindByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            if (id == null)
                throw new ArgumentNullException("Id needs to have value");

            return id switch
            {
                Guid guid => documentSession.LoadAsync<TEntity>(guid, cancellationToken),
                long l => documentSession.LoadAsync<TEntity>(l, cancellationToken),
                int i => documentSession.LoadAsync<TEntity>(i, cancellationToken),
                _ => documentSession.LoadAsync<TEntity>(id.ToString(), cancellationToken)
            };
        }

        public TEntity GetById(object id)
        {
            return FindById(id) ?? throw NotFoundException.For<TEntity>(id);
        }

        public async Task<TEntity> GetByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            var entity = await FindByIdAsync(id, cancellationToken);

            return entity ?? throw NotFoundException.For<TEntity>(id);
        }

        public IQueryable<TEntity> Query()
        {
            return documentSession.Query<TEntity>();
        }

        public IReadOnlyCollection<TEntity> Query(string query, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return documentSession.Query<TEntity>(query, queryParams);
        }

        public async Task<IReadOnlyCollection<TEntity>> QueryAsync(string query,
            CancellationToken cancellationToken = default, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            return await documentSession.QueryAsync<TEntity>(query, cancellationToken, queryParams);
        }

        public TEntity Add(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            documentSession.Insert(entity);

            return entity;
        }

        public Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var result = Add(entity);

            return Task.FromResult(result);
        }

        public IReadOnlyCollection<TEntity> AddAll(params TEntity[] entities)
        {
            if (entities == null)
                throw new ArgumentNullException(nameof(entities));

            if (entities.Length == 0)
                throw new ArgumentOutOfRangeException(nameof(entities), entities.Length,
                    $"{nameof(AddAll)} needs to have at least one entity provided.");

            documentSession.Insert(entities);

            return entities;
        }

        public Task<IReadOnlyCollection<TEntity>> AddAllAsync(CancellationToken cancellationToken = default,
            params TEntity[] entities)
        {
            var result = AddAll(entities);

            return Task.FromResult(result);
        }

        public TEntity Update(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            documentSession.Update(entity);

            return entity;
        }

        public Task<TEntity> UpdateAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            documentSession.Update(entity);

            return Task.FromResult(entity);
        }

        public TEntity Delete(TEntity entity)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            documentSession.Delete(entity);

            return entity;
        }

        public Task<TEntity> DeleteAsync(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            documentSession.Delete(entity);

            return Task.FromResult(entity);
        }

        public bool DeleteById(object id)
        {
            if (id == null)
                throw new ArgumentNullException(nameof(id));

            switch (id)
            {
                case Guid guid:
                    documentSession.Delete<TEntity>(guid);
                    break;
                case long l:
                    documentSession.Delete<TEntity>(l);
                    break;
                case int i:
                    documentSession.Delete<TEntity>(i);
                    break;
                default:
                    documentSession.Delete<TEntity>(id.ToString());
                    break;
            }

            return true;
        }

        public Task<bool> DeleteByIdAsync(object id, CancellationToken cancellationToken = default)
        {
            if (id == null)
                throw new ArgumentNullException(nameof(id));

            switch (id)
            {
                case Guid guid:
                    documentSession.Delete<TEntity>(guid);
                    break;
                case long l:
                    documentSession.Delete<TEntity>(l);
                    break;
                case int i:
                    documentSession.Delete<TEntity>(i);
                    break;
                default:
                    documentSession.Delete<TEntity>(id.ToString());
                    break;
            }

            return Task.FromResult(true);
        }

        public void SaveChanges()
        {
            documentSession.SaveChanges();
        }

        public Task SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            return documentSession.SaveChangesAsync(cancellationToken);
        }
    }
}
