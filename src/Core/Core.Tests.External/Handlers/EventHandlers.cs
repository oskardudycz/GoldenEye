using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Events;
using GoldenEye.Tests.External.Contracts;

namespace GoldenEye.Tests.External.Handlers;

public class FirstEventHandler: IEventHandler<BankAccountCreated>, IEventHandler<MoneyWasWithdrawn>
{
    public Task Handle(BankAccountCreated notification, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }

    public Task Handle(MoneyWasWithdrawn notification, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}

public class SecondEventHandler: IEventHandler<BankAccountCreated>
{
    public Task Handle(BankAccountCreated notification, CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}