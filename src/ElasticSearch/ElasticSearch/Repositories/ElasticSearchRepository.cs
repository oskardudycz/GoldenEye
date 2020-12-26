using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events.Aggregate;
using GoldenEye.Objects.General;
using GoldenEye.Repositories;

namespace GoldenEye.ElasticSearch.Repositories
{
    public class ElasticSearchRepository<TEntity>: IRepository<TEntity>
        where TEntity : class, IHaveId
    {
        private readonly IAggregateEventsPublisher aggregateEventsPublisher;

        public ElasticSearchRepository(IAggregateEventsPublisher aggregateEventsPublisher)
        {
            this.aggregateEventsPublisher = aggregateEventsPublisher;
        }

        public Task<TEntity> FindById(object id, CancellationToken cancellationToken = default)
        {
            if (id == null)
                throw new ArgumentNullException(nameof(id), "Id needs to have value");

            throw new NotImplementedException();
        }

        public IQueryable<TEntity> Query()
        {
            throw new NotImplementedException();
        }

        public Task<IReadOnlyCollection<TEntity>> RawQuery(string query,
            CancellationToken cancellationToken, params object[] queryParams)
        {
            if (query == null)
                throw new ArgumentNullException(nameof(query));

            if (queryParams == null)
                throw new ArgumentNullException(nameof(queryParams));

            throw new NotImplementedException();
        }

        public Task<TEntity> Add(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            throw new NotImplementedException();
        }

        public Task<TEntity> Update(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            throw new NotImplementedException();
        }

        public Task<TEntity> Update(TEntity entity, int expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<TEntity> Delete(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            throw new NotImplementedException();
        }

        public Task<TEntity> Delete(TEntity entity, int expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<bool> DeleteById(object id, CancellationToken cancellationToken = default)
        {
            if (id == null)
                throw new ArgumentNullException(nameof(id));

            throw new NotImplementedException();
        }

        public Task<bool> DeleteById(object id, int expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public async Task SaveChanges(CancellationToken cancellationToken = default)
        {
            await aggregateEventsPublisher.Publish(cancellationToken);
            throw new NotImplementedException();
        }
    }
}
