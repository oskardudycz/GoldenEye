using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;
using System.Linq;
using System.Data.Entity.Infrastructure;

namespace Backend.Business.Context
{
    public interface ITHBContext: IDataContext
    {
        IDbSet<TaskEntity> Tasks { get; }
        DbQuery<TaskTypeEntity> TaskTypes { get; }
        IDbSet<ClientEntity> Clients { get; }
        DbQuery<Customer> Customers { get; }
        IQueryable<ModelerUserEntity> ModelerUsers { get; }
        int AddOrUpdateTask(TaskEntity task);
    }
}