using System.Threading;
using System.Threading.Tasks;
using GoldenEye.DDD.Events;
using GoldenEye.DDD.Tests.External.Contracts;

namespace GoldenEye.DDD.Tests.External.Handlers
{
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
}
