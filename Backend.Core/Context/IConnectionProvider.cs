using System.Data;
using System.Data.Common;

namespace Backend.Core.Context
{
    public interface IConnectionProvider
    {
        void Close();

        void Commit();

        void Dispose();

        DbConnection Open();

        DbConnection Renew();

        void Rollback();

        void BeginTransaction(IsolationLevel isolationLevel = IsolationLevel.ReadCommitted, bool rollbackPrevious = false);
    }
}
