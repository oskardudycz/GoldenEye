using System;
using System.Data;
using System.Data.SqlClient;

namespace Marten.Integration.Tests.TestsInfrasructure
{
    public abstract class DapperTest: IDisposable
    {
        public static string ConnectionString =
            "Server=(local)\\SQL2017;Database=master;User ID=sa;Password=Password12!";

        protected readonly IDbConnection DbConnection;

        protected readonly string SchemaName = "sch" + Guid.NewGuid().ToString().Replace("-", string.Empty);
        protected bool wasDisposed;

        // "Server=localhost;Database=master;User ID=sa;Password=Password12!";

        protected DapperTest(): this(true)
        {
        }

        protected DapperTest(bool shouldCreateSession)
        {
            if (shouldCreateSession)
                DbConnection = CreateDbConnection();

            //Execute($"CREATE SCHEMA IF NOT EXISTS {SchemaName};");
            //Execute($"SET search_path TO {SchemaName}, public");
        }

        public void Dispose()
        {
            if (wasDisposed) return;
            wasDisposed = true;

            //Execute($"DROP SCHEMA IF EXISTS {SchemaName} CASCADE;");

            DbConnection?.Dispose();
        }

        protected virtual IDbConnection CreateDbConnection()
        {
            var connection = new SqlConnection(ConnectionString);
            connection.Open();
            return connection;
        }

        protected void Execute(string sql)
        {
            using (var tran = DbConnection.BeginTransaction(IsolationLevel.ReadCommitted))
            {
                var command = DbConnection.CreateCommand();
                command.CommandText = sql;
                command.Transaction = tran;

                command.ExecuteNonQuery();

                tran.Commit();
            }
        }
    }
}
