using System.Threading;
using System.Threading.Tasks;
using GoldenEye.DDD.Commands;
using GoldenEye.DDD.Tests.External.Contracts;
using MediatR;

namespace GoldenEye.DDD.Tests.External.Handlers
{
    public class CommandHandler: ICommandHandler<CreateBankAccount>, ICommandHandler<WithdrawMoney>
    {
        public Task<Unit> Handle(CreateBankAccount request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }

        public Task<Unit> Handle(WithdrawMoney request, CancellationToken cancellationToken)
        {
            return Unit.Task;
        }
    }
}
