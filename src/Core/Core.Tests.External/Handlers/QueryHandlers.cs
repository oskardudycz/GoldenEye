using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using GoldenEye.Queries;
using GoldenEye.Tests.External.Contracts;

namespace GoldenEye.Tests.External.Handlers;

public class QueryHandler: IQueryHandler<GetBankAccountDetails, BankAccountDetails>,
    IQueryHandler<GetBankAccountHistory, IReadOnlyCollection<MoneyTransaction>>
{
    public Task<BankAccountDetails> Handle(GetBankAccountDetails request, CancellationToken cancellationToken)
    {
        return Task.FromResult(new BankAccountDetails());
    }

    public Task<IReadOnlyCollection<MoneyTransaction>> Handle(GetBankAccountHistory request,
        CancellationToken cancellationToken)
    {
        return Task.FromResult<IReadOnlyCollection<MoneyTransaction>>(new List<MoneyTransaction>());
    }
}