using System;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using GoldenEye.Shared.Core.Configuration;
using GoldenEye.Shared.Core.IOC.Attributes;

namespace GoldenEye.Backend.Core.Context
{
    [InjectInRequestScope]
    public class ConnectionProvider : IDisposable, IConnectionProvider
    {
        private readonly object _lockObject = new object();
        private SqlConnection _dbConnection;
        private SqlTransaction _sqlTransaction;
        private bool _wasDisposed;

        public void Close()
        {
            lock (_lockObject)
            {
                if (_sqlTransaction != null)
                {
                    _sqlTransaction.Dispose();
                    _sqlTransaction = null;
                }
                if (_dbConnection == null || _dbConnection.State != ConnectionState.Open) return;

                _dbConnection.Close();
                _dbConnection.Dispose();
                _dbConnection = null;
            }
        }

        public void Commit()
        {
            lock (_lockObject)
            {
                if (_sqlTransaction != null)
                {
                    _sqlTransaction.Commit();
                }
            }
        }

        public void Dispose()
        {
            if (_wasDisposed)
                return;

            _wasDisposed = true;
            Close();
            GC.SuppressFinalize(this);
        }

        public DbConnection Open()
        {
            lock (_lockObject)
            {
                if (_dbConnection != null)
                {
                    return _dbConnection;
                }

                _wasDisposed = false;

                _dbConnection = new SqlConnection(ConfigHelper.GetSettingAsString("DBConnectionString"));

                return _dbConnection;
            }
        }

        public DbConnection Renew()
        {
            lock (_lockObject)
            {
                if (_dbConnection == null) return Open();

                _dbConnection.Close();
                _dbConnection.Dispose();
                _dbConnection = null;
            }
            return Open();
        }

        public void Rollback()
        {
            lock (_lockObject)
            {
                if (_sqlTransaction != null)
                {
                    _sqlTransaction.Rollback();
                }
            }
        }

        public void BeginTransaction(IsolationLevel isolationLevel = IsolationLevel.ReadCommitted, bool rollbackPrevious = false)
        {
            lock (_lockObject)
            {
                if (_sqlTransaction != null && _sqlTransaction.Connection != null)
                {
                    if (rollbackPrevious)
                    {
                        _sqlTransaction.Rollback();
                    }
                    else
                    {
                        _sqlTransaction.Commit();
                    }
                }

                _sqlTransaction = _dbConnection.BeginTransaction(isolationLevel);
            }
        }
    }
}