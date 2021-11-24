using System;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using GoldenEye.Commands;
using GoldenEye.Registration;
using GoldenEye.Tests.External.Contracts;
using GoldenEye.Tests.External.Handlers;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace GoldenEye.Tests.Registration;

public class CommandHandlerRegistrationTests
{
    public CommandHandlerRegistrationTests()
    {
        services.AddAllCommandHandlers(ServiceLifetime.Scoped);
    }

    public class AddUser: ICommand
    {
    }

    public class UpdateUser: ICommand
    {
    }

    public class AddAccount: ICommand
    {
    }

    public class UpdateAccount: ICommand
    {
    }

    public class DeleteAccount: ICommand
    {
    }

    public class UserCommandHandler:
        ICommandHandler<AddUser>,
        ICommandHandler<UpdateUser>
    {
        public Task<Unit> Handle(AddUser request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }

        public Task<Unit> Handle(UpdateUser request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public abstract class BaseAccountCommandHandler:
        ICommandHandler<AddAccount>,
        ICommandHandler<UpdateAccount>
    {
        public abstract Task<Unit> Handle(AddAccount request, CancellationToken cancellationToken);

        public Task<Unit> Handle(UpdateAccount request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public class AccountCommandHandler:
        BaseAccountCommandHandler,
        ICommandHandler<DeleteAccount>
    {
        public Task<Unit> Handle(DeleteAccount request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }

        public override Task<Unit> Handle(AddAccount request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public class DuplicatedDeleteAccountCommandHandler:
        ICommandHandler<DeleteAccount>
    {
        public Task<Unit> Handle(DeleteAccount request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public abstract class AbstractCommandHandler:
        ICommandHandler<DeleteAccount>
    {
        public Task<Unit> Handle(DeleteAccount request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }

    public class GenericCommandHandler<TCommand>: ICommandHandler<TCommand>
        where TCommand : ICommand
    {
        public Task<Unit> Handle(TCommand request, CancellationToken cancellationToken)
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
            var deleteAccountHandlers = sp.GetServices<IRequestHandler<DeleteAccount, Unit>>()
                .Union(sp.GetServices<ICommandHandler<DeleteAccount>>());

            deleteAccountHandlers.Should().NotContain(x => x is AbstractCommandHandler);
        }
    }

    [Fact]
    public void GivenBaseCommandHandler_WhenAddAllCommandHandlerCalled_ThenOnlyDerivedClassIsRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var addAccountHandlers = sp.GetServices<IRequestHandler<AddAccount, Unit>>()
                .Union(sp.GetServices<ICommandHandler<AddAccount>>());
            var updateAccountHandlers = sp.GetServices<IRequestHandler<UpdateAccount, Unit>>()
                .Union(sp.GetServices<ICommandHandler<UpdateAccount>>());

            addAccountHandlers.Should().ContainSingle();
            addAccountHandlers.Should().AllBeOfType<AccountCommandHandler>();

            updateAccountHandlers.Should().ContainSingle();
            updateAccountHandlers.Should().AllBeOfType<AccountCommandHandler>();
        }
    }

    [Fact]
    public void GivenDuplicatedCommandHandler_WhenAddAllCommandHandlerCalled_ThenBothAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var deleteAccountHandlers = sp.GetServices<IRequestHandler<DeleteAccount, Unit>>()
                .Union(sp.GetServices<ICommandHandler<DeleteAccount>>());

            deleteAccountHandlers.Should().HaveCount(2);
            deleteAccountHandlers.Should().Contain(x => x is AccountCommandHandler);
            deleteAccountHandlers.Should().Contain(x => x is DuplicatedDeleteAccountCommandHandler);
        }
    }

    [Fact]
    public void GivenGenericCommandHandler_WhenAddAllCommandHandlerCalled_ThenIsNotRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var genericHandler = sp.GetService<GenericCommandHandler<CreateBankAccount>>();

            genericHandler.Should().BeNull();
        }
    }

    [Fact]
    public void GivenMultipleCommandHandler_WhenAddAllCommandHandlerCalled_ThenAllCommandHandlersAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
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
    }

    [Fact]
    public void
        GivenMultipleCommandHandlersFromApplicationDependencies_WhenAddAllCommandHandlerCalled_ThenBothAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
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
    }
}