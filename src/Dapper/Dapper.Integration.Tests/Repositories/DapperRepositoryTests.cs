using System.Linq;
using System.Threading.Tasks;
using FluentAssertions;
using GoldenEye.Dapper.Integration.Tests.Infrastructure;
using GoldenEye.Dapper.Integration.Tests.TestData;
using GoldenEye.Dapper.Repositories;
using GoldenEye.Repositories;
using Xunit;

namespace GoldenEye.Dapper.Integration.Tests.Repositories
{
    public class DapperRepositoryTests: DapperTest
    {
        [Fact]
        public async Task GivenRepository_WhenFullCRUDFlowIsRun_ThenSucceed()
        {
            Execute(Structure.UsersCreateSql);

            var repository = new DapperRepository<User>(DbConnection);

            var user = new User {Id = 0, UserName = "john.doe@mail.com", FullName = null};

            //1. Add
            var result = await repository.Add(user);

            result.Should().NotBe(null);
            result.Id.Should().BeGreaterThan(0);
            result.UserName.Should().Be("john.doe@mail.com");
            result.FullName.Should().BeNull();

            //2. GetById

            var recordFromDb = await repository.FindById(user.Id);

            recordFromDb.Should().BeEquivalentTo(result);

            //3. Update
            var userToUpdate = new User {Id = user.Id, UserName = "tom.smith@mail.com", FullName = "Tom Smith"};

            result = await repository.Update(userToUpdate);

            result.Should().NotBe(null);
            result.Id.Should().Be(user.Id);
            result.UserName.Should().Be("tom.smith@mail.com");
            result.FullName.Should().Be("Tom Smith");

            recordFromDb = await repository.FindById(userToUpdate.Id);

            recordFromDb.Should().BeEquivalentTo(result);

            //4. Remove
            result = await repository.Delete(userToUpdate);

            result.Should().NotBe(null);
            result.Id.Should().Be(user.Id);
            result.UserName.Should().Be("tom.smith@mail.com");
            result.FullName.Should().Be("Tom Smith");

            recordFromDb = await repository.FindById(userToUpdate.Id);

            recordFromDb.Should().Be(null);

            //5. Add Range

            var results = (await repository.AddAll(
                default,
                new User {UserName = "anna.frank@mail.com"},
                new User {UserName = "anna.young@mail.com"},
                new User {UserName = "anna.old@mail.com"}
            ))?.ToList();

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

            var queryResults = repository.Query().ToList();

            queryResults.Should().Contain(x => results.Select(u => u.Id).Contains(x.Id));

            queryResults = repository.Query().ToList().Where(x => x.UserName == results[1].UserName).ToList();

            queryResults.Should().HaveCountGreaterOrEqualTo(1);
            queryResults.First(x => x.Id == results[1].Id).Should().BeEquivalentTo(results[1]);
        }
    }
}
