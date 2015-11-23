using Backend.Business.Context;
using Backend.Business.Entities;
using Backend.Core.Repository;

namespace Backend.Business.Repository
{
    public interface ITaskRepository: IRepository<TaskEntity>
    {
    }
}
