using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Repository;

namespace GoldenEye.Backend.Business.Repository
{
    public class TaskRepository: RepositoryBase<TaskEntity>, ITaskRepository
    {
        public TaskRepository(ISampleContext context): base(context, context.Tasks)
        {
        }
    }
}