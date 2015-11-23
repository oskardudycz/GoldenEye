using Backend.Core.Context;
using Backend.Business.Entities;
using System.Data.Entity;
using System.Linq;

namespace Backend.Business.Context
{
    public interface ITHBContext: IDataContext
    {
        IDbSet<Task> Tasks { get; }
        IQueryable<TaskType> TaskTypes { get; }
        int AddOrUpdateTask(Task task);
    }
}