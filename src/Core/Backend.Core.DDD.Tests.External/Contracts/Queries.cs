using GoldenEye.Backend.Core.DDD.Queries;

namespace Backend.Core.DDD.Tests.External.Contracts
{
    public class BankAccountDetails
    {
    }

    public class GetBankAccountDetails : IQuery<BankAccountDetails>
    {
    }

    public class MoneyTransaction
    {
    }

    public class GetBankAccountHistory : IListQuery<MoneyTransaction>
    {
    }
}