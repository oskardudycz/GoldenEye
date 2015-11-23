using Backend.Core.Repository;
using Backend.Business.Entities;
using Backend.Business.Context;

namespace Backend.Business.Repository
{
    public class TaskRepository: BaseRepository<TaskEntity>, ITaskRepository
    {
        public TaskRepository(ITHBContext context): base(context, context.Tasks)
        {
        }
    }
}