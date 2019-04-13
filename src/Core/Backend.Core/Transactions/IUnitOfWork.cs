using System;

namespace GoldenEye.Backend.Core.Transactions
{
    public interface IUnitOfWork : IDisposable
    {
        void Begin();

        void Commit();
    }
}