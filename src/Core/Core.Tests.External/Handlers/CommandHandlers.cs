using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Commands;
using GoldenEye.Tests.External.Contracts;
using MediatR;

namespace GoldenEye.Tests.External.Handlers;

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
