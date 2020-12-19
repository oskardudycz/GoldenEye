using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Extensions.Collections;
using GoldenEye.Objects.General;

namespace GoldenEye.Repositories
{
    public class InMemoryRepository<TEntity>: InMemoryReadonlyRepository<TEntity>, IRepository<TEntity>
        where TEntity : class, IHaveId
    {
        public Task<TEntity> Add(TEntity entity, CancellationToken cancellationToken)
        {
            Context.Add(entity);
            return Task.FromResult(entity);
        }

        public Task<TEntity> Update(TEntity entity, CancellationToken cancellationToken)
        {
            Context.Replace(entity);
            return Task.FromResult(entity);
        }

        public Task<TEntity> Update(TEntity entity, object expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<TEntity> Delete(TEntity entity, CancellationToken cancellationToken)
        {
            Context.RemoveById(entity.Id);
            return Task.FromResult(entity);
        }

        public Task<TEntity> Delete(TEntity entity, object expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task<bool> DeleteById(object id, CancellationToken cancellationToken)
        {
            Context.RemoveById(id);

            return Task.FromResult(true);
        }

        public Task<bool> DeleteById(object id, object expectedVersion, CancellationToken cancellationToken = default)
        {
            throw new NotImplementedException();
        }

        public Task SaveChanges(CancellationToken cancellationToken = default)
        {
            return Task.CompletedTask;
        }
    }
}
