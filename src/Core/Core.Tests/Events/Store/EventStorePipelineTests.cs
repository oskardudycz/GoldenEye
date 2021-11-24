using System;
using System.Threading.Tasks;
using FluentAssertions;
using GoldenEye.Events;
using GoldenEye.Events.Store;
using GoldenEye.Registration;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace GoldenEye.Tests.Events.Store;

public partial class EventStorePipelineTests
{
    public class UserCreated: IEvent
    {
        public Guid StreamId => Guid.NewGuid();
    }

    [Fact]
    public async Task
        GivenEventStorePipelineSetUp_WhenEventIsPublished_ThenEventIsStoredInEventStoreAutomaticallyWithPipeline()
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
        await eventBus.Publish(@event);

        //Then
        var eventStore = (EventStore)sp.GetService<IEventStore>();
        (await eventStore.Query()).Should().Contain(@event);
    }
}