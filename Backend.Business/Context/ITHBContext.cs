using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;
using System.Linq;

namespace Backend.Business.Context
{
    public interface ITHBContext: IDataContext
    {
        IDbSet<TaskEntity> Tasks { get; }
        IQueryable<TaskTypeEntity> TaskTypes { get; }
        IDbSet<ClientEntity> Clients { get; }
        int AddOrUpdateTask(TaskEntity task);
    }
}