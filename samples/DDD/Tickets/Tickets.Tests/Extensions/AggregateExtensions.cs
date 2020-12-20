using System.Linq;
using GoldenEye.Aggregates;
using GoldenEye.Events;

namespace Tickets.Tests.Extensions
{
    public static class AggregateExtensions
    {
        public static T PublishedEvent<T>(this IAggregate aggregate) where T : class, IEvent
        {
            return aggregate.DequeueUncommittedEvents().LastOrDefault() as T;
        }
    }
}
