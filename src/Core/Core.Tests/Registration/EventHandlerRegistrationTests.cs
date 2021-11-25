using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using GoldenEye.Events;
using GoldenEye.Registration;
using GoldenEye.Tests.External.Contracts;
using GoldenEye.Tests.External.Handlers;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace GoldenEye.Tests.Registration;

public class EventHandlerRegistrationTests
{
    public class UserCreated: IEvent
    {
        public UserCreated(Guid userId)
        {
            UserId = userId;
        }

        public Guid UserId { get; }
        public Guid StreamId => UserId;
    }

    public class UsersCountHandler: IEventHandler<UserCreated>
    {
        public int UserCount { get; private set; }

        public Task Handle(UserCreated @event, CancellationToken cancellationToken)
        {
            UserCount++;
            return Unit.Task;
        }
    }

    public class UsersIdsHandler: IEventHandler<UserCreated>
    {
        public List<Guid> UserIds { get; } = new List<Guid>();

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
        services.AddEventHandler<UserCreated, UsersCountHandler>(ServiceLifetime.Singleton);
        services.AddEventHandler<UserCreated, UsersIdsHandler>(ServiceLifetime.Singleton);

        var sp = services.BuildServiceProvider();
        var eventBus = sp.GetService<IEventBus>();
        var @event = new UserCreated(Guid.NewGuid());

        //When
        await eventBus.Publish(@event);

        //Then
        var usersCountHandler = sp.GetService<UsersCountHandler>();
        usersCountHandler.UserCount.Should().Be(1);

        var usersIdsHandler = sp.GetService<UsersIdsHandler>();
        usersIdsHandler.UserIds.Should().HaveCount(1);
        usersIdsHandler.UserIds.Should().Contain(@event.UserId);
    }
}

public class EventHandlerAllRegistrationTests
{
    public EventHandlerAllRegistrationTests()
    {
        services.AddAllEventHandlers(ServiceLifetime.Scoped);
    }

    public class UserAdded: IEvent
    {
        public Guid StreamId => Guid.Empty;
    }

    public class UserUpdated: IEvent
    {
        public Guid StreamId => Guid.Empty;
    }

    public class AccountAdded: IEvent
    {
        public Guid StreamId => Guid.Empty;
    }

    public class AccountUpdated: IEvent
    {
        public Guid StreamId => Guid.Empty;
    }

    public class AccountDeleted: IEvent
    {
        public Guid StreamId => Guid.Empty;
    }

    public class UserEventHandler:
        IEventHandler<UserAdded>,
        IEventHandler<UserUpdated>
    {
        public Task Handle(UserAdded request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }

        public Task Handle(UserUpdated request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public abstract class BaseAccountEventHandler:
        IEventHandler<AccountAdded>,
        IEventHandler<AccountUpdated>
    {
        public abstract Task Handle(AccountAdded request, CancellationToken cancellationToken);

        public Task Handle(AccountUpdated request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public class AccountEventHandler:
        BaseAccountEventHandler,
        IEventHandler<AccountDeleted>
    {
        public Task Handle(AccountDeleted request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }

        public override Task Handle(AccountAdded request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public class DuplicatedDeleteAccountEventHandler:
        IEventHandler<AccountDeleted>
    {
        public Task Handle(AccountDeleted request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public abstract class AbstractEventHandler:
        IEventHandler<AccountDeleted>
    {
        public Task Handle(AccountDeleted request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public class GenericEventHandler<TEvent>: IEventHandler<TEvent>
        where TEvent : IEvent
    {
        public Task Handle(TEvent notification, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }

    private readonly ServiceCollection services = new ServiceCollection();

    [Fact]
    public void GivenAbstractEventHandler_WhenAddAllEventHandlerCalled_ThenIsNotRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var deleteAccountHandlers = sp.GetServices<INotificationHandler<AccountDeleted>>()
                .Union(sp.GetServices<IEventHandler<AccountDeleted>>());

            deleteAccountHandlers.Should().NotContain(x => x is AbstractEventHandler);
        }
    }

    [Fact]
    public void GivenBaseEventHandler_WhenAddAllEventHandlerCalled_ThenOnlyDerivedClassIsRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var accountAddedHandlers = sp.GetServices<INotificationHandler<AccountAdded>>()
                .Union(sp.GetServices<IEventHandler<AccountAdded>>());
            var accountUpdatedHandlers = sp.GetServices<INotificationHandler<AccountUpdated>>()
                .Union(sp.GetServices<IEventHandler<AccountUpdated>>());

            accountAddedHandlers.Should().ContainSingle();
            accountAddedHandlers.Should().AllBeOfType<AccountEventHandler>();

            accountUpdatedHandlers.Should().ContainSingle();
            accountUpdatedHandlers.Should().AllBeOfType<AccountEventHandler>();
        }
    }

    [Fact]
    public void GivenDuplicatedEventHandler_WhenAddAllEventHandlerCalled_ThenBothAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var deleteAccountHandlers = sp.GetServices<INotificationHandler<AccountDeleted>>()
                .Union(sp.GetServices<IEventHandler<AccountDeleted>>());

            deleteAccountHandlers.Should().HaveCount(2);
            deleteAccountHandlers.Should().Contain(x => x is AccountEventHandler);
            deleteAccountHandlers.Should().Contain(x => x is DuplicatedDeleteAccountEventHandler);
        }
    }

    [Fact]
    public void GivenGenericEventHandler_WhenAddAllEventHandlerCalled_ThenIsNotRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var genericHandler = sp.GetService<GenericEventHandler<BankAccountCreated>>();

            genericHandler.Should().BeNull();
        }
    }

    [Fact]
    public void GivenMultipleEventHandler_WhenAddAllEventHandlerCalled_ThenAllEventHandlersAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var userAddedHandlers = sp.GetServices<INotificationHandler<UserAdded>>()
                .Union(sp.GetServices<IEventHandler<UserAdded>>()).ToList();
            var userUpdatedHandlers = sp.GetServices<INotificationHandler<UserUpdated>>()
                .Union(sp.GetServices<IEventHandler<UserUpdated>>()).ToList();

            userAddedHandlers.Should().ContainSingle();
            userAddedHandlers.Should().AllBeOfType<UserEventHandler>();

            userUpdatedHandlers.Should().ContainSingle();
            userUpdatedHandlers.Should().AllBeOfType<UserEventHandler>();
        }
    }

    [Fact]
    public void
        GivenMultipleEventHandlersFromApplicationDependencies_WhenAddAllEventHandlerCalled_ThenBothAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var bankAccountCreatedHandlers = sp.GetServices<INotificationHandler<BankAccountCreated>>()
                .Union(sp.GetServices<IEventHandler<BankAccountCreated>>()).ToList();
            var moneyWasWithdrawnHandlers = sp.GetServices<INotificationHandler<MoneyWasWithdrawn>>()
                .Union(sp.GetServices<IEventHandler<MoneyWasWithdrawn>>()).ToList();

            bankAccountCreatedHandlers.Should().HaveCount(2);
            bankAccountCreatedHandlers.Should().Contain(x => x is FirstEventHandler);
            bankAccountCreatedHandlers.Should().Contain(x => x is SecondEventHandler);

            moneyWasWithdrawnHandlers.Should().ContainSingle();
            moneyWasWithdrawnHandlers.Should().AllBeOfType<FirstEventHandler>();
        }
    }
}