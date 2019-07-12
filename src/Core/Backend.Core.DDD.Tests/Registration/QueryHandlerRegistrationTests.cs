using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.DDD.Registration;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Backend.Core.DDD.Tests.Registration
{
    public class QueryHandlerRegistrationTests
    {
        public class User { }

        public class Account { }

        public class GetUser : IQuery<User> { }

        public class GetUserList : IQuery<IReadOnlyCollection<User>> { }

        public class GetAccount : IQuery<Account> { }

        public class GetAccountList : IQuery<IReadOnlyCollection<Account>> { }

        public class GetMainAccount : IQuery<Account> { }

        public class UserQueryHandler :
            IQueryHandler<GetUser, User>,
            IQueryHandler<GetUserList, IReadOnlyCollection<User>>
        {
            public Task<User> Handle(GetUser request, CancellationToken cancellationToken)
            {
                throw new System.NotImplementedException();
            }

            public Task<IReadOnlyCollection<User>> Handle(GetUserList request, CancellationToken cancellationToken)
            {
                throw new System.NotImplementedException();
            }
        }

        public abstract class BaseAccountQueryHandler :
            IQueryHandler<GetAccount, Account>,
            IQueryHandler<GetAccountList, IReadOnlyCollection<Account>>
        {
            public abstract Task<Account> Handle(GetAccount request, CancellationToken cancellationToken);

            public Task<IReadOnlyCollection<Account>> Handle(GetAccountList request, CancellationToken cancellationToken)
            {
                throw new System.NotImplementedException();
            }
        }

        public class AccountQueryHandler :
            BaseAccountQueryHandler,
            IQueryHandler<GetMainAccount, Account>
        {
            public override Task<Account> Handle(GetAccount request, CancellationToken cancellationToken)
            {
                throw new System.NotImplementedException();
            }

            public Task<Account> Handle(GetMainAccount request, CancellationToken cancellationToken)
            {
                throw new System.NotImplementedException();
            }
        }

        public class DuplicatedGetMainAccountQueryHandler :
            IQueryHandler<GetMainAccount, Account>
        {
            public Task<Account> Handle(GetMainAccount request, CancellationToken cancellationToken)
            {
                throw new System.NotImplementedException();
            }
        }

        private ServiceCollection services = new ServiceCollection();

        public QueryHandlerRegistrationTests()
        {
            services.AddAllQueryHandlers(ServiceLifetime.Scoped);
        }

        [Fact]
        public void GivenMultipleQueryHandler_WhenAddAllQueryHandlerCalled_ThenAllQueryHandlersAreRegistered()
        {
            using (var sp = services.BuildServiceProvider())
            {
                var addUserHandlers = sp.GetServices<IRequestHandler<GetUser, User>>()
                    .Union(sp.GetServices<IQueryHandler<GetUser, User>>()).ToList();
                var updateUserHandlers = sp.GetServices<IRequestHandler<GetUserList, IReadOnlyCollection<User>>>()
                    .Union(sp.GetServices<IQueryHandler<GetUserList, IReadOnlyCollection<User>>>()).ToList();

                addUserHandlers.Should().ContainSingle();
                addUserHandlers.Should().AllBeOfType<UserQueryHandler>();

                updateUserHandlers.Should().ContainSingle();
                updateUserHandlers.Should().AllBeOfType<UserQueryHandler>();
            }
        }

        [Fact]
        public void GivenBaseQueryHandler_WhenAddAllQueryHandlerCalled_ThenOnlyDerivedClassIsRegistered()
        {
            using (var sp = services.BuildServiceProvider())
            {
                var addAccountHandlers = sp.GetServices<IRequestHandler<GetAccount, Account>>()
                    .Union(sp.GetServices<IQueryHandler<GetAccount, Account>>());
                var updateAccountHandlers = sp.GetServices<IRequestHandler<GetAccountList, IReadOnlyCollection<Account>>>()
                    .Union(sp.GetServices<IQueryHandler<GetAccountList, IReadOnlyCollection<Account>>>());

                addAccountHandlers.Should().ContainSingle();
                addAccountHandlers.Should().AllBeOfType<AccountQueryHandler>();

                updateAccountHandlers.Should().ContainSingle();
                updateAccountHandlers.Should().AllBeOfType<AccountQueryHandler>();
            }
        }

        [Fact]
        public void GivenDuplicatedQueryHandler_WhenAddAllQueryHandlerCalled_ThenBothAreRegistered()
        {
            using (var sp = services.BuildServiceProvider())
            {
                var deleteAccountHandlers = sp.GetServices<IRequestHandler<GetMainAccount, Account>>()
                    .Union(sp.GetServices<IQueryHandler<GetMainAccount, Account>>());

                deleteAccountHandlers.Should().HaveCount(2);
                deleteAccountHandlers.Should().Contain(x => x is AccountQueryHandler);
                deleteAccountHandlers.Should().Contain(x => x is DuplicatedGetMainAccountQueryHandler);
            }
        }
        private IServiceCollection Collection { get; } = new ServiceCollection();
        [Fact]
        public void CanRegisterAllQueriesWithFromApplicationDependencies()
        {
            Collection.Scan(scan => scan
                .FromApplicationDependencies()
                .AddClasses(classes => classes.AssignableTo(typeof(IQueryHandler<,>)))
                .AsSelfWithInterfaces()
            );
            

            Assert.Collection(Collection,
                t => Assert.Equal(typeof(IQueryHandler<GetAccountList, IReadOnlyCollection<Account>>), t.ServiceType)
                
                );
        }
        [Fact]
        public void CanRegisterAllQueriesWithFromAssemblyOf()
        {
            Collection.Scan(scan => scan
                .FromAssemblyOf<GetAccountList>()
                .AddClasses(classes => classes.AssignableTo(typeof(IQueryHandler<,>)))
                .AsSelfWithInterfaces()
            );
            

            Assert.Collection(Collection,
                t => Assert.Equal(typeof(IQueryHandler<GetAccountList, IReadOnlyCollection<Account>>), t.ServiceType)
                
            );
        }
        
    }
}