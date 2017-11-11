using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using FluentAssertions;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.Marten.Events.Storage;
using Marten.Integration.Tests.TestsInfrasructure;
using Xunit;

namespace Backend.Core.Marten.Tests.Events.Storage
{
    public class MartenEventStoreTests : MartenTest
    {
        private MartenEventStore Sut;

        public MartenEventStoreTests()
        {
            Sut = new MartenEventStore(Session);
        }

        public class UserCreated : IEvent
        {
            public Guid UserId { get; set; }
            public string UserName { get; set; }
            public Guid StreamId => UserId;
        }

        public class UserUpdated : IEvent
        {
            public Guid UserId { get; set; }
            public string UserName { get; set; }
            public Guid StreamId => UserId;
        }

        [Fact(Skip = "Myget can't run it")]
        public void GivenEventStoreWithEvents_WhenQueried_ThenQueriedSuccessful()
        {
            Guid userId = Guid.NewGuid();
            //Given
            Sut.Store(userId,
                new UserCreated { UserId = userId, UserName = "john.sith" },
                new UserUpdated { UserId = userId, UserName = "john.smith" }
            );

            Guid secondUserId = Guid.NewGuid();
            Sut.Store(secondUserId,
                new UserCreated { UserId = secondUserId, UserName = "adam.sandler" }
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