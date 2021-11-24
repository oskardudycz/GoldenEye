using System;
using System.Collections.Generic;
using System.Linq;
using FluentAssertions;
using GoldenEye.Dapper.Mappings;
using Microsoft.Extensions.DependencyInjection;
using Xunit;

namespace GoldenEye.Dapper.Tests.Mappings;

public class RegistrationTests
{
    private class User
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
    }

    private class UserDapperMapping: IDapperMapping<User>
    {
        public string Add => "INSERT INTO Users (Id, Name) VALUES ('{0}', '{1}')";

        public string Update => "UPDATE Users Set Name = '{1}' WHERE Id = '{0}'";

        public string Delete => "DELETE FROM Users WHERE Id = '{0}'";

        public string Query => "SELECT Id, Name FROM Users";

        public string FindById => "SELECT Id, Name FROM Users WHERE Id = '{0}'";
    }

    private class Address
    {
        public Guid Id { get; set; }
        public string Street { get; set; }
    }

    private class AddressDapperMapping: IDapperMapping<User>
    {
        public string Add => "INSERT INTO Addresses (Id, Street) VALUES ('{0}', '{1}')";

        public string Update => "UPDATE Addresses Set Street = '{1}' WHERE Id = '{0}'";

        public string Delete => "DELETE FROM Addresses WHERE Id = '{0}'";

        public string Query => "SELECT Id, Street FROM Addresses";

        public string FindById => "SELECT Id, Street FROM Addresses WHERE Id = '{0}'";
    }

    [Fact]
    public void GivenTwoMappingsForEntityTypes_WhenAddAllDapperMappingsCalled_ThenAllDapperMappingsAreRegistered()
    {
        //Given
        var services = new ServiceCollection();

        //When
        services.AddAllDapperMappings();

        using (var sp = services.BuildServiceProvider())
        {
            var mappings = sp.GetServices<IDapperMapping>().ToList();
            var mappingsReadonlyCollection = sp.GetService<IReadOnlyCollection<IDapperMapping>>();

            mappings.Should().HaveCountGreaterOrEqualTo(2);
            mappingsReadonlyCollection.Should().HaveSameCount(mappings);

            mappings.Should().Contain(v => v is UserDapperMapping);
            mappings.Should().Contain(v => v is AddressDapperMapping);
        }
    }
}
