using Backend.Core.Repository;
using Backend.Business.Context;

namespace Backend.Business.Repository
{
    public class TaskRepository: RepositoryBase<Task>, ITaskRepository
    {
        public TaskRepository(ITHBContext context): base(context, context.Tasks)
        {
        }

        public override Task Add(Task entity)
        {
            return AddOrUpdate(entity);
        }

        public override Task Update(Task entity)
        {
            return AddOrUpdate(entity);
        }

        private Task AddOrUpdate(Task entity)
        {
            var taskId = ((ITHBContext)Context).AddOrUpdateTask(entity);

            return GetById(taskId);
        }
    }
}