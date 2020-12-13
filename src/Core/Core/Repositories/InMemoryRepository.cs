using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Core.Extensions.Collections;
using GoldenEye.Core.Objects.General;

namespace GoldenEye.Core.Repositories
{
    public class InMemoryRepository<TEntity>: InMemoryReadonlyRepository<TEntity>, IRepository<TEntity>
        where TEntity : class, IHaveId
    {
        public TEntity Add(TEntity entity)
        {
            Context.Add(entity);

            return entity;
        }

        public Task<TEntity> AddAsync(TEntity entity, CancellationToken cancellationToken)
        {
            return Task.FromResult(Add(entity));
        }

        public IReadOnlyCollection<TEntity> AddAll(params TEntity[] entities)
        {
            Context.AddRange(entities);

            return entities;
        }

        public Task<IReadOnlyCollection<TEntity>> AddAllAsync(CancellationToken cancellationToken = default,
            params TEntity[] entities)
        {
            return Task.FromResult(AddAll(entities));
        }

        public TEntity Update(TEntity entity)
        {
            Context.Replace(entity);

            return entity;
        }

        public Task<TEntity> UpdateAsync(TEntity entity, CancellationToken cancellationToken)
        {
            return Task.FromResult(Update(entity));
        }

        public TEntity Delete(TEntity entity)
        {
            Context.RemoveById(entity.Id);

            return entity;
        }

        public Task<TEntity> DeleteAsync(TEntity entity, CancellationToken cancellationToken)
        {
            return Task.FromResult(Delete(entity));
        }

        public bool DeleteById(object id)
        {
            Context.RemoveById(id);

            return true;
        }

        public Task<bool> DeleteByIdAsync(object id, CancellationToken cancellationToken)
        {
            return Task.FromResult(DeleteById(id));
        }

        public void SaveChanges()
        {
        }

        public Task SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            return Task.CompletedTask;
        }
    }
}
