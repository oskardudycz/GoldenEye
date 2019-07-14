using System;
using GoldenEye.Backend.Core.DDD.Events;

namespace Backend.Core.DDD.Tests.External.Contracts
{
    public class BankAccountCreated : IEvent
    {
        public Guid StreamId => Guid.NewGuid();
    }

    public class MoneyWasWithdrawn : IEvent
    {
        public Guid StreamId => Guid.NewGuid();
    }
}