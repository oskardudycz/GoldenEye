using System.Collections.Generic;
using FluentAssertions;
using FluentValidation;
using GoldenEye.Backend.Core.Registration;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace Backend.Core.Tests.Registration
{
    public class RegistrationTests
    {
        public class DataContext
        {
            public List<string> Users = new List<string>();
        }

        private class CreateUser
        {
            public CreateUser(string userName)
            {
                UserName = userName;
            }

            public string UserName { get; }
        }

        private class CreateUserValidator: AbstractValidator<CreateUser>
        {
            public CreateUserValidator()
            {
                RuleFor(c => c.UserName).NotEmpty();
            }
        }

        private class CreateUserUniqueUsernameDomainValidator: AbstractValidator<CreateUser>
        {
            public CreateUserUniqueUsernameDomainValidator(DataContext dataContext)
            {
                RuleFor(c => c.UserName).Must(username => !dataContext.Users.Contains(username));
            }
        }

        [Fact]
        public void GivenTwoValidatorsForType_WhenAddAllValidatorsCalled_ThenAllValidatorsAreRegistered()
        {
            //Given
            var services = new ServiceCollection();

            services.AddSingleton<DataContext>();

            //When
            services.AddAllValidators();

            using (var sp = services.BuildServiceProvider())
            {
                var validators = sp.GetServices<IValidator<CreateUser>>();

                validators.Should().HaveCount(2);
                validators.Should().Contain(v => v is CreateUserValidator);
                validators.Should().Contain(v => v is CreateUserUniqueUsernameDomainValidator);
            }
        }
    }
}
