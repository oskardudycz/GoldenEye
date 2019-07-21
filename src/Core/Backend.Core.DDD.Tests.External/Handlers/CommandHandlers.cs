using System.Threading;
using System.Threading.Tasks;
using Backend.Core.DDD.Tests.External.Contracts;
using GoldenEye.Backend.Core.DDD.Commands;
using MediatR;

namespace Backend.Core.DDD.Tests.External.Handlers
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
