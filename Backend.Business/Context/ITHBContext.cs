using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;
using System.Linq;
using System.Data.Entity.Infrastructure;
using System.Data.SqlClient;

namespace Backend.Business.Context
{
    public interface ITHBContext: IDataContext
    {
        IDbSet<TaskEntity> Tasks { get; }
        IQueryable<TaskTypeEntity> TaskTypes { get; }
        IDbSet<ClientEntity> Clients { get; }
        DbQuery<Customer> Customers { get; }
        int AddOrUpdateTask(TaskEntity task);
    }
}