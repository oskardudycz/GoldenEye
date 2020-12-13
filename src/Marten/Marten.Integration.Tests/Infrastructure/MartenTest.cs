using System;
using System.Data;
using Marten;
using Marten.Events;
using Npgsql;

namespace GoldenEye.Marten.Integration.Tests.Infrastructure
{
    public abstract class MartenTest: IDisposable
    {
        public static string ConnectionString =
            "PORT = 5432; HOST = 127.0.0.1; TIMEOUT = 15; POOLING = True; MINPOOLSIZE = 1; MAXPOOLSIZE = 100; COMMANDTIMEOUT = 20; DATABASE = 'postgres'; PASSWORD = 'Password12!'; USER ID = 'postgres'";

        protected readonly string SchemaName = GenerateSchemaName();
        protected readonly IDocumentSession Session;

        protected MartenTest(): this(true)
        {
        }

        protected MartenTest(bool shouldCreateSession)
        {
            if (shouldCreateSession)
                Session = CreateSession();
        }

        protected IEventStore EventStore => Session.Events;

        public void Dispose()
        {
            Session?.Dispose();

            var sql = $"DROP SCHEMA {SchemaName} CASCADE;";
            using (var conn = new NpgsqlConnection(ConnectionString))
            {
                conn.Open();
                using (var tran = conn.BeginTransaction(IsolationLevel.ReadCommitted))
                {
                    var command = conn.CreateCommand();
                    command.CommandText = sql;

                    command.ExecuteNonQuery();

                    tran.Commit();
                }
            }
        }

        protected static string GenerateSchemaName() => "sch" + Guid.NewGuid().ToString().Replace("-", string.Empty);

        protected virtual IDocumentSession CreateSession(Action<StoreOptions> storeOptions = null)
        {
            var documentStore = Registration.Registration.CreateDocumentStore(ConnectionString, storeOptions, SchemaName);

            return Registration.Registration.CreateDocumentSession(documentStore);
        }
    }
}
