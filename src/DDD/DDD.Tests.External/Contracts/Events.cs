using System;
using GoldenEye.DDD.Events;

namespace GoldenEye.DDD.Tests.External.Contracts
{
    public class BankAccountCreated: IEvent
    {
        public Guid StreamId => Guid.NewGuid();
    }

    public class MoneyWasWithdrawn: IEvent
    {
        public Guid StreamId => Guid.NewGuid();
    }
}
