using System.Linq;
using FluentAssertions;
using GoldenEye.Repositories;
using GoldenEye.EntityFramework.Integration.Tests.Infrastructure;
using GoldenEye.EntityFramework.Integration.Tests.TestData;
using GoldenEye.EntityFramework.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Migrations;
using Xunit;

namespace GoldenEye.EntityFramework.Integration.Tests.Repositories
{
    public class EntityFrameworkRepositoryTests: EntityFrameworkTest
    {
        [Fact(Skip = "somehow it does not work on AppVeyor")]
        public void GivenRepository_WhenFullCRUDFlowIsRun_ThenSucceed()
        {
            var builder = new DbContextOptionsBuilder<UsersDbContext>();
            builder.UseNpgsql(ConnectionString,
                x => x.MigrationsHistoryTable(
                    HistoryRepository.DefaultTableName,
                    SchemaName));

            User user = null;
            using (var dbContext = new UsersDbContext(builder.Options))
            {
                var repository = new EntityFrameworkRepository<UsersDbContext, User>(dbContext);

                dbContext.Database.Migrate();

                user = new User {Id = 0, UserName = "john.doe@mail.com", FullName = null};

                //1. Add
                var result = repository.Add(user);
                repository.SaveChanges();

                result.Should().NotBe(null);
                result.Id.Should().BeGreaterThan(0);
                result.UserName.Should().Be("john.doe@mail.com");
                result.FullName.Should().BeNull();
            }
            //2. GetById

            using (var dbContext = new UsersDbContext(builder.Options))
            {
                var repository = new EntityFrameworkRepository<UsersDbContext, User>(dbContext);

                var recordFromDb = repository.FindById(user.Id);

                recordFromDb.Should().BeEquivalentTo(user);
            }

            //3. Update
            using (var dbContext = new UsersDbContext(builder.Options))
            {
                var repository = new EntityFrameworkRepository<UsersDbContext, User>(dbContext);

                var userToUpdate = new User {Id = user.Id, UserName = "tom.smith@mail.com", FullName = "Tom Smith"};

                repository = new EntityFrameworkRepository<UsersDbContext, User>(dbContext);
                var result = repository.Update(userToUpdate);
                repository.SaveChanges();

                result.Should().NotBe(null);
                result.Id.Should().Be(user.Id);
                result.UserName.Should().Be("tom.smith@mail.com");
                result.FullName.Should().Be("Tom Smith");

                var recordFromDb = repository.FindById(userToUpdate.Id);

                recordFromDb.Should().BeEquivalentTo(result);
            }



            //4. Remove
            using (var dbContext = new UsersDbContext(builder.Options))
            {
                var repository = new EntityFrameworkRepository<UsersDbContext, User>(dbContext);

                var result = repository.DeleteById(user.Id);
                repository.SaveChanges();

                result.Should().BeTrue();

                var recordFromDb = repository.FindById(user.Id);

                recordFromDb.Should().Be(null);
            }
            //5. Add Range
            using (var dbContext = new UsersDbContext(builder.Options))
            {
                var repository = new EntityFrameworkRepository<UsersDbContext, User>(dbContext);

                var results = repository.AddAll(
                    new User {UserName = "anna.frank@mail.com"},
                    new User {UserName = "anna.young@mail.com"},
                    new User {UserName = "anna.old@mail.com"}
                )?.ToList();
                repository.SaveChanges();

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
}
