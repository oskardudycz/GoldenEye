using Backend.Core.Repository;
using Backend.Business.Context;
using Backend.Business.Entities;

namespace Backend.Business.Repository
{
    public class TaskRepository: RepositoryBase<TaskEntity>, ITaskRepository
    {
        public TaskRepository(ITHBContext context): base(context, context.Tasks)
        {
        }

        public override TaskEntity Add(TaskEntity entity)
        {
            return AddOrUpdate(entity);
        }

        public override TaskEntity Update(TaskEntity entity)
        {
            return AddOrUpdate(entity);
        }

        private TaskEntity AddOrUpdate(TaskEntity entity)
        {
            var taskId = ((ITHBContext)Context).AddOrUpdateTask(entity);

            return GetById(taskId);
        }
    }
}