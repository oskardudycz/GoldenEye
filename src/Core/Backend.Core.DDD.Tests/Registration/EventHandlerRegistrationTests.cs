using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.DDD.Registration;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Backend.Core.DDD.Tests.Registration
{
    public class EventHandlerRegistrationTests
    {
        public class UserCreated : IEvent
        {
            public Guid UserId { get; }
            public Guid StreamId => UserId;

            public UserCreated(Guid userId)
            {
                UserId = userId;
            }
        }

        public class UsersCountHandler : IEventHandler<UserCreated>
        {
            public int UserCount { get; private set; }

            public Task Handle(UserCreated @event, CancellationToken cancellationToken)
            {
                UserCount++;
                return Unit.Task;
            }
        }

        public class UsersIdsHandler : IEventHandler<UserCreated>
        {
            public List<Guid> UserIds { get; private set; } = new List<Guid>();

            public Task Handle(UserCreated @event, CancellationToken cancellationToken)
            {
                UserIds.Add(@event.StreamId);
                return Unit.Task;
            }
        }

        [Fact]
        public async Task GivenTwoEventHandlers_WhenEventIsPublished_ThenBothHandles()
        {
            //Given
            var services = new ServiceCollection();
            services.AddDDD();
            services.RegisterEventHandler<UserCreated, UsersCountHandler>(ServiceLifetime.Singleton);
            services.RegisterEventHandler<UserCreated, UsersIdsHandler>(ServiceLifetime.Singleton);

            var sp = services.BuildServiceProvider();
            var eventBus = sp.GetService<IEventBus>();
            var @event = new UserCreated(Guid.NewGuid());

            //When
            await eventBus.PublishAsync(@event);

            //Then
            var usersCountHandler = sp.GetService<UsersCountHandler>();
            usersCountHandler.UserCount.Should().Be(1);

            var usersIdsHandler = sp.GetService<UsersIdsHandler>();
            usersIdsHandler.UserIds.Should().HaveCount(1);
            usersIdsHandler.UserIds.Should().Contain(@event.UserId);
        }
    }
}