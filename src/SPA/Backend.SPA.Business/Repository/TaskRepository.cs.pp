using GoldenEye.Backend.Core.Repository;
using $rootnamespace$.Context;
using $rootnamespace$.Entities;

namespace $rootnamespace$.Repository
{
    public class TaskRepository: RepositoryBase<TaskEntity>, ITaskRepository
    {
        public TaskRepository(ISampleContext context): base(context, context.Tasks)
        {
        }
    }
}