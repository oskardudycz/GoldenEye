using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Repository;

namespace GoldenEye.Backend.Business.Repository
{
    public class TaskTypeRepository : ReadonlyRepositoryBase<TaskTypeEntity>, ITaskTypeRepository
    {
        public TaskTypeRepository(ISampleContext context)
            : base(context, context.TaskTypes)
        {
        }
    }
}