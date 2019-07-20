using System;
using System.Linq;
using FluentAssertions;
using GoldenEye.Backend.Core.DDD.Events;
using GoldenEye.Backend.Core.Marten.Events.Storage;
using GoldenEye.Backend.Core.Transactions;
using Marten.Integration.Tests.TestsInfrasructure;
using Xunit;

namespace Backend.Core.Marten.Tests.Transactions
{
    public class TransactionScopeUnitOfWorkTests: MartenTest
    {
        public class UserCreated: IEvent
        {
            public Guid UserId { get; set; }
            public string UserName { get; set; }
            public Guid StreamId => UserId;
        }

        public TransactionScopeUnitOfWorkTests() : base(false)
        {
        }

        [Fact(Skip = "not working")]
        public void Test()
        {
            var userId = Guid.NewGuid();
            var schemaName = GenerateSchemaName();

            using (var uow = new TransactionScopeUnitOfWork())
            {
                uow.Begin();

                using (var session = CreateSession(opt => opt.Events.DatabaseSchemaName = opt.DatabaseSchemaName = schemaName))
                {
                    var eventStore = new MartenEventStore(session);
                    //Given
                    eventStore.Store(userId,
                        new UserCreated { UserId = userId, UserName = "john.smith" }
                    );

                    eventStore.SaveChanges();

                    //When
                    eventStore.Query().OfType<UserCreated>().ToList().Should().HaveCount(1);
                }
            }

            using (var session = CreateSession(opt => opt.Events.DatabaseSchemaName = opt.DatabaseSchemaName = schemaName))
            {
                //Given
                var eventStore = new MartenEventStore(session);

                //When
                eventStore.Query().OfType<UserCreated>().ToList().Should().HaveCount(0);
            }
        }
    }
}
