using System;
using System.Data;
using Npgsql;

namespace Marten.Integration.Tests.TestsInfrasructure
{
    public abstract class DapperTest : IDisposable
    {
        protected bool wasDisposed = false;
        protected readonly IDbConnection DbConnection;

        protected readonly string SchemaName = "sch" + Guid.NewGuid().ToString().Replace("-", string.Empty);

        public static string ConnectionString =
            "PORT = 5432; HOST = 127.0.0.1; TIMEOUT = 15; POOLING = True; MINPOOLSIZE = 1; MAXPOOLSIZE = 100; COMMANDTIMEOUT = 20; DATABASE = 'postgres'; PASSWORD = 'Password12!'; USER ID = 'postgres'";

        protected DapperTest() : this(true)
        {
        }

        protected DapperTest(bool shouldCreateSession)
        {
            if (shouldCreateSession)
            {
                DbConnection = CreateDbConnection();

                Execute($"CREATE SCHEMA IF NOT EXISTS {SchemaName};");
                Execute($"SET search_path TO {SchemaName}, public");
            }
        }

        protected virtual IDbConnection CreateDbConnection()
        {
            var connection = new NpgsqlConnection(ConnectionString);
            connection.Open();
            return connection;
        }

        protected void Execute(string sql)
        {
            using (var tran = DbConnection.BeginTransaction(IsolationLevel.ReadCommitted))
            {
                var command = DbConnection.CreateCommand();
                command.CommandText = sql;

                command.ExecuteNonQuery();

                tran.Commit();
            }
        }

        public void Dispose()
        {
            if (wasDisposed)
            {
                return;
            }
            wasDisposed = true;

            Execute($"DROP SCHEMA IF EXISTS {SchemaName} CASCADE;");

            DbConnection?.Dispose();
        }
    }
}