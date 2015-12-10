using GoldenEye.Backend.Business.Context;
using GoldenEye.Backend.Business.Entities;
using GoldenEye.Backend.Core.Repository;
using GoldenEye.Shared.Core.Security;

namespace GoldenEye.Backend.Business.Repository
{
    public class TaskRepository: RepositoryBase<TaskEntity>, ITaskRepository
    {
        private readonly IUserInfoProvider _userInfoProvider;

        public TaskRepository(ISampleContext context, IUserInfoProvider userInfoProvider): base(context, context.Tasks)
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
            var taskId = ((ISampleContext)Context).AddOrUpdateTask(entity);

            return GetById(taskId);
        }
    }
}