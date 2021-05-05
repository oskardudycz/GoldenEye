using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events.Aggregate;
using GoldenEye.Objects.General;
using Nest;

namespace GoldenEye.ElasticSearch.Repositories
{
    public class ElasticSearchRepository<TEntity>: GoldenEye.Repositories.IRepository<TEntity>
        where TEntity : class, IHaveId
    {
        private readonly IElasticClient elasticClient;
        private readonly IAggregateEventsPublisher aggregateEventsPublisher;

        public ElasticSearchRepository(IElasticClient elasticClient, IAggregateEventsPublisher aggregateEventsPublisher)
        {
            this.elasticClient = elasticClient;
            this.aggregateEventsPublisher = aggregateEventsPublisher;
        }

        public async Task<TEntity> FindById(object id, CancellationToken cancellationToken = default)
        {
            if (id == null)
                throw new ArgumentNullException(nameof(id), "Id needs to have value");

            var result = id switch
            {
                string stringId => await elasticClient.GetAsync<TEntity>(stringId, ct: cancellationToken),
                long longId => await elasticClient.GetAsync<TEntity>(longId, ct: cancellationToken),
                int intId => await elasticClient.GetAsync<TEntity>(intId, ct: cancellationToken),
                Guid guidId => await elasticClient.GetAsync<TEntity>(guidId, ct: cancellationToken),
                _ => throw new ArgumentOutOfRangeException(nameof(id),
                    $"{nameof(id)} has to be of type string, int, long or Guid")
            };

            return result?.Source;
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

        public async Task<TEntity> Add(TEntity entity, CancellationToken cancellationToken = default)
        {
            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var result = entity.Id switch
            {
                string stringId => await elasticClient.IndexAsync(entity, i => i.Id(stringId), cancellationToken),
                long longId =>  await elasticClient.IndexAsync(entity, i => i.Id(longId), cancellationToken),
                int intId =>  await elasticClient.IndexAsync(entity, i => i.Id(intId), cancellationToken),
                Guid guidId => await elasticClient.IndexAsync(entity, i => i.Id(guidId), cancellationToken),
                _ => throw new ArgumentOutOfRangeException(nameof(entity.Id),
                    $"{nameof(entity.Id)} has to be of type string, int, long or Guid")
            };
            return entity;
        }

        public async Task<TEntity> Update(TEntity entity, int? expectedVersion, CancellationToken cancellationToken = default)
        {
            if(expectedVersion.HasValue)
                throw new NotImplementedException();

            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var result = entity.Id switch
            {
                string stringId => await elasticClient.UpdateAsync<TEntity>(stringId, i => i.Doc(entity), cancellationToken),
                long longId =>  await elasticClient.UpdateAsync<TEntity>(longId, i => i.Doc(entity), cancellationToken),
                int intId =>  await elasticClient.UpdateAsync<TEntity>(intId, i => i.Doc(entity), cancellationToken),
                Guid guidId => await elasticClient.UpdateAsync<TEntity>(guidId, i => i.Doc(entity), cancellationToken),
                _ => throw new ArgumentOutOfRangeException(nameof(entity.Id),
                    $"{nameof(entity.Id)} has to be of type string, int, long or Guid")
            };
            return entity;
        }

        public async Task<TEntity> Delete(TEntity entity, int? expectedVersion, CancellationToken cancellationToken = default)
        {
            if(expectedVersion.HasValue)
                throw new NotImplementedException();

            if (entity == null)
                throw new ArgumentNullException(nameof(entity));

            var result = entity.Id switch
            {
                string stringId => await elasticClient.DeleteAsync<TEntity>(stringId, ct:cancellationToken),
                long longId =>  await elasticClient.DeleteAsync<TEntity>(longId, ct:cancellationToken),
                int intId =>  await elasticClient.DeleteAsync<TEntity>(intId, ct:cancellationToken),
                Guid guidId => await elasticClient.DeleteAsync<TEntity>(guidId, ct:cancellationToken),
                _ => throw new ArgumentOutOfRangeException(nameof(entity.Id),
                    $"{nameof(entity.Id)} has to be of type string, int, long or Guid")
            };
            return entity;
        }

        public async Task<bool> DeleteById(object id, int? expectedVersion, CancellationToken cancellationToken = default)
        {
            if(expectedVersion.HasValue)
                throw new NotImplementedException();

            if (id == null)
                throw new ArgumentNullException(nameof(id));

            var result = id switch
            {
                string stringId => await elasticClient.DeleteAsync<TEntity>(stringId, ct:cancellationToken),
                long longId =>  await elasticClient.DeleteAsync<TEntity>(longId, ct:cancellationToken),
                int intId =>  await elasticClient.DeleteAsync<TEntity>(intId, ct:cancellationToken),
                Guid guidId => await elasticClient.DeleteAsync<TEntity>(guidId, ct:cancellationToken),
                _ => throw new ArgumentOutOfRangeException(nameof(id),
                    $"{nameof(id)} has to be of type string, int, long or Guid")
            };
            return result.IsValid;
        }

        public Task SaveChanges(CancellationToken cancellationToken = default)
        {
            return aggregateEventsPublisher.Publish(cancellationToken);
        }
    }
}
