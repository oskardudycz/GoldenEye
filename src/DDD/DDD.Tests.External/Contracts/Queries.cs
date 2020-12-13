using GoldenEye.DDD.Queries;

namespace GoldenEye.DDD.Tests.External.Contracts
{
    public class BankAccountDetails
    {
    }

    public class GetBankAccountDetails: IQuery<BankAccountDetails>
    {
    }

    public class MoneyTransaction
    {
    }

    public class GetBankAccountHistory: IListQuery<MoneyTransaction>
    {
    }
}
