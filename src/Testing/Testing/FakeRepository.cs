using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Aggregates;
using GoldenEye.Repositories;

namespace GoldenEye.Testing
{
    public class FakeRepository<T> : IRepository<T> where T : class, IAggregate
    {
        public Dictionary<Guid, T> Aggregates { get; private set; }

        public FakeRepository(params T[] aggregates)
        {
            Aggregates = aggregates.ToDictionary(ks=> ks.Id, vs => vs);
        }
        public Task<T> FindById(object id, CancellationToken cancellationToken = default)
        {
            return Task.FromResult(Aggregates.GetValueOrDefault((Guid)id));
        }

        public Task<T> Add(T aggregate, CancellationToken cancellationToken = default)
        {
            Aggregates.Add(aggregate.Id, aggregate);
            return Task.FromResult(aggregate);
        }

        public Task<T> Update(T aggregate, CancellationToken cancellationToken = default)
        {
            Aggregates[aggregate.Id] = aggregate;
            return Task.FromResult(aggregate);
        }

        public Task<T> Update(T entity, int expectedVersion, CancellationToken cancellationToken = default)
        {
            return Update(entity, cancellationToken);
        }

        public Task<T> Delete(T aggregate, CancellationToken cancellationToken = default)
        {
            Aggregates.Remove(aggregate.Id);
            return Task.FromResult(aggregate);
        }

        public Task<T> Delete(T entity, int expectedVersion, CancellationToken cancellationToken = default)
        {
            return Delete(entity, cancellationToken);
        }

        public Task<bool> DeleteById(object id, CancellationToken cancellationToken = default)
        {
            Aggregates.Remove((Guid)id);
            return Task.FromResult(true);
        }

        public Task<bool> DeleteById(object id, int expectedVersion, CancellationToken cancellationToken = default)
        {
            return DeleteById(id, cancellationToken);
        }

        public Task SaveChanges(CancellationToken cancellationToken = default)
        {
            return Task.CompletedTask;
        }
    }
}
