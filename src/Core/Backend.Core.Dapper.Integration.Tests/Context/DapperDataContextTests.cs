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
        }
    }
}