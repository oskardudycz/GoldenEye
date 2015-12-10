using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Context;

namespace GoldenEye.Backend.Business.Context
{
    public interface ISampleContext: IDataContext
    {
        IDbSet<TaskEntity> Tasks { get; }
        DbQuery<TaskTypeEntity> TaskTypes { get; }
        IDbSet<ClientEntity> Clients { get; }
        DbQuery<Customer> Customers { get; }
        IQueryable<ModelerUserEntity> ModelerUsers { get; }
        int AddOrUpdateTask(TaskEntity task);
    }
}