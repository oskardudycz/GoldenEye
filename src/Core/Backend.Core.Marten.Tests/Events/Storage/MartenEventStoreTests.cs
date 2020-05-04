using System;
using System.Linq;
using FluentAssertions;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.Marten.Events.Storage;
using Marten.Integration.Tests.TestsInfrasructure;
using Xunit;

namespace Backend.Core.Marten.Tests.Events.Storage
{
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
        public void GivenEventStoreWithEvents_WhenQueried_ThenQueriedSuccessful()
        {
            var userId = Guid.NewGuid();
            //Given
            Sut.Store(userId,
                new UserCreated {UserId = userId, UserName = "john.sith"},
                new UserUpdated {UserId = userId, UserName = "john.smith"}
            );

            var secondUserId = Guid.NewGuid();
            Sut.Store(secondUserId,
                new UserCreated {UserId = secondUserId, UserName = "adam.sandler"}
            );

            Sut.SaveChanges();

            //When
            Sut.Query().OfType<UserCreated>().ToList().Should().HaveCount(2);
            Sut.Query<UserCreated>().ToList().Should().HaveCount(2);

            Sut.Query(userId).ToList().Should().HaveCount(2);
            Sut.Query(userId).OfType<UserUpdated>().ToList().Should().HaveCount(1);
        }
    }
}
