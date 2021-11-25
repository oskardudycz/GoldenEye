using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Aggregates;
using GoldenEye.Repositories;

namespace Tickets.Tests.Stubs.Storage;

public class FakeRepository<T> : IRepository<T> where T : class, IAggregate
{
    public Dictionary<object, T> Aggregates { get; private set; }

    public FakeRepository(params T[] aggregates)
    {
        Aggregates = aggregates.ToDictionary(ks=> (object)ks.Id, vs => vs);
    }

    public Task<T> FindById(object id, CancellationToken cancellationToken)
    {
        return Task.FromResult(Aggregates.GetValueOrDefault(id)!);
    }

    public Task<T> Add(T aggregate, CancellationToken cancellationToken)
    {
        Aggregates.Add(aggregate.Id, aggregate);
        return Task.FromResult(aggregate);
    }

    public Task<T> Update(T aggregate, int? version, CancellationToken cancellationToken)
    {
        Aggregates[aggregate.Id] = aggregate;
        return Task.FromResult(aggregate);
    }

    public Task<T> Delete(T aggregate, int? version, CancellationToken cancellationToken)
    {
        Aggregates.Remove(aggregate.Id);
        return Task.FromResult(aggregate);
    }

    public Task<bool> DeleteById(object id, int? expectedVersion, CancellationToken cancellationToken = default)
    {
        Aggregates.Remove(id);
        return Task.FromResult(true);
    }

    public Task SaveChanges(CancellationToken cancellationToken = default)
    {
        return Task.CompletedTask;
    }
}