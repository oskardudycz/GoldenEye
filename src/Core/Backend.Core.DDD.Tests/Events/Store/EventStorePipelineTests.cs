using System;
using Xunit;
using Microsoft.Extensions.DependencyInjection;
using GoldenEye.Backend.Core.DDD.Registration;
using GoldenEye.Backend.Core.DDD.Events.Store;
using GoldenEye.Backend.Core.DDD.Events;
using FluentAssertions;

namespace Backend.Core.DDD.Tests.Events.Store
{
    public partial class EventStorePipelineTests
    {
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
            eventStore.Query().Should().Contain(@event);
        }
    }
}