using System.Data.Entity;
using Backend.Core.Repository;
using Backend.Business.Entities;
using Backend.Business.Context;

namespace Backend.Business.Repository
{
    public class TaskTypeRepository : ReadonlyRepositoryBase<TaskTypeEntity>, ITaskTypeRepository
    {
        public TaskTypeRepository(ITHBContext context)
            : base(context, context.TaskTypes.AsNoTracking())
        {
        }
    }
}