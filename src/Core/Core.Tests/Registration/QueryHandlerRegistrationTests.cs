using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using GoldenEye.Queries;
using GoldenEye.Registration;
using GoldenEye.Tests.External.Contracts;
using GoldenEye.Tests.External.Handlers;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace GoldenEye.Tests.Registration;

public class QueryHandlerRegistrationTests
{
    public QueryHandlerRegistrationTests()
    {
        services.AddAllQueryHandlers(ServiceLifetime.Scoped);
    }

    public class User
    {
    }

    public class Account
    {
    }

    public class GetUser: IQuery<User>
    {
    }

    public class GetUserList: IQuery<IReadOnlyCollection<User>>
    {
    }

    public class GetAccount: IQuery<Account>
    {
    }

    public class GetAccountList: IQuery<IReadOnlyCollection<Account>>
    {
    }

    public class GetMainAccount: IQuery<Account>
    {
    }

    public class UserQueryHandler:
        IQueryHandler<GetUser, User>,
        IQueryHandler<GetUserList, IReadOnlyCollection<User>>
    {
        public Task<User> Handle(GetUser request, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }

        public Task<IReadOnlyCollection<User>> Handle(GetUserList request, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }

    public abstract class BaseAccountQueryHandler:
        IQueryHandler<GetAccount, Account>,
        IQueryHandler<GetAccountList, IReadOnlyCollection<Account>>
    {
        public abstract Task<Account> Handle(GetAccount request, CancellationToken cancellationToken);

        public Task<IReadOnlyCollection<Account>> Handle(GetAccountList request,
            CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }

    public class AccountQueryHandler:
        BaseAccountQueryHandler,
        IQueryHandler<GetMainAccount, Account>
    {
        public Task<Account> Handle(GetMainAccount request, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }

        public override Task<Account> Handle(GetAccount request, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }

    public class DuplicatedGetMainAccountQueryHandler:
        IQueryHandler<GetMainAccount, Account>
    {
        public Task<Account> Handle(GetMainAccount request, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }

    public abstract class AbstractQueryHandler:
        IQueryHandler<GetMainAccount, Account>
    {
        public Task<Account> Handle(GetMainAccount request, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }

    public class GenericQueryHandler<TQuery, TResponse>: IQueryHandler<TQuery, TResponse>
        where TQuery : IQuery<TResponse>
    {
        public Task<TResponse> Handle(TQuery request, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }

    private readonly ServiceCollection services = new ServiceCollection();

    [Fact]
    public void GivenAbstractQueryHandler_WhenAddAllQueryHandlerCalled_ThenIsNotRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var getMainAccountHandlers = sp.GetServices<IRequestHandler<GetMainAccount, Account>>()
                .Union(sp.GetServices<IQueryHandler<GetMainAccount, Account>>());

            getMainAccountHandlers.Should().NotContain(x => x is AbstractQueryHandler);
        }
    }

    [Fact]
    public void GivenBaseQueryHandler_WhenAddAllQueryHandlerCalled_ThenOnlyDerivedClassIsRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var getAccountHandlers = sp.GetServices<IRequestHandler<GetAccount, Account>>()
                .Union(sp.GetServices<IQueryHandler<GetAccount, Account>>());
            var getAccountListHandlers = sp
                .GetServices<IRequestHandler<GetAccountList, IReadOnlyCollection<Account>>>()
                .Union(sp.GetServices<IQueryHandler<GetAccountList, IReadOnlyCollection<Account>>>());

            getAccountHandlers.Should().ContainSingle();
            getAccountHandlers.Should().AllBeOfType<AccountQueryHandler>();

            getAccountListHandlers.Should().ContainSingle();
            getAccountListHandlers.Should().AllBeOfType<AccountQueryHandler>();
        }
    }

    [Fact]
    public void GivenDuplicatedQueryHandler_WhenAddAllQueryHandlerCalled_ThenBothAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var getMainAccountHandlers = sp.GetServices<IRequestHandler<GetMainAccount, Account>>()
                .Union(sp.GetServices<IQueryHandler<GetMainAccount, Account>>());

            getMainAccountHandlers.Should().HaveCount(2);
            getMainAccountHandlers.Should().Contain(x => x is AccountQueryHandler);
            getMainAccountHandlers.Should().Contain(x => x is DuplicatedGetMainAccountQueryHandler);
        }
    }

    [Fact]
    public void GivenGenericQueryHandler_WhenAddAllQueryHandlerCalled_ThenIsNotRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var genericHandler = sp.GetService<GenericQueryHandler<GetBankAccountDetails, BankAccountDetails>>();

            genericHandler.Should().BeNull();
        }
    }

    [Fact]
    public void GivenMultipleQueryHandler_WhenAddAllQueryHandlerCalled_ThenAllQueryHandlersAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
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
    }

    [Fact]
    public void
        GivenMultipleQueryHandlersFromApplicationDependencies_WhenAddAllQueryHandlerCalled_ThenBothAreRegistered()
    {
        using (var sp = services.BuildServiceProvider())
        {
            var getBankAccountDetailsHandlers = sp
                .GetServices<IRequestHandler<GetBankAccountDetails, BankAccountDetails>>()
                .Union(sp.GetServices<IQueryHandler<GetBankAccountDetails, BankAccountDetails>>()).ToList();
            var getBankAccountHistoryHandlers = sp
                .GetServices<IRequestHandler<GetBankAccountHistory, IReadOnlyCollection<MoneyTransaction>>>()
                .Union(
                    sp.GetServices<IQueryHandler<GetBankAccountHistory, IReadOnlyCollection<MoneyTransaction>>>())
                .ToList();

            getBankAccountDetailsHandlers.Should().ContainSingle();
            getBankAccountDetailsHandlers.Should().AllBeOfType<QueryHandler>();

            getBankAccountHistoryHandlers.Should().ContainSingle();
            getBankAccountHistoryHandlers.Should().AllBeOfType<QueryHandler>();
        }
    }
}