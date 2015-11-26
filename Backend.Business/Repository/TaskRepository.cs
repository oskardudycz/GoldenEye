using Backend.Core.Repository;
using Backend.Business.Context;
using Backend.Business.Entities;
using Shared.Core.Security;

namespace Backend.Business.Repository
{
    public class TaskRepository: RepositoryBase<TaskEntity>, ITaskRepository
    {
        private readonly IUserInfoProvider _userInfoProvider;

        public TaskRepository(ITHBContext context, IUserInfoProvider userInfoProvider): base(context, context.Tasks)
        {
            _userInfoProvider = userInfoProvider;
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
            entity.ModificationBy = _userInfoProvider.GetCurrentUserName();
            var taskId = ((ITHBContext)Context).AddOrUpdateTask(entity);

            return GetById(taskId);
        }
    }
}