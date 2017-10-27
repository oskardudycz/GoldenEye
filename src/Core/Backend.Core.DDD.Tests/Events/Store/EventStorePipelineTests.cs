using System;
using Xunit;
using Microsoft.Extensions.DependencyInjection;
using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.DDD.Events.Store;
using GoldenEye.Backend.Core.DDD.Events;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Shared.Core.Objects.General;
using System.Collections.Generic;
using Baseline;
using FluentAssertions;

namespace Backend.Core.DDD.Tests.Events.Store
{
    public class EventStorePipelineTests
    {
        public class EventStore : IEventStore
        {
            public IList<IEvent> Events = new List<IEvent>();

            public void SaveChanges()
            {
            }

            public Task SaveChangesAsync(CancellationToken token = default(CancellationToken))
            {
                return Task.CompletedTask;
            }

            public Guid Store(Guid stream, params IEvent[] events)
            {
                Events.AddRange(events);
                return stream;
            }

            public Task<Guid> StoreAsync(Guid stream, params IEvent[] events)
            {
                return Task.FromResult(Store(stream, events));
            }

            public TEntity Aggregate<TEntity>(Guid streamId)
                where TEntity : class, IHasGuidId, new()
            {
                return new TEntity();
            }

            public Task<TEntity> AggregateAsync<TEntity>(Guid streamId)
                where TEntity : class, IHasGuidId, new()
            {
                return Task.FromResult(Aggregate<TEntity>(streamId));
            }
        }

        public class UserCreated : IEvent
        {
            public Guid StreamId => Guid.NewGuid();
        }

        [Fact]
        public void GivenEventStorePipelineSetUp_WhenEventIsPublished_ThenEventIsStoredInEventStoreAutomaticallyWithPipeline()
        {
            //Given
            var services = new ServiceCollection();
            services.AddDDD();
            services.AddScoped<IEventStore, EventStore>();

            services.AddEventStorePipeline();

            var sp = services.BuildServiceProvider();
            var eventBus = sp.GetService<IEventBus>();
            var @event = new UserCreated();

            //When
            eventBus.Publish(@event);

            //Then
            var eventStore = (EventStore)sp.GetService<IEventStore>();
            eventStore.Events.Should().Contain(@event);
        }
    }
}