using System.Collections.Generic;
using System.Linq;
using FluentAssertions;
using GoldenEye.Commands;
using GoldenEye.Events;
using GoldenEye.Queries;
using GoldenEye.Registration;
using GoldenEye.Tests.External.Contracts;
using GoldenEye.Tests.External.Handlers;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Xunit;
using static GoldenEye.Tests.Registration.CommandHandlerRegistrationTests;
using static GoldenEye.Tests.Registration.EventHandlerAllRegistrationTests;
using static GoldenEye.Tests.Registration.QueryHandlerRegistrationTests;

namespace GoldenEye.Tests.Registration;

public class AllHandlersRegistrationTests
{
    public AllHandlersRegistrationTests()
    {
        services.AddAllDDDHandlers(ServiceLifetime.Scoped);
    }

    private readonly ServiceCollection services = new ServiceCollection();

    private static void AllCommandHandlersShouldBeRegistered(ServiceProvider sp)
    {
        var addUserHandlers = sp.GetServices<IRequestHandler<AddUser, Unit>>()
            .Union(sp.GetServices<ICommandHandler<AddUser>>()).ToList();
        var updateUserHandlers = sp.GetServices<IRequestHandler<UpdateUser, Unit>>()
            .Union(sp.GetServices<ICommandHandler<UpdateUser>>()).ToList();

        addUserHandlers.Should().ContainSingle();
        addUserHandlers.Should().AllBeOfType<UserCommandHandler>();

        updateUserHandlers.Should().ContainSingle();
        updateUserHandlers.Should().AllBeOfType<UserCommandHandler>();
    }

    private static void AllExternalCommandHandlersShouldBeRegistered(ServiceProvider sp)
    {
        var createBankAccountHandlers = sp.GetServices<IRequestHandler<CreateBankAccount>>()
            .Union(sp.GetServices<ICommandHandler<CreateBankAccount>>()).ToList();
        var withdrawMoneyHandlers = sp.GetServices<IRequestHandler<WithdrawMoney>>()
            .Union(sp.GetServices<ICommandHandler<WithdrawMoney>>()).ToList();

        createBankAccountHandlers.Should().ContainSingle();
        createBankAccountHandlers.Should().AllBeOfType<CommandHandler>();

        withdrawMoneyHandlers.Should().ContainSingle();
        withdrawMoneyHandlers.Should().AllBeOfType<CommandHandler>();
    }

    private static void AllEventHandlersShouldBeRegistered(ServiceProvider sp)
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

    private static void AllExternalEventHandlersShouldBeRegistered(ServiceProvider sp)
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

    private static void AllQueryHandlersShouldBeRegistered(ServiceProvider sp)
    {
        var getUserHandlers = sp.GetServices<IRequestHandler<GetUser, User>>()
            .Union(sp.GetServices<IQueryHandler<GetUser, User>>()).ToList();
        var getUserListHandlers = sp.GetServices<IRequestHandler<GetUserList, IReadOnlyCollection<User>>>()
            .Union(sp.GetServices<IQueryHandler<GetUserList, IReadOnlyCollection<User>>>()).ToList();

        getUserHandlers.Should().ContainSingle();
        getUserHandlers.Should().AllBeOfType<UserQueryHandler>();

        getUserListHandlers.Should().ContainSingle();
        getUserListHandlers.Should().AllBeOfType<UserQueryHandler>();
    }

    private static void AllExternalQueryHandlersShouldBeRegistered(ServiceProvider sp)
    {
        var getBankAccountDetailsHandlers = sp
            .GetServices<IRequestHandler<GetBankAccountDetails, BankAccountDetails>>()
            .Union(sp.GetServices<IQueryHandler<GetBankAccountDetails, BankAccountDetails>>()).ToList();
        var getBankAccountHistoryHandlers = sp
            .GetServices<IRequestHandler<GetBankAccountHistory, IReadOnlyCollection<MoneyTransaction>>>()
            .Union(sp.GetServices<IQueryHandler<GetBankAccountHistory, IReadOnlyCollection<MoneyTransaction>>>())
            .ToList();

        getBankAccountDetailsHandlers.Should().ContainSingle();
        getBankAccountDetailsHandlers.Should().AllBeOfType<QueryHandler>();

        getBankAccountHistoryHandlers.Should().ContainSingle();
        getBankAccountHistoryHandlers.Should().AllBeOfType<QueryHandler>();
    }

    [Fact]
    public void GivenMultipleHandlers_WhenAddAllDDDHandlersCalled_ThenAllHandlersAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            //Commands
            AllCommandHandlersShouldBeRegistered(sp);
            AllExternalCommandHandlersShouldBeRegistered(sp);

            //Events
            AllEventHandlersShouldBeRegistered(sp);
            AllExternalEventHandlersShouldBeRegistered(sp);

            //Queries
            AllQueryHandlersShouldBeRegistered(sp);
            AllExternalQueryHandlersShouldBeRegistered(sp);
        }
    }
}