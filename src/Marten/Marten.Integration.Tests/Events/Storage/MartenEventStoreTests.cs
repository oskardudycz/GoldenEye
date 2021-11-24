using System;
using System.Linq;
using System.Threading.Tasks;
using FluentAssertions;
using GoldenEye.Events;
using GoldenEye.Events.Store;
using GoldenEye.Marten.Events.Storage;
using GoldenEye.Marten.Integration.Tests.Infrastructure;
using Xunit;

namespace GoldenEye.Marten.Integration.Tests.Events.Storage;

public class MartenEventStoreTests: MartenTest
{
    public MartenEventStoreTests()
    {
        Sut = new MartenEventStore(Session);
    }

    private readonly MartenEventStore Sut;

    public class UserCreated: IEvent
    {
        public Guid UserId { get; set; }
        public string UserName { get; set; }
        public Guid StreamId => UserId;
    }

    public class UserUpdated: IEvent
    {
        public Guid UserId { get; set; }
        public string UserName { get; set; }
        public Guid StreamId => UserId;
    }

    [Fact]
    public async Task GivenEventStoreWithEvents_WhenQueried_ThenQueriedSuccessful()
    {
        var userId = Guid.NewGuid();
        //Given
        await Sut.Append(userId,default,
            new UserCreated {UserId = userId, UserName = "john.sith"},
            new UserUpdated {UserId = userId, UserName = "john.smith"}
        );

        var secondUserId = Guid.NewGuid();
        await Sut.Append(secondUserId,default,
            new UserCreated {UserId = secondUserId, UserName = "adam.sandler"}
        );

        await Sut.SaveChanges();

        //When
        (await Sut.Query()).OfType<UserCreated>().ToList().Should().HaveCount(2);
        (await Sut.Query<UserCreated>()).ToList().Should().HaveCount(2);

        (await Sut.Query(streamId: userId)).ToList().Should().HaveCount(2);
        (await Sut.Query(streamId: userId)).OfType<UserUpdated>().ToList().Should().HaveCount(1);
    }
}
