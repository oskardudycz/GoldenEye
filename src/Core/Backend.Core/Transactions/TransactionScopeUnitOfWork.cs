using System.Transactions;

namespace GoldenEye.Backend.Core.Transactions
{
    public class TransactionScopeUnitOfWork : IUnitOfWork
    {
        private TransactionScope transactionScope;

        private bool wasDisposed = false;

        public void Begin()
        {
            transactionScope = new TransactionScope(TransactionScopeAsyncFlowOption.Enabled);
        }

        public void Commit()
        {
            transactionScope.Complete();
        }

        public void Dispose()
        {
            if (wasDisposed)
                return;

            wasDisposed = true;
            transactionScope.Dispose();
        }
    }
}