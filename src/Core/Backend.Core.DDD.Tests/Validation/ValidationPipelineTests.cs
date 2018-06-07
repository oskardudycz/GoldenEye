using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using FluentValidation;
using GoldenEye.Backend.Core.DDD.Commands;
using GoldenEye.Backend.Core.DDD.Queries;
using GoldenEye.Backend.Core.DDD.Registration;
using MediatR;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Backend.Core.Tests.Validation
{
    public class ValidationPipelineTests
    {
        public class CommandTests
        {
            private class CreateUser : ICommand
            {
                public string UserName { get; }

                public CreateUser(string userName)
                {
                    UserName = userName;
                }
            }

            private class CreateUserValidator : AbstractValidator<CreateUser>
            {
                public CreateUserValidator()
                {
                    RuleFor(c => c.UserName).NotEmpty();
                }
            }

            private class RemoveAllUsers : ICommand
            {
            }

            public class DataContext
            {
                public List<string> Users = new List<string>();
            }

            private class UserCommandHandler : ICommandHandler<CreateUser>,
                ICommandHandler<RemoveAllUsers>
            {
                private readonly DataContext context;

                public UserCommandHandler(DataContext context)
                {
                    this.context = context;
                }

                public Task<Unit> Handle(CreateUser command, CancellationToken cancellationToken)
                {
                    context.Users.Add(command.UserName);
                    return Unit.Task;
                }

                public Task<Unit> Handle(RemoveAllUsers command, CancellationToken cancellationToken)
                {
                    context.Users.Clear();
                    return Unit.Task;
                }
            }

            [Fact]
            public async Task GivenValidationPipelineSetUp_WhenValidCommandWasSent_ThenCommandIsValidatedAndHandledByCommandHandler()
            {
                //Given
                var services = new ServiceCollection();
                services.AddDDD();

                services.AddValidationPipeline();
                services.AddSingleton<DataContext>();
                services.RegisterCommandHandler<CreateUser, UserCommandHandler>();
                services.AddTransient<IValidator<CreateUser>, CreateUserValidator>();

                using (var sp = services.BuildServiceProvider())
                {
                    var commandBus = sp.GetService<ICommandBus>();
                    var command = new CreateUser("John Doe");

                    //When
                    await commandBus.SendAsync(command);

                    //Then
                    var context = sp.GetService<DataContext>();
                    context.Users.Should().Contain(command.UserName);
                }
            }

            [Fact]
            public async Task GivenValidationPipelineSetUp_WhenCommandWithoutValidatorWasSent_ThenCommandIsNotValidatedAndHandledByCommandHandler()
            {
                //Given
                var services = new ServiceCollection();
                services.AddDDD();

                services.AddValidationPipeline();
                services.AddSingleton(new DataContext { Users = new List<string> { "John Doe" } });
                services.RegisterCommandHandler<RemoveAllUsers, UserCommandHandler>();
                //No validator Registered

                using (var sp = services.BuildServiceProvider())
                {
                    var commandBus = sp.GetService<ICommandBus>();
                    var command = new RemoveAllUsers();

                    //When
                    await commandBus.SendAsync(command);

                    //Then
                    var context = sp.GetService<DataContext>();
                    context.Users.Should().NotContain("John Doe");
                    context.Users.Should().BeEmpty();
                }
            }

            [Fact]
            public void GivenValidationPipelineSetUp_WhenInValidCommandWasSent_ThenCommandWasValidatedAndValidationExceptionWasThrown()
            {
                //Given
                var services = new ServiceCollection();
                services.AddDDD();

                services.AddValidationPipeline();
                services.AddSingleton<DataContext>();
                services.RegisterCommandHandler<CreateUser, UserCommandHandler>();
                services.AddTransient<IValidator<CreateUser>, CreateUserValidator>();

                using (var sp = services.BuildServiceProvider())
                {
                    var commandBus = sp.GetService<ICommandBus>();
                    var invalidCommand = new CreateUser(null);

                    Func<Task> sendCommandAsync = async () => await commandBus.SendAsync(invalidCommand);
                    //When
                    //Then
                    sendCommandAsync.Should().Throw<ValidationException>();

                    var context = sp.GetService<DataContext>();
                    context.Users.Should().BeEmpty();
                }
            }
        }

        public class QueriesTests
        {
            private class GetUser : IQuery<string>
            {
                public int Id { get; }

                public GetUser(int id)
                {
                    Id = id;
                }
            }

            private class GetUserValidator : AbstractValidator<GetUser>
            {
                public GetUserValidator()
                {
                    RuleFor(c => c.Id)
                        .GreaterThanOrEqualTo(0);
                }
            }

            private class GetAllUsers : IListQuery<string>
            {
            }

            public class DataContext
            {
                public List<string> Users = new List<string>();
            }

            private class UserQueryHandler : IQueryHandler<GetUser, string>,
                IQueryHandler<GetAllUsers, IReadOnlyList<string>>
            {
                private readonly DataContext context;

                public UserQueryHandler(DataContext context)
                {
                    this.context = context;
                }

                public Task<string> Handle(GetUser query, CancellationToken cancellationToken)
                {
                    return Task.FromResult(context.Users[query.Id]);
                }

                public Task<IReadOnlyList<string>> Handle(GetAllUsers query, CancellationToken cancellationToken)
                {
                    return Task.FromResult<IReadOnlyList<string>>(context.Users);
                }
            }

            [Fact]
            public async Task GivenValidationPipelineSetUp_WhenValidQueryWasSent_ThenQueryIsValidatedAndHandledByQueryHandler()
            {
                //Given
                var services = new ServiceCollection();
                services.AddDDD();

                services.AddValidationPipeline();
                services.AddSingleton(new DataContext { Users = new List<string> { "John Doe" } });
                services.RegisterQueryHandler<GetUser, string, UserQueryHandler>();
                services.AddTransient<IValidator<GetUser>, GetUserValidator>();

                using (var sp = services.BuildServiceProvider())
                {
                    var queryBus = sp.GetService<IQueryBus>();
                    var query = new GetUser(0);

                    //When
                    var result = await queryBus.SendAsync<GetUser, string>(query);

                    //Then
                    result.Should().NotBeNull();
                    result.Should().Be("John Doe");
                }
            }

            [Fact]
            public async Task GivenValidationPipelineSetUp_WhenQueryWithoutValidatorWasSent_ThenQueryIsNotValidatedAndHandledByQueryHandler()
            {
                //Given
                var services = new ServiceCollection();
                services.AddDDD();

                services.AddValidationPipeline();
                services.AddSingleton(new DataContext { Users = new List<string> { "John Doe" } });
                services.RegisterQueryHandler<GetAllUsers, IReadOnlyList<string>, UserQueryHandler>();

                using (var sp = services.BuildServiceProvider())
                {
                    var queryBus = sp.GetService<IQueryBus>();
                    var query = new GetAllUsers();

                    //When
                    var result = await queryBus.SendAsync<GetAllUsers, IReadOnlyList<string>>(query);

                    //Then
                    result.Should().HaveCount(1);
                    result[0].Should().Be("John Doe");
                }
            }

            [Fact]
            public async Task GivenValidationPipelineSetUp_WhenValidQueryWithoutValidatorWasSent_ThenQueryIsValidatedAndHandledByQueryHandler()
            {
                //Given
                var services = new ServiceCollection();
                services.AddDDD();

                services.AddValidationPipeline();
                services.AddSingleton(new DataContext { Users = new List<string> { "John Doe" } });
                services.RegisterQueryHandler<GetUser, string, UserQueryHandler>();
                services.AddTransient<IValidator<GetUser>, GetUserValidator>();

                using (var sp = services.BuildServiceProvider())
                {
                    var queryBus = sp.GetService<IQueryBus>();
                    var query = new GetUser(0);

                    //When
                    var result = await queryBus.SendAsync<GetUser, string>(query);

                    //Then
                    result.Should().NotBeNull();
                    result.Should().Be("John Doe");
                }
            }

            [Fact]
            public void GivenValidationPipelineSetUp_WhenInValidQueryWasSent_ThenQueryWasValidatedAndValidationExceptionWasThrown()
            {
                //Given
                var services = new ServiceCollection();
                services.AddDDD();

                services.AddValidationPipeline();
                services.AddSingleton(new DataContext { Users = new List<string> { "John Doe" } });
                services.RegisterQueryHandler<GetUser, string, UserQueryHandler>();
                services.AddTransient<IValidator<GetUser>, GetUserValidator>();

                using (var sp = services.BuildServiceProvider())
                {
                    var queryBus = sp.GetService<IQueryBus>();
                    var invalidQuery = new GetUser(-1);

                    Func<Task> sendQueryAsync = async () => await queryBus.SendAsync<GetUser, string>(invalidQuery);
                    //When
                    //Then
                    sendQueryAsync.Should().Throw<ValidationException>();
                }
            }
        }
    }
}