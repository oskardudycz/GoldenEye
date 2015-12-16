using GoldenEye.Backend.Core.Repository;
using GoldenEye.SPA.Business.Sample.Context;
using GoldenEye.SPA.Business.Sample.Entities;

namespace GoldenEye.SPA.Business.Sample.Repository
{
    public class TaskRepository: RepositoryBase<TaskEntity>, ITaskRepository
    {
        public TaskRepository(ISampleContext context): base(context, context.Tasks)
        {
        }
    }
}