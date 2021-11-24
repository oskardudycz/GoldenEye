using System;
using GoldenEye.Events;

namespace GoldenEye.Tests.External.Contracts;

public class BankAccountCreated: IEvent
{
    public Guid StreamId => Guid.NewGuid();
}

public class MoneyWasWithdrawn: IEvent
{
    public Guid StreamId => Guid.NewGuid();
}