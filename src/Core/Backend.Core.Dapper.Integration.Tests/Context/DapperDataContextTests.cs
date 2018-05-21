using System.Linq;
using Backend.Core.Dapper.Integration.Tests.TestData;
using FluentAssertions;
using GoldenEye.Backend.Core.Dapper.Context;
using Marten.Integration.Tests.TestsInfrasructure;
using Xunit;

namespace Backend.Core.Dapper.Integration.Tests.Context
{
    public class DapperDataContextTests : DapperTest
    {
        [Fact]
        public void GivenDataContextWithouts_WhenFullCRUDFlowIsRun_ThenSucceed()
        {
            Execute(Structure.UsersCreateSql);

            var dataContext = new DapperDataContext(DbConnection);

            var user = new User
            {
                Id = 0,
                UserName = "john.doe@mail.com",
                FullName = null
            };

            //1. Add
            var result = dataContext.Add(user);

            result.Should().NotBe(null);
            result.Id.Should().BeGreaterThan(0);
            result.UserName.Should().Be("john.doe@mail.com");
            result.FullName.Should().BeNull();

            //2. GetById

            var recordFromDb = dataContext.GetById<User>(user.Id);

            recordFromDb.Should().BeEquivalentTo(result);

            //3. Update
            var userToUpdate = new User
            {
                Id = user.Id,
                UserName = "tom.smith@mail.com",
                FullName = "Tom Smith"
            };

            result = dataContext.Update(userToUpdate);

            result.Should().NotBe(null);
            result.Id.Should().Be(user.Id);
            result.UserName.Should().Be("tom.smith@mail.com");
            result.FullName.Should().Be("Tom Smith");

            recordFromDb = dataContext.GetById<User>(userToUpdate.Id);

            recordFromDb.Should().BeEquivalentTo(result);

            //4. Remove
            result = dataContext.Remove(userToUpdate);

            result.Should().NotBe(null);
            result.Id.Should().Be(user.Id);
            result.UserName.Should().Be("tom.smith@mail.com");
            result.FullName.Should().Be("Tom Smith");

            recordFromDb = dataContext.GetById<User>(userToUpdate.Id);

            recordFromDb.Should().Be(null);

            //5. Add Range

            var results = dataContext.AddRange(
                new User { UserName = "anna.frank@mail.com" },
                new User { UserName = "anna.young@mail.com" },
                new User { UserName = "anna.old@mail.com" }
            )?.ToList();

            results.Should().NotBeNull();
            results.Should().HaveCount(3);

            results[0].Id.Should().BeGreaterThan(0);
            results[0].UserName.Should().Be("anna.frank@mail.com");
            results[0].FullName.Should().BeNull();

            results[1].Id.Should().BeGreaterThan(0);
            results[1].UserName.Should().Be("anna.young@mail.com");
            results[1].FullName.Should().BeNull();

            results[2].Id.Should().BeGreaterThan(0);
            results[2].UserName.Should().Be("anna.old@mail.com");
            results[2].FullName.Should().BeNull();

            //6. Query

            var queryResults = dataContext.GetQueryable<User>().ToList();

            queryResults.Should().Contain(x => results.Select(u => u.Id).Contains(x.Id));

            queryResults = dataContext.GetQueryable<User>().Where(x => x.UserName == results[1].UserName).ToList();

            queryResults.Should().HaveCountGreaterOrEqualTo(1);
            queryResults.First(x => x.Id == results[1].Id).Should().BeEquivalentTo(results[1]);
        }
    }
}